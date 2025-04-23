//
//  SubjectType.swift
//  QRIZ
//
//  Created by 김세훈 on 4/15/25.
//

import Foundation

// MARK: - Subject
/// 과목 타입을 정의한 열거형입니다.
/// - 하위 개념으로 `Chapter(SQL 기본, SQL활용 등)`를 가지고 있습니다.
enum Subject: String, CaseIterable {
    case one = "데이터 모델링의 이해"
    case two = "SQL 기본 및 활용"
    
    var chapters: [Chapter] {
        switch self {
        case .one: return [.dataModeling, .dataModelAndSQL]
        case .two: return [.sqlBasic, .sqlAdvanced,.sqlCommands]
        }
    }
}

extension Subject {
    /// 주어진 챕터가 속한 과목을 찾아 반환하는 함수입니다.
    static func from(chapter: Chapter) -> Subject? {
      allCases.first { $0.chapters.contains(chapter) }
    }
}

// MARK: - Chapter
/// 챕터 타입을 정의한 열거형입니다.
/// - 하위 개념으로 `concept(엔터티, 속성 등)`를 가지고 있습니다.
enum Chapter: String, CaseIterable {
    case dataModeling = "데이터 모델링의 이해"
    case dataModelAndSQL = "데이터 모델과 SQL"
    case sqlBasic = "SQL 기본"
    case sqlAdvanced = "SQL 활용"
    case sqlCommands = "관리 구문"
    
    var concepts: [String] {
        switch self {
        case .dataModeling: return ConceptCategory.DataModeling.allCases.map { $0.rawValue }
        case .dataModelAndSQL: return ConceptCategory.DataModelAndSQL.allCases.map { $0.rawValue }
        case .sqlBasic: return ConceptCategory.SQLBasic.allCases.map { $0.rawValue }
        case .sqlAdvanced: return ConceptCategory.SQLAdvanced.allCases.map { $0.rawValue }
        case .sqlCommands: return ConceptCategory.SQLCommands.allCases.map { $0.rawValue }
        }
    }
}

extension Chapter {
    /// 주어진 concept이 속한 Chapter를 찾는 함수입니다.
    static func from(concept: String) -> Chapter? {
      allCases.first { $0.concepts.contains(concept) }
    }
    
    /// 카드에 표시할 이미지
    var assetName: String {
        switch self {
        case .dataModeling:     return "understandingDataModeling"
        case .dataModelAndSQL:  return "dataModelAndSQL"
        case .sqlBasic:         return "sqlBasics"
        case .sqlAdvanced:      return "sqlAdvanced"
        case .sqlCommands:      return "managementStatements"
        }
    }
    
    /// 카드에 표시할 제목
    var cardTitle: String {
        rawValue
    }
    
    /// 카드에 표시할 항목 수
    var cardItemCount: Int {
        concepts.count
    }
    
    /// title과 urlString을 튜플 배열로 반환해주는 프로퍼티입니다.
    var conceptItems: [ConceptItem] {
        concepts.compactMap { title in
            guard let fileName = fileName(for: title) else { return nil }
            return ConceptItem(title: title, fileName: fileName)
        }
    }
    
    /// concept에 대한 파일이름을 반환해주는 함수힙니다.
    private func fileName(for concept: String) -> String? {
        switch self {
        case .dataModeling:
            return ConceptCategory.DataModeling.from(concept: concept)?.fileName
        case .dataModelAndSQL:
            return ConceptCategory.DataModelAndSQL.from(concept: concept)?.fileName
        case .sqlBasic:
            return ConceptCategory.SQLBasic.from(concept: concept)?.fileName
        case .sqlAdvanced:
            return ConceptCategory.SQLAdvanced.from(concept: concept)?.fileName
        case .sqlCommands:
            return ConceptCategory.SQLCommands.from(concept: concept)?.fileName
        }
    }
}

// MARK: - ConceptCategory
/// 개념들을 카테고리별로 그룹화한 열거형입니다.
enum ConceptCategory: CaseIterable {
    enum DataModeling: String, CaseIterable {
        case understandOfDataModel = "데이터 모델의 이해"
        case entity = "엔터티"
        case attribute = "속성"
        case relation = "관계"
        case identifier = "식별자"
        
        /// 주어진 concept에 속한 DataModeling 케이스를 찾는 함수입니다.
        static func from(concept: String) -> DataModeling? {
            allCases.first { $0.rawValue == concept }
        }
        
        var fileName: String {
            switch self {
            case .understandOfDataModel: return "UnderstandOfDataModel"
            case .entity:                return "Entity"
            case .attribute:             return "Attribute"
            case .relation:              return "Relation"
            case .identifier:            return "Identifier"
            }
        }
    }
    
    enum DataModelAndSQL: String, CaseIterable {
        case normalization = "정규화"
        case relationAndJoin = "관계와 조인의 이해"
        case understandOfTransaction = "모델이 표현하는 트랜잭션의 이해"
        case understandOfNull = "NULL 속성의 이해"
        case naturalAndSurrogate = "본질식별자 vs 인조식별자"
        
        /// 주어진 concept에 속한 DataModelAndSQL 케이스를 찾는 함수입니다.
        static func from(concept: String) -> DataModelAndSQL? {
            allCases.first { $0.rawValue == concept }
        }
        
        var fileName: String {
            switch self {
            case .normalization:           return "Normalization"
            case .relationAndJoin:         return "RelationAndJoin"
            case .understandOfTransaction: return "UnderstandOfTransaction"
            case .understandOfNull:        return "UnderstandOfNull"
            case .naturalAndSurrogate:     return "NaturalAndSurrogate"
            }
        }
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
        
        /// 주어진 concept에 속한 SQLBasic 케이스를 찾는 함수입니다.
        static func from(concept: String) -> SQLBasic? {
            allCases.first { $0.rawValue == concept }
        }
        
        var fileName: String {
            switch self {
            case .rdbms:              return "RDBMS"
            case .selectQuery:        return "SelectQuery"
            case .function:           return "Function"
            case .whereQuery:         return "WhereQuery"
            case .groupByHavingQuery: return "GroupByHavingQuery"
            case .orderByQuery:       return "OrderByQuery"
            case .joinQuery:          return "JoinQuery"
            case .standardJoin:       return "StandardJoin"
            }
        }
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
        
        /// 주어진 concept에 속한 SQLAdvanced 케이스를 찾는 함수입니다.
        static func from(concept: String) -> SQLAdvanced? {
            allCases.first { $0.rawValue == concept }
        }
        
        var fileName: String {
            switch self {
            case .subQuery:                   return "SubQuery"
            case .unionOperator:              return "UnionOperator"
            case .groupFunction:              return "GroupFunction"
            case .windowFunction:             return "WindowFunction"
            case .topNQuery:                  return "TopNQuery"
            case .hierarchicalQueryAndSelfJoin: return "HierarchicalQueryAndSelfJoin"
            case .pivotAndUnpivot:            return "PivotAndUnpivot"
            case .regularExpression:          return "RegularExpression"
            }
        }
    }
    
    enum SQLCommands: String, CaseIterable {
        case dml = "DML"
        case tcl = "TCL"
        case ddl = "DDL"
        case dcl = "DCL"
        
        /// 주어진 concept에 속한 SQLCommands 케이스를 찾는 함수입니다.
        static func from(concept: String) -> SQLCommands? {
            allCases.first { $0.rawValue == concept }
        }
        
        var fileName: String {
            switch self {
            case .dml: return "DML"
            case .tcl: return "TCL"
            case .ddl: return "DDL"
            case .dcl: return "DCL"
            }
        }
    }
}
