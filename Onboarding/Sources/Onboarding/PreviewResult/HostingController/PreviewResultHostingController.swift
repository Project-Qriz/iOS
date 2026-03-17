import UIKit
import SwiftUI
import Combine

final class PreviewResultHostingController: UIHostingController<PreviewResultView> {
    private let viewModel: PreviewResultViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(viewModel: PreviewResultViewModel) {
        self.viewModel = viewModel
        super.init(rootView: PreviewResultView(
            previewScoresData: viewModel.previewScoresData,
            previewConceptsData: viewModel.previewConceptsData
        ))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        viewModel.onViewDidLoad()

        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] msg in
                guard let self else { return }
                let alert = UIAlertController(title: "오류", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.viewModel.errorMessage = nil
                })
                self.present(alert, animated: true)
            }
            .store(in: &subscriptions)
    }

    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "시험 결과"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .coolNeutral700
        navigationItem.titleView = titleLabel

        let xmarkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let xmark = UIImage(systemName: "xmark")?.withTintColor(.coolNeutral800, renderingMode: .alwaysOriginal)
        xmarkButton.setImage(xmark, for: .normal)
        xmarkButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: xmarkButton)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }
}
