//
//  ConceptPDFMainView.swift
//  QRIZ
//
//  Created by 김세훈 on 4/19/25.
//

import UIKit
import PDFKit

final class ConceptPDFMainView: UIView {
    
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
            subjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            
            chapterLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 8),
            chapterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            
            pdfView.topAnchor.constraint(equalTo: chapterLabel.bottomAnchor, constant: 6.5),
            pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

