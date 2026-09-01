//
//  CrashReportingServiceImpl.swift
//  QRIZ
//

import FirebaseCrashlytics
import QRIZUtils

final class CrashReportingServiceImpl: CrashReportingService, @unchecked Sendable {

    func record(_ error: Error, context: String) {
        Crashlytics.crashlytics().setCustomValue(context, forKey: "context")
        Crashlytics.crashlytics().record(error: error)
    }
}
