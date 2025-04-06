//
//  FindIDViewModelTests.swift
//  QRIZTests
//
//  Created by 김세훈 on 3/24/25.
//

import Foundation

import XCTest
import Combine
@testable import QRIZ

final class FindIDViewModelTests: XCTestCase {
    
    private var sut: FindIDViewModel! // System Under Test
    private var mockService: MockAccountRecoveryService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockAccountRecoveryService()
        sut = FindIDViewModel(accountRecoveryService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_이메일텍스트변경시_유효성검사_성공() {
        // given: 필요한 value 세팅
        let inputSubject = PassthroughSubject<FindIDViewModel.Input, Never>()
        let output = sut.transform(input: inputSubject.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "유효한 이메일이면 .isNameValid(true) 이벤트가 발생")
        
        // when: 테스트 코드 실행
        output
            .sink { event in
                switch event {
                case .isNameValid(let isValid):
                    XCTAssertTrue(isValid, "test@naver.com은 유효한 이메일 형식이므로 true")
                    expectation.fulfill() // 충족되는 시점에 호출하여 동작을 수행했음을 알림
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
        
        inputSubject.send(.emailTextChanged("test@naver.com"))
        
        // then: 결과 확인(출력)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_이메일텍스트변경시_유효성검사_실패() {
        // given: 필요한 value 세팅
        let inputSubject = PassthroughSubject<FindIDViewModel.Input, Never>()
        let output = sut.transform(input: inputSubject.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "유효한 이메일이면 .isNameValid(false) 이벤트가 발생")
        
        // when: 테스트 코드 실행
        output
            .sink { event in
                switch event {
                case .isNameValid(let isValid):
                    XCTAssertFalse(isValid, "공백은 유효한 이메일 형식이 아니므로 false")
                    expectation.fulfill() // 충족되는 시점에 호출하여 동작을 수행했음을 알림
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
        
        inputSubject.send(.emailTextChanged(""))
        
        // then: 결과 확인(출력)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_버튼탭시_findID성공시_Alert이동이벤트발생() {
        // given: 필요한 value 세팅
        let inputSubject = PassthroughSubject<FindIDViewModel.Input, Never>()
        let output = sut.transform(input: inputSubject.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "API 호출 성공 시 .navigateToAlerView 이벤트 발생")
        
        // when: 테스트 코드 실행
        // Mock에서 기본적으로 shouldThrowError = false이므로 성공 응답
        output
            .sink { event in
                switch event {
                case .navigateToAlerView:
                    expectation.fulfill()
                case .showErrorAlert(_):
                    XCTFail("성공 시나리오에서 오류 발생은 예상치 않음")
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
        
        inputSubject.send(.emailTextChanged("test@naver.com"))
        inputSubject.send(.buttonTapped)
        
        // then: 결과 확인(출력)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockService.findIDCallCount, 1) // 몇번 호출됐는지 확인
    }
    
    func test_버튼탭시_findID실패시_showErrorAlert이벤트발생() {
        // given: 필요한 value 세팅
        mockService.shouldThrowError = true
        let inputSubject = PassthroughSubject<FindIDViewModel.Input, Never>()
        let output = sut.transform(input: inputSubject.eraseToAnyPublisher())
        let expectation = XCTestExpectation(description: "API 호출 실패 시 .showErrorAlert 이벤트 발생")
        
        // when: 테스트 코드 실행
        output
            .sink { event in
                switch event {
                case .showErrorAlert(let errorMessage):
                    XCTAssertEqual(errorMessage, "테스트 클라이언트 에러")
                    expectation.fulfill()
                case .navigateToAlerView:
                    XCTFail("실패 시나리오에서 성공 이벤트는 발생하지 않아야 함")
                default:
                    break
                }
            }
            .store(in: &self.cancellables)
        
        inputSubject.send(.emailTextChanged("test@naver.com"))
        inputSubject.send(.buttonTapped)
        
        // then: 결과 확인(출력)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockService.findIDCallCount, 1) // 몇번 호출됐는지 확인
    }
    
    func test_버튼탭시_이메일없을때_아무이벤트도발생하지않음() {
        // given: 필요한 value 세팅
        let inputSubject = PassthroughSubject<FindIDViewModel.Input, Never>()
        let output = sut.transform(input: inputSubject.eraseToAnyPublisher())
        let noOutputExpectation = expectation(description: "이메일이 없을 때는 아무 이벤트도 발생하지 않음")
        noOutputExpectation.isInverted = true  // 이벤트가 발생하면 실패하도록 설정

        output
            .sink { _ in
                noOutputExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // when: 테스트 코드 실행(이메일 입력 없이 버튼 탭 이벤트 전송)
        inputSubject.send(.buttonTapped)
        
        // then: 결과 확인(출력)
        wait(for: [noOutputExpectation], timeout: 0.5)
    }
}
