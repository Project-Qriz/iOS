import UIKit
import DesignSystem
import Combine

final class DeleteAccountMainView: UIView {

    // MARK: - Properties

    private let deleteTapSubject = PassthroughSubject<Void, Never>()

    var deleteTapPublisher: AnyPublisher<Void, Never> {
        deleteTapSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .coolNeutral100
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원 탈퇴 시 아래 내용을 확인해 주세요."
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private let infoView = DeleteAccountInfoView()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "QRIZ 회원 탈퇴를 하시겠습니까?"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .coolNeutral500
        return label
    }()

    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "회원 탈퇴"
        config.baseBackgroundColor = .customBlue500
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attrs = incoming
            attrs.font = .systemFont(ofSize: 16, weight: .medium)
            return attrs
        }
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            self?.deleteTapSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    private func setupUI() {
        backgroundColor = .white
    }
}

// MARK: - Layout Setup

extension DeleteAccountMainView {
    private func addSubviews() {
        [
            separator,
            titleLabel,
            infoView,
            questionLabel,
            deleteButton
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0),

            titleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 40.0
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),

            infoView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 20.0
            ),
            infoView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            infoView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),

            questionLabel.topAnchor.constraint(
                equalTo: infoView.bottomAnchor,
                constant: 20.0
            ),
            questionLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            questionLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),

            deleteButton.topAnchor.constraint(
                equalTo: questionLabel.bottomAnchor,
                constant: 14.0
            ),
            deleteButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            deleteButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),
            deleteButton.heightAnchor.constraint(
                equalTo: deleteButton.widthAnchor,
                multiplier: 0.117
            )
        ])
    }
}
