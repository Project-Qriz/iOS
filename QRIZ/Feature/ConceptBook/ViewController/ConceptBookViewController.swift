//
//  ConceptBookViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 2/23/25.
//

import UIKit
import Combine

final class ConceptBookViewController: UIViewController {
    
    // MARK: - Enumsc
    
    enum Attributes {
        static let navigationTitle = "개념서"
    }
    
    // MARK: - Properties
    
    let rootView: ConceptBookMainView
    private let conceptBookVM: ConceptBookViewModel
    
    // MARK: - Initialize
    
    init(conceptBookVM: ConceptBookViewModel) {
        self.conceptBookVM = conceptBookVM
        self.rootView = ConceptBookMainView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(title: Attributes.navigationTitle)
        bind()
    }
    
    override func loadView() {
        self.view = rootView
        
    }
    
    // MARK: - Functions
    
    private func bind() {
    }
}
