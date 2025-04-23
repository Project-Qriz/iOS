//
//  ConceptPDFMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import UIKit
import PDFKit

final class ConceptPDFMainView: UIView {
    
    // MARK: - Enums
    
    private enum Metric {
        static let horizontalMargin: CGFloat = 18.0
        static let chapterLabelTopOffset: CGFloat = 8.0
        static let pdfViewTopOffset: CGFloat = 6.5
    }
    
    // MARK: - UI
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .coolNeutral800
        return label
    }()
    
    private let chapterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
        self.backgroundColor = .white
    }
    
    func configHeader(subject: String, chapter: String) {
        subjectLabel.text = subject
        chapterLabel.text = chapter
    }
    
    func configPDF(document: PDFDocument) {
        pdfView.document = document
    }
}

// MARK: - Layout Setup

extension ConceptPDFMainView {
    private func addSubviews() {
        [
            subjectLabel,
            chapterLabel,
            pdfView,
        ].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        chapterLabel.translatesAutoresizingMaskIntoConstraints = false
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subjectLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            subjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            chapterLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: Metric.chapterLabelTopOffset),
            chapterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metric.horizontalMargin),
            
            pdfView.topAnchor.constraint(equalTo: chapterLabel.bottomAnchor, constant: Metric.pdfViewTopOffset),
            pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

