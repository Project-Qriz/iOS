import UIKit
import DesignSystem
import QRIZUtils

final class DeleteAccountInfoView: UIView {

    // MARK: - UI

    private let bulletLabel1: UILabel = {
        let label = UILabel()
        label.text = "•  회원 탈퇴 시 계정 정보는 모두 삭제됩니다."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .coolNeutral500
        return label
    }()

    private let bulletLabel2: UILabel = {
        let label = UILabel()
        label.text = "•  진행 중인 '오늘의 공부'를 포함해, 모든 데이터가 삭\n    제되며 복구할 수 없습니다."
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
                constant: 20.0
            ),
            bulletLabel1.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            bulletLabel1.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),

            bulletLabel2.topAnchor.constraint(
                equalTo: bulletLabel1.bottomAnchor,
                constant: 8.0
            ),
            bulletLabel2.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            bulletLabel2.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),
            bulletLabel2.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -20.0
            )
        ])
    }
}
