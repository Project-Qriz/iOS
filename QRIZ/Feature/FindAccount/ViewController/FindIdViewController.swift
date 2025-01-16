//
//  FindIdViewController.swift
//  QRIZ
//
//  Created by 김세훈 on 1/17/25.
//

import UIKit
import Combine

final class FindIdViewController: UIViewController {
    
    // MARK: - Enums
    
    private enum Attributes {
        static let navigationTitle: String = "아이디 찾기"
        static let headerTitle: String = "아이디를 잊으셨나요?"
        static let headerDescription: String = "Qriz에 가입했던 이메일을 입력하시면\n아이디를 메일로 보내드립니다."
    }
    
    // MARK: - Properties
    
    private let rootView: FindAccountMainView
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellable: AnyCancellable?
    
    // MARK: - initialize
    
    init() {
        self.rootView = FindAccountMainView(
            title: Attributes.headerTitle,
            description: Attributes.headerDescription
        )
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
