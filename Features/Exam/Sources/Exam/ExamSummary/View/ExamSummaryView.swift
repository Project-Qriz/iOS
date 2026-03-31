import UIKit
import Combine

final class ExamSummaryView: UIView {
    
    // MARK: - Properties
    
    private let beginExamTapSubject = PassthroughSubject<Void, Never>()
    
    var beginExamTapPublisher: AnyPublisher<Void, Never> {
        beginExamTapSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .coolNeutral800
        label.textAlignment = .left
        label.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        let attributedText = NSMutableAttributedString(
            string: "배운 내용을 기반으로\n실제같은 모의고사를 풀어봐요",
            attributes: [.paragraphStyle: paragraphStyle]
        )
        label.attributedText = attributedText
        
        return label
    }()
    
    private let summaryImageView: UIImageView = {
        let imageView = UIImageView(image: .examSummary)
        imageView.layer.shadowColor = UIColor.coolNeutral100.cgColor
        imageView.layer.shadowOpacity = 1
        return imageView
    }()
    
    private let bottomButton: UIButton = {
        let button = UIButton()
        button.setTitle("테스트 시작하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .customBlue500
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        setupUI()
        setupButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods

    private func setupUI() {
        backgroundColor = .customBlue50
    }

    private func setupButtonAction() {
        bottomButton.addAction(UIAction { [unowned self] _ in
            beginExamTapSubject.send()
        }, for: .touchUpInside)
    }
}

// MARK: - Layout Setup

extension ExamSummaryView {
    private func addSubviews() {
        [titleLabel, summaryImageView, bottomButton].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        [titleLabel, summaryImageView, bottomButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            summaryImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            summaryImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            summaryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            summaryImageView.heightAnchor.constraint(equalTo: summaryImageView.widthAnchor, multiplier: 0.88),
            
            bottomButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomButton.leadingAnchor.constraint(equalTo: summaryImageView.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: summaryImageView.trailingAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
