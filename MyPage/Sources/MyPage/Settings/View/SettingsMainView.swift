import UIKit
import QRIZUtils
import Combine

final class SettingsMainView: UIView {

    // MARK: - Properties

    private let optionTapSubject = PassthroughSubject<SettingsOption, Never>()

    var optionTapPublisher: AnyPublisher<SettingsOption, Never> {
        optionTapSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    let profileHeaderView = ProfileHeaderView()

    private lazy var optionsVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: makeOptionViews())
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
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

    private func makeOptionViews() -> [SettingsOptionView] {
        return SettingsOption.allCases.map { type in
            let view = SettingsOptionView(title: type.rawValue)
            view.tapGestureEndedPublisher()
                .sink { [weak self] _ in
                    self?.optionTapSubject.send(type)
                }
                .store(in: &view.cancellables)
            return view
        }
    }
}

// MARK: - Layout Setup

extension SettingsMainView {
    private func addSubviews() {
        [
            profileHeaderView,
            optionsVStackView
        ].forEach(addSubview(_:))
    }

    private func setupConstraints() {
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        optionsVStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileHeaderView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 24.0
            ),
            profileHeaderView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            profileHeaderView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),

            optionsVStackView.topAnchor.constraint(
                equalTo: profileHeaderView.bottomAnchor,
                constant: 24.0
            ),
            optionsVStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 18.0
            ),
            optionsVStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -18.0
            ),
        ])
    }
}
