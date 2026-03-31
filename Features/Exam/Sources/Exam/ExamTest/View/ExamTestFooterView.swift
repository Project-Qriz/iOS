import UIKit
import Combine
import DesignSystem
import ExamKit



final class ExamTestFooterView: UIView {

    // MARK: - Metric

    private enum Metric {
        static let top: CGFloat = 17
        static let leading: CGFloat = 18
        static let trailing: CGFloat = -18
        static let width: CGFloat = 90
        static let height: CGFloat = 48
    }
    
    // MARK: - Properties

    private let prevButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let nextButtonTappedSubject = PassthroughSubject<Void, Never>()

    var prevButtonTappedPublisher: AnyPublisher<Void, Never> {
        prevButtonTappedSubject.eraseToAnyPublisher()
    }

    var nextButtonTappedPublisher: AnyPublisher<Void, Never> {
        nextButtonTappedSubject.eraseToAnyPublisher()
    }

    // MARK: - UI

    private let prevButton = TestButton(isPreviousButton: true)
    private let nextButton = TestButton(isPreviousButton: false)
    private let pageIndicatorLabel = TestPageIndicatorLabel()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
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
        backgroundColor = .white
        layer.shadowColor = UIColor.customBlue100.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 16
        layer.borderColor = UIColor.customBlue100.cgColor
        layer.borderWidth = 1
    }

    private func setupButtonAction() {
        prevButton.addAction(UIAction { [weak self] _ in
            self?.prevButtonTappedSubject.send()
        }, for: .touchUpInside)
        
        nextButton.addAction(UIAction { [weak self] _ in
            self?.nextButtonTappedSubject.send()
        }, for: .touchUpInside)
    }

    func updateCurPage(curPage: Int) {
        pageIndicatorLabel.setCurrentPage(curPage)
    }

    func updateTotalPage(totalPage: Int) {
        pageIndicatorLabel.setTotalPage(totalPage)
    }

    func updatePrevButton(isVisible: Bool) {
        prevButton.isHidden = !isVisible
    }

    func updateNextButton(isVisible: Bool, isTextSubmit: Bool) {
        nextButton.isHidden = !isVisible
        nextButton.updateTitle(isTextSubmit ? "제출" : "다음")
    }
}

// MARK: - Layout Setup

extension ExamTestFooterView {

    private func addSubviews() {
        [prevButton, nextButton, pageIndicatorLabel].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        [prevButton, nextButton, pageIndicatorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.leading),
            prevButton.topAnchor.constraint(equalTo: topAnchor, constant: Metric.top),
            prevButton.widthAnchor.constraint(equalToConstant: Metric.width),
            prevButton.heightAnchor.constraint(equalToConstant: Metric.height),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Metric.trailing),
            nextButton.topAnchor.constraint(equalTo: topAnchor, constant: Metric.top),
            nextButton.widthAnchor.constraint(equalToConstant: Metric.width),
            nextButton.heightAnchor.constraint(equalToConstant: Metric.height),

            pageIndicatorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageIndicatorLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
        ])
    }
}
