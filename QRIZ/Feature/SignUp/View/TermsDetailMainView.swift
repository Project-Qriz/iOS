//
//  TermsDetailMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 5/18/25.
//

import UIKit
import Combine
import PDFKit

final class TermsDetailMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let topMargin: CGFloat = 12.0
        static let dismissButtonLeadingOffset: CGFloat = 18.0
    }
    
    private enum Attributes {
        static let xmark: String = "xmark"
    }
    
    // MARK: - Properties
    
    private let dismissButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    var dismissButtonTappedPublisher: AnyPublisher<Void, Never> {
        dismissButtonTappedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - UI
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image  = UIImage(systemName: Attributes.xmark, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .coolNeutral800
        button.addAction(UIAction { [weak self] _ in
            self?.dismissButtonTappedSubject.send()
        }, for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.backgroundColor = .white
        return pdfView
    }()
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func setupUI() {
        self.backgroundColor = .white
    }
    
    func configPDF(document: PDFDocument) {
        pdfView.document = document
    }
    
    func updateTitle(_ text: String) {
        titleLabel.text = text
    }
}

// MARK: - Layout Setup

extension TermsDetailMainView {
    private func addSubviews() {
        [
            dismissButton,
            titleLabel,
            pdfView
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.topMargin),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.dismissButtonLeadingOffset),
            
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Metric.topMargin),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            pdfView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metric.topMargin),
            pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

