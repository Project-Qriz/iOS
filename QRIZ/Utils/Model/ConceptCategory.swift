//
//  TotalConcept.swift
//  QRIZ
//
//  Created by ch on 1/18/25.
//

import Foundation

enum ConceptCategory: CaseIterable {
    
    static func getConceptList<T: CaseIterable & RawRepresentable>(for category: T.Type) -> [String] where T.RawValue == String {
        var arr: [String] = []
        for elem in category.allCases {
            arr.append(elem.rawValue)
        }
        return arr
    }
    
    static func getAllConceptList() -> [[String]] {
        var arr: [[String]] = []
        arr.append(getConceptList(for: DataModeling.self))
        arr.append(getConceptList(for: DataModelAndSQL.self))
        arr.append(getConceptList(for: SQLBasic.self))
        arr.append(getConceptList(for: SQLAdvanced.self))
        arr.append(getConceptList(for: SQLCommands.self))
        return arr
    }
    
    enum DataModeling: String, CaseIterable {
        case understandOfDataModel = "데이터 모델의 이해"
        case entity = "엔터티"
        case attribute = "속성"
        case relation = "관계"
        case identifer = "식별자"
    }
    
    enum DataModelAndSQL: String, CaseIterable {
        case normalization = "정규화"
        case relationAndJoin = "관계와 조인의 이해"
        case understandOfTransaction = "모델이 표현하는 트랜잭션의 이해"
        case understandOfNull = "NULL 속성의 이해"
        case naturalAndSurrogate = "본질식별자 vs 인조식별자"
    }
    
    enum SQLBasic: String, CaseIterable {
        case rdbms = "관계형 데이터베이스 개요"
        case selectQuery = "SELECT문"
        case function = "함수"
        case whereQuery = "WHERE절"
        case groupByHavingQuery = "GROUP BY, HAVING절"
        case orderByQuery = "ORDER BY절"
        case joinQuery = "조인"
        case standardJoin = "표준 조인"
    }
    
    enum SQLAdvanced: String, CaseIterable {
        case subQuery = "서브 쿼리"
        case unionOperator = "집합 연산자"
        case groupFunction = "그룹 함수"
        case windowFunction = "윈도우 함수"
        case topNQuery = "Top N 쿼리"
        case hierarchicalQueryAndSelfJoin = "계층형 질의와 셀프 조인"
        case pivotAndUnpivot = "PIVOT절과 UNPIVOT절"
        case regularExpression = "정규 표현식"
    }
    
    enum SQLCommands: String, CaseIterable {
        case dml = "DML"
        case tcl = "TCL"
        case ddl = "DDL"
        case dcl = "DCL"
    }
}
