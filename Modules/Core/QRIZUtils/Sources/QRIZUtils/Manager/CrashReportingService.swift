//
//  CrashReportingService.swift
//  QRIZUtils
//

@MainActor
public protocol CrashReportingService: Sendable {
    /// 앱을 죽이지 않은 비치명적(non-fatal) 에러를 리포팅한다.
    /// - Parameters:
    ///   - error: 발생한 에러
    ///   - context: 어디서 발생했는지 구분하기 위한 짧은 식별자(예: API 엔드포인트 경로)
    func record(_ error: Error, context: String)
}

@MainActor
public final class CrashReportingManager: CrashReportingService {

    public nonisolated static let shared = CrashReportingManager()

    private var service: (any CrashReportingService)?

    private nonisolated init() {}

    public func configure(service: any CrashReportingService) {
        self.service = service
    }

    public func record(_ error: Error, context: String) {
        service?.record(error, context: context)
    }
}
