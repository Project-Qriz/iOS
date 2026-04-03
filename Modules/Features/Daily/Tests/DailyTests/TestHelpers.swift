import Foundation

// 100ms: fire-and-forget Task{ }가 완료되기에 충분한 대기 시간
let asyncSleepNanoseconds: UInt64 = 100_000_000

// 650ms: updateData() 내부 500ms sleep + 네트워크 완료 후 데이터가 ObservableObject에 반영되기까지 충분한 대기 시간
let updateDataSleepNanoseconds: UInt64 = 650_000_000
