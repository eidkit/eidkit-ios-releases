import Foundation
import EidKit
import OpenTelemetryApi
import OpenTelemetrySdk

// MARK: - EidKitSpanAdapter

/// Converts `EidKitSpan` callback events into OpenTelemetry spans.
///
/// Buffers all spans in a session and emits them in parent-first order once the root
/// `eidkit.session` span completes. This reconstructs the full parent-child waterfall
/// in Jaeger, Sentry, Grafana Tempo, and any other W3C-compatible backend.
///
/// **Usage:**
/// ```swift
/// let provider = TracerProviderBuilder()
///     .add(spanProcessor: SimpleSpanProcessor(spanExporter: myExporter))
///     .build()
/// OpenTelemetry.registerTracerProvider(tracerProvider: provider)
///
/// let adapter = EidKitSpanAdapter(
///     tracer: provider.get(instrumentationName: "io.eidkit.sdk")
/// )
/// try EidKitSdk.configure(EidKitConfig(onSpan: adapter.onSpan))
/// ```
///
/// Hold a strong reference to `EidKitSpanAdapter` for the lifetime of your app.
public final class EidKitSpanAdapter {

    private let tracer: any Tracer
    private let lock = NSLock()
    private var buffer: [EidKitSpan] = []

    public init(tracer: any Tracer) {
        self.tracer = tracer
    }

    /// Pass this closure to `EidKitConfig.onSpan`.
    public var onSpan: (EidKitSpan) -> Void {
        return { [weak self] span in self?.receive(span) }
    }

    private func receive(_ span: EidKitSpan) {
        lock.lock()
        buffer.append(span)
        let shouldFlush = span.parentSpanId == nil
        lock.unlock()
        if shouldFlush { flush() }
    }

    private func flush() {
        lock.lock()
        let spans = buffer
        buffer.removeAll()
        lock.unlock()

        // Build parent → [children] map
        var children: [String: [EidKitSpan]] = [:]
        var root: EidKitSpan?
        for span in spans {
            if let p = span.parentSpanId {
                children[p, default: []].append(span)
            } else {
                root = span
            }
        }
        guard let root else { return }

        // Emit root-first (DFS) so each parent OTel span exists before its children.
        // This gives correct parentSpanId linkage in the backend.
        func emit(_ span: EidKitSpan, parent: (any Span)?) {
            let builder = tracer
                .spanBuilder(spanName: span.name)
                .setSpanKind(spanKind: .internal)
                .setStartTime(time: span.startTime)
            if let parent { _ = builder.setParent(parent) }
            let otelSpan = builder.startSpan()
            for (key, value) in span.attributes {
                switch value {
                case .string(let s): otelSpan.setAttribute(key: key, value: s)
                case .int(let i):    otelSpan.setAttribute(key: key, value: i)
                }
            }
            if case .error(let desc) = span.status {
                otelSpan.status = Status.error(description: desc)
            }
            otelSpan.end(time: span.endTime)
            for child in children[span.spanId] ?? [] {
                emit(child, parent: otelSpan)
            }
        }

        emit(root, parent: nil)
    }
}



// MARK: - OtlpHttpSpanExporter

/// A generic OTLP/HTTP JSON span exporter.
///
/// Serialises completed spans to the OTLP JSON wire format and POSTs them
/// to any compatible backend (Sentry, Honeycomb, Grafana Tempo, Jaeger, etc.).
///
/// **Usage:**
/// ```swift
/// let exporter = OtlpHttpSpanExporter(
///     endpoint: URL(string: "https://ingest.example.com/otlp/v1/traces")!,
///     headers: ["x-api-key": "your-key"]
/// )
/// let provider = TracerProviderBuilder()
///     .add(spanProcessor: SimpleSpanProcessor(spanExporter: exporter))
///     .build()
/// ```
///
/// `export()` blocks until the HTTP response arrives (or `explicitTimeout` elapses),
/// which is safe because `SimpleSpanProcessor` already dispatches to a background queue.
public final class OtlpHttpSpanExporter: SpanExporter {

    private let endpoint: URL
    private let headers: [String: String]
    private let resource: Resource

    /// - Parameters:
    ///   - endpoint: OTLP/HTTP traces endpoint URL.
    ///   - headers:  HTTP headers to include on every request (auth, API keys, etc.).
    ///   - resource: OTel `Resource` describing the service/device. Included in every export batch.
    public init(endpoint: URL, headers: [String: String] = [:], resource: Resource = Resource()) {
        self.endpoint = endpoint
        self.headers = headers
        self.resource = resource
    }

    public func export(spans: [SpanData], explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        guard let body = try? JSONSerialization.data(withJSONObject: buildPayload(spans)) else {
            return .failure
        }
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            req.setValue(value, forHTTPHeaderField: key)
        }
        req.httpBody = body

        let sem = DispatchSemaphore(value: 0)
        var result: SpanExporterResultCode = .success
        URLSession.shared.dataTask(with: req) { _, res, err in
            if let err {
                print("[EidKitOtlp] export error: \(err.localizedDescription)")
                result = .failure
            } else if let http = res as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("[EidKitOtlp] HTTP \(http.statusCode)")
                result = .failure
            }
            sem.signal()
        }.resume()
        _ = sem.wait(timeout: .now() + (explicitTimeout ?? 10))
        return result
    }

    public func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode { .success }
    public func shutdown(explicitTimeout: TimeInterval?) {}

    // MARK: - OTLP JSON payload

    private lazy var resourceAttrs: [[String: Any]] = {
        resource.attributes
            .sorted { $0.key < $1.key }
            .map { ["key": $0.key, "value": otlpValue($0.value)] }
    }()

    private func buildPayload(_ spans: [SpanData]) -> [String: Any] {
        var byScopeKey: [String: [SpanData]] = [:]
        for s in spans {
            let key = s.instrumentationScope.name + "|" + (s.instrumentationScope.version ?? "")
            byScopeKey[key, default: []].append(s)
        }
        let scopeSpans: [[String: Any]] = byScopeKey.values.map { group in
            let info = group[0].instrumentationScope
            var scopeObj: [String: Any] = ["name": info.name]
            if let v = info.version { scopeObj["version"] = v }
            return ["scope": scopeObj, "spans": group.map { otlpSpan($0) }]
        }
        return ["resourceSpans": [["resource": ["attributes": resourceAttrs], "scopeSpans": scopeSpans]]]
    }

    private func otlpSpan(_ s: SpanData) -> [String: Any] {
        var obj: [String: Any] = [
            "traceId":           s.traceId.hexString,
            "spanId":            s.spanId.hexString,
            "name":              s.name,
            "kind":              otlpKind(s.kind),
            "startTimeUnixNano": nanos(s.startTime),
            "endTimeUnixNano":   nanos(s.endTime),
            "attributes":        s.attributes.sorted { $0.key < $1.key }
                                     .map { ["key": $0.key, "value": otlpValue($0.value)] },
            "status":            otlpStatus(s.status),
        ]
        if let parent = s.parentSpanId, parent.isValid {
            obj["parentSpanId"] = parent.hexString
        }
        return obj
    }

    private func nanos(_ date: Date) -> String {
        String(Int64(date.timeIntervalSince1970 * 1_000_000_000))
    }

    private func otlpKind(_ k: SpanKind) -> Int {
        switch k {
        case .internal: return 1; case .server: return 2; case .client: return 3
        case .producer: return 4; case .consumer: return 5
        @unknown default: return 1
        }
    }

    private func otlpStatus(_ s: Status) -> [String: Any] {
        switch s {
        case .unset:          return ["code": 0]
        case .ok:             return ["code": 1]
        case .error(let msg): return ["code": 2, "message": msg]
        }
    }
}

// MARK: - ConsoleSpanExporter

/// Prints one line per completed span to stdout.
///
/// Format: `[EidKitOtlp] <name> <ms>ms [<status>] key=value ...`
///
/// Useful during development to confirm spans are being emitted without
/// needing a backend.
public final class ConsoleSpanExporter: SpanExporter {
    public init() {}

    public func export(spans: [SpanData], explicitTimeout: TimeInterval?) -> SpanExporterResultCode {
        for s in spans {
            let ms = String(format: "%.1f", s.endTime.timeIntervalSince(s.startTime) * 1000)
            let attrs = s.attributes.sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }.joined(separator: " ")
            let status: String
            switch s.status {
            case .ok:    status = "OK"
            case .unset: status = "UNSET"
            case .error: status = "ERROR"
            }
            print("[EidKitOtlp] \(s.name) \(ms)ms [\(status)] \(attrs)")
        }
        return .success
    }

    public func flush(explicitTimeout: TimeInterval?) -> SpanExporterResultCode { .success }
    public func shutdown(explicitTimeout: TimeInterval?) {}
}

// MARK: - AttributeValue -> OTLP JSON

private func otlpValue(_ v: AttributeValue) -> [String: Any] {
    switch v {
    case .string(let s):      return ["stringValue": s]
    case .bool(let b):        return ["boolValue": b]
    case .int(let i):         return ["intValue": "\(i)"]  // int64 as decimal string per OTLP JSON spec
    case .double(let d):      return ["doubleValue": d]
    case .stringArray(let a): return ["arrayValue": ["values": a.map { ["stringValue": $0] }]]
    case .boolArray(let a):   return ["arrayValue": ["values": a.map { ["boolValue": $0] }]]
    case .intArray(let a):    return ["arrayValue": ["values": a.map { ["intValue": "\($0)"] }]]
    case .doubleArray(let a): return ["arrayValue": ["values": a.map { ["doubleValue": $0] }]]
    @unknown default:         return ["stringValue": "\(v)"]
    }
}

