import UIKit
import DesignSystem
import QRIZUtils
import Combine

final class QuickActionsCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let horizontalSpacing: CGFloat = 8.0
        static let buttonAspectRatio: CGFloat = 82.0 / 165.5
    }

    private enum Attributes {
        static let resetPlanText: String = "플랜 초기화"
        static let registerExamText: String = "시험 등록"
    }

    // MARK: - Properties

    private let resetPlanTappedSubject = PassthroughSubject<Void, Never>()
    private let registerExamTappedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    var resetPlanTappedPublisher: AnyPublisher<Void, Never> {
        resetPlanTappedSubject.eraseToAnyPublisher()
    }

    var registerExamTappedPublisher: AnyPublisher<Void, Never> {
        registerExamTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private lazy var resetPlanButton: UIButton = {
        let button = buildButton(title: Attributes.resetPlanText, image: .resetIcon)
        button.addAction(UIAction { [weak self] _ in
            self?.resetPlanTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    private lazy var registerExamButton: UIButton = {
        let button = buildButton(title: Attributes.registerExamText, image: .examRegister)
        button.addAction(UIAction { [weak self] _ in
            self?.registerExamTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .customBlue50
    }

    func configureActions(
        onResetPlan: @escaping () -> Void,
        onRegisterExam: @escaping () -> Void
    ) {
        cancellables.removeAll()
        resetPlanTappedPublisher.sink { onResetPlan() }.store(in: &cancellables)
        registerExamTappedPublisher.sink { onRegisterExam() }.store(in: &cancellables)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    private func buildButton(title: String, image: UIImage?) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePlacement = .top
        config.imagePadding = 4
        config.title = title

        config.titleTextAttributesTransformer = .init { incoming in
            var attrs = incoming
            attrs.font = .systemFont(ofSize: 16, weight: .medium)
            return attrs
        }
        config.baseForegroundColor = .coolNeutral800

        let button = UIButton(configuration: config)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.applyQRIZShadow(radius: 16, color: .coolNeutral300)
        return button
    }
}

// MARK: - Layout Setup

extension QuickActionsCell {
    private func addSubviews() {
        [
            resetPlanButton,
            registerExamButton
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        resetPlanButton.translatesAutoresizingMaskIntoConstraints = false
        registerExamButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            resetPlanButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            resetPlanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            resetPlanButton.widthAnchor.constraint(
                equalTo: registerExamButton.widthAnchor
            ),
            resetPlanButton.heightAnchor.constraint(
                equalTo: resetPlanButton.widthAnchor,
                multiplier: Metric.buttonAspectRatio
            ),

            registerExamButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            registerExamButton.leadingAnchor.constraint(
                equalTo: resetPlanButton.trailingAnchor,
                constant: Metric.horizontalSpacing
            ),
            registerExamButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            registerExamButton.heightAnchor.constraint(
                equalTo: registerExamButton.widthAnchor,
                multiplier: Metric.buttonAspectRatio
            ),
        ])
    }
}
