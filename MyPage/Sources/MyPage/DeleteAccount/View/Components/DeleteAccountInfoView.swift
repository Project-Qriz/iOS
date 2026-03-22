import UIKit
import DesignSystem
import QRIZUtils

final class DeleteAccountInfoView: UIView {

    // MARK: - Enums

    private enum Metric {
        static let horizontalSpacing: CGFloat = 18.0
        static let verticalSpacing: CGFloat = 20.0
        static let bulletLabel2TopOffset: CGFloat = 8.0
    }

    private enum Attributes {
        static let bullet1Text: String = "•  회원 탈퇴 시 계정 정보는 모두 삭제됩니다."
        static let bullet2Text: String = "•  진행 중인 '오늘의 공부'를 포함해, 모든 데이터가 삭\n    제되며 복구할 수 없습니다."
    }

    // MARK: - UI

    private let bulletLabel1: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet1Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        return label
    }()

    private let bulletLabel2: UILabel = {
        let label = UILabel()
        label.text = Attributes.bullet2Text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        addSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func setupStyle() {
        backgroundColor = .white
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.coolNeutral100.cgColor
        layer.cornerRadius = 8.0
        applyQRIZShadow(radius: 8.0, color: .coolNeutral300)
    }
}

// MARK: - Layout Setup

extension DeleteAccountInfoView {
    private func addSubviews() {
        [bulletLabel1, bulletLabel2].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        bulletLabel1.translatesAutoresizingMaskIntoConstraints = false
        bulletLabel2.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bulletLabel1.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Metric.verticalSpacing
            ),
            bulletLabel1.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel1.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),

            bulletLabel2.topAnchor.constraint(
                equalTo: bulletLabel1.bottomAnchor,
                constant: Metric.bulletLabel2TopOffset
            ),
            bulletLabel2.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metric.horizontalSpacing
            ),
            bulletLabel2.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metric.horizontalSpacing
            ),
            bulletLabel2.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metric.verticalSpacing
            )
        ])
    }
}
