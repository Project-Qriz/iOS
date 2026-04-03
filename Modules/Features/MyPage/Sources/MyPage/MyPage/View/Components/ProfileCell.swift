import UIKit
import DesignSystem
import Combine

final class ProfileCell: UICollectionViewCell {

    // MARK: - Enums

    private enum Metric {
        static let spacing: CGFloat = 12.0
    }

    private enum Attributes {
        static let chevron: String = "chevron.right"
    }

    // MARK: - Properties

    private let tapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()

    private lazy var chevronButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: Attributes.chevron, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        button.isUserInteractionEnabled = false
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, chevronButton])
        stackView.axis = .horizontal
        stackView.spacing = Metric.spacing
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
        addTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .customBlue50
    }

    func configure(with userName: String) {
        userNameLabel.text = userName
    }

    func onTap(_ action: @escaping () -> Void) {
        cancellables.removeAll()
        tapPublisher
            .sink { action() }
            .store(in: &cancellables)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        tapSubject.send()
    }
}

// MARK: - Layout Setup

extension ProfileCell {
    private func addSubviews() {
        [
            stackView
        ].forEach(contentView.addSubview(_:))
    }

    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
