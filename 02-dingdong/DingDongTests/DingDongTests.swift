import XCTest
@testable import DingDong

final class DingDongTests: XCTestCase {

    // MARK: - TrackingTask

    func testRemainingCalculation() {
        let task = TrackingTask(
            id: UUID(), dbId: nil,
            hospitalCode: "ntuh", hospitalName: "台大醫院",
            department: "家庭醫學部", doctorName: "王醫師", clinicRoom: "01 診",
            userNumber: 55, threshold: 5,
            currentNumber: 40, lastUpdated: Date(), status: .active
        )
        XCTAssertEqual(task.remaining, 15)
    }

    func testRemainingNilWhenNoUserNumber() {
        let task = TrackingTask(
            id: UUID(), dbId: nil,
            hospitalCode: "ntuh", hospitalName: "台大醫院",
            department: "家庭醫學部", doctorName: "王醫師", clinicRoom: "01 診",
            userNumber: nil, threshold: 5,
            currentNumber: 40, lastUpdated: Date(), status: .active
        )
        XCTAssertNil(task.remaining)
    }

    // MARK: - Hospital Classification

    func testTaipeiClassification() {
        let hospital = Hospital(
            code: "ntuh", name: "台大醫院", shortName: "台大",
            city: "台北市", district: "中正區", level: "medical_center", isActive: true
        )
        XCTAssertEqual(HospitalArea.classify(hospital), .taipei)
    }

    // MARK: - NotifyMode

    func testNotifyModeDisplayName() {
        XCTAssertEqual(NotifyMode.light.displayName, "重要時機提醒")
        XCTAssertEqual(NotifyMode.normal.displayName, "每次更新提醒")
        XCTAssertEqual(NotifyMode.final_.displayName, "輪到時才提醒")
    }
}
