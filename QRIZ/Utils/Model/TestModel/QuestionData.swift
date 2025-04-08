//
//  QuestionList.swift
//  QRIZ
//
//  Created by ch on 12/21/24.
//

import Foundation

struct QuestionData {
    var question: String
    var option1: String
    var option2: String
    var option3: String
    var option4: String
    var timeLimit: Int
    var questionNumber: Int
    var selectedOption: Int? = nil
    var description: String? = nil
    var skillId: Int? = nil
    
    func getOptionRawValue(option: Int) -> String {
        switch option {
        case 1:
            return option1
        case 2:
            return option2
        case 3:
            return option3
        case 4:
            return option4
        default:
            print("QuestionData: selected option doesn't exist")
            return ""
        }
    }
    
    static var previewSampleList: [QuestionData] = {
        var list: [QuestionData] = []
        for i in 0..<20 {
            var question: QuestionData
            if i % 3 == 0 {
                question = QuestionData(question: "다음 중 엔터티 분류에 대한 설명으로 가장 올바른 것은?", option1: "기본 엔터티는 항상 발생 엔터티의 부모 엔터티가 된다.", option2: "중심 엔터티는 업무에서 중요한 엔터티만을 의미한다.", option3: "행위 엔터티는 두 개 이상의 엔터티로부터 발생되는 엔터티이다.", option4: "코드 엔터티는 반드시 기본 엔터티여야 한다.", timeLimit: 70, questionNumber: i + 1)
            } else if i % 3 == 1 {
                question = QuestionData(question: "다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?", option1: "트랜잭션을 더 작은 단위로 분할", option2: "트랜잭션의 타임아웃 시간을 늘림", option3: "모든 데이터를 메모리에 로드", option4: "트랜잭션의 격리 수준을 낮춤", timeLimit: 70, questionNumber: i + 1)
            } else {
                question = QuestionData(question: "다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?다음 중 트랜잭션 모델링에서 '긴 트랜잭션(Long Transaction)'을 처리하는 방법으로 가장 적절한 것은?", option1: "트랜잭션을 더 작은 단위로 분할", option2: "트랜잭션의 타임아웃 시간을 늘림", option3: "모든 데이터를 메모리에 로드", option4: "트랜잭션의 격리 수준을 낮춤", timeLimit: 70, questionNumber: i + 1)
            }
            list.append(question)
        }
        return list
    }()
    
    static var dailySampleList: [QuestionData] = {
        var list: [QuestionData] = []
        for i in 0..<6 {
            var question: QuestionData
            if i % 2 == 0 {
                question = QuestionData(question: "다음과 같은 상황에서 적절한 엔터티 도출 방식은?",
                                        option1: """
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """,
                                        option2: """
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """,
                                        option3: """
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """,
                                        option4: """
                                        기본 엔터티: 고객, 상품
                                        중심 엔터티: 주문
                                        행위 엔터티: 주문상품
                                        코드 엔터티: 주문상태
                                        """,
                                        timeLimit: 300,
                                        questionNumber: i + 1,
                                        description: """
                                            [업무상황]
                                            1. 고객이 상품을 주문한다.
                                            2. 한 번의 주문에 여러 상품을 담을 수 있다.
                                            3. 상품의 재고는 실시간으로 관리되어야 한다.
                                            4. 주문 상태는 '주문', '결제', '배송', '완료'로 관리된다.
                                        """,
                                        skillId: 2)
                
            } else {
                question = QuestionData(question: "다음과 같은 데이터에서 필요한 분석을 위한 적절한 윈도우 함수 사용은?",
                                        option1: """
                                            ```sql SELECT p2.PROD_ID, p2.PROD_NAME FROM PRODUCTS p2 WHERE p2.CATEGORY = (     SELECT p1.CATEGORY     FROM PURCHASES pu     JOIN PRODUCTS p1 ON pu.PROD_ID = p1.PROD_ID     WHERE pu.ORDER_DATE = (         SELECT MAX(ORDER_DATE)         FROM PURCHASES     ) ) AND p2.PROD_ID NOT IN (     SELECT PROD_ID     FROM PURCHASES ); ```
                                            """,
                                        option2: """
                                            ```sql SELECT p2.PROD_ID, p2.PROD_NAME FROM PRODUCTS p2 WHERE p2.CATEGORY = (     SELECT p1.CATEGORY     FROM PURCHASES pu     JOIN PRODUCTS p1 ON pu.PROD_ID = p1.PROD_ID     WHERE pu.ORDER_DATE = (         SELECT MAX(ORDER_DATE)         FROM PURCHASES     ) ) AND p2.PROD_ID NOT IN (     SELECT PROD_ID     FROM PURCHASES ); ```
                                            """,
                                        option3: """
                                            ```sql SELECT p2.PROD_ID, p2.PROD_NAME FROM PRODUCTS p2 WHERE p2.CATEGORY = (     SELECT p1.CATEGORY     FROM PURCHASES pu     JOIN PRODUCTS p1 ON pu.PROD_ID = p1.PROD_ID     WHERE pu.ORDER_DATE = (         SELECT MAX(ORDER_DATE)         FROM PURCHASES     ) ) AND p2.PROD_ID NOT IN (     SELECT PROD_ID     FROM PURCHASES ); ```
                                            """,
                                        option4: """
                                            ```sql SELECT p2.PROD_ID, p2.PROD_NAME FROM PRODUCTS p2 WHERE p2.CATEGORY = (     SELECT p1.CATEGORY     FROM PURCHASES pu     JOIN PRODUCTS p1 ON pu.PROD_ID = p1.PROD_ID     WHERE pu.ORDER_DATE = (         SELECT MAX(ORDER_DATE)         FROM PURCHASES     ) ) AND p2.PROD_ID NOT IN (     SELECT PROD_ID     FROM PURCHASES ); ```
                                            """,
                                        timeLimit: 300,
                                        questionNumber: i + 1,
                                        description: """
                                            ```sql [매출데이터] SALES_DATE    AMOUNT 2024-01-01    1000 2024-01-02    1200 2024-01-03    800 2024-01-04    1500 ...  [요구사항] 1. 일자별 매출 금액 2. 전일 대비 증감액 3. 3일 이동평균 4. 연초부터의 누적 매출 ```
                                            """,
                                        skillId: 13)
            }
            list.append(question)
        }
        return list
    }()
}
