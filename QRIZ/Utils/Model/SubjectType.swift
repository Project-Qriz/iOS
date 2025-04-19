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
    var conceptItems: [(title: String, url: String)] {
        concepts.compactMap { title in
            guard let url = urlString(for: title) else { return nil }
            return (title: title, url: url)
        }
    }
    
    /// concept에 대한 URL 문자열을 반환해주는 함수힙니다.
    private func urlString(for concept: String) -> String? {
        switch self {
        case .dataModeling:
            return ConceptCategory.DataModeling.from(concept: concept)?.urlString
        case .dataModelAndSQL:
            return ConceptCategory.DataModelAndSQL.from(concept: concept)?.urlString
        case .sqlBasic:
            return ConceptCategory.SQLBasic.from(concept: concept)?.urlString
        case .sqlAdvanced:
            return ConceptCategory.SQLAdvanced.from(concept: concept)?.urlString
        case .sqlCommands:
            return ConceptCategory.SQLCommands.from(concept: concept)?.urlString
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
        case identifer = "식별자"
        
        /// 주어진 concept에 속한 DataModeling 케이스를 찾는 함수입니다.
        static func from(concept: String) -> DataModeling? {
            allCases.first { $0.rawValue == concept }
        }
        
        var urlString: String {
            switch self {
            case .understandOfDataModel:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/fc657024-ec32-46e0-a632-deab073b03ee/%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%AA%A8%EB%8D%B8%EC%9D%98_%EC%9D%B4%ED%95%B4.pdf?table=block&id=14475dc3-4a16-80b0-884d-ee4b05a9e6d7&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=UQjHk5jw0pulUU3rYi3eqc18hZTAU1szrYY_gUdf8so&downloadName=%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%AA%A8%EB%8D%B8%EC%9D%98+%EC%9D%B4%ED%95%B4.pdf"
            case .entity:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/33d70845-00ae-4a8e-a4fa-880aa5844485/%EC%97%94%ED%84%B0%ED%8B%B0.pdf?table=block&id=14475dc3-4a16-8034-935c-e8f0900b93c5&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=byVDDHF0gHe8VHdR8mqdZDD9WX6PsFeSt2-h5IQlEKU&downloadName=%EC%97%94%ED%84%B0%ED%8B%B0.pdf"
            case .attribute:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/25ef9edb-1448-419c-879f-65c273a0a2ca/%EC%86%8D%EC%84%B1.pdf?table=block&id=14475dc3-4a16-8080-ab5d-f34a338cbc4a&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=OAf3LuVmtYKUVH43NalNhlJKWP8D48rxRZ7vkdfTxN4&downloadName=%EC%86%8D%EC%84%B1.pdf"
            case .relation:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/01fb3430-60bf-4497-a5c0-4e9ce405ea47/%EA%B4%80%EA%B3%84.pdf?table=block&id=14475dc3-4a16-809b-a887-d844bf2e4291&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=NId8-ujHOoH_fXcTEZA9O98tLJs6igLnHQ4GlDbVIu8&downloadName=%EA%B4%80%EA%B3%84.pdf"
            case .identifer:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/155a7933-81bb-45f3-9c9a-36133a449aaf/%EC%8B%9D%EB%B3%84%EC%9E%90.pdf?table=block&id=14475dc3-4a16-80c9-9f36-c23b796dbbae&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=U1pSCcR3aPpeVTtise_Yo_qSg9V3HYgG7ZuBvYv6CKY&downloadName=%EC%8B%9D%EB%B3%84%EC%9E%90.pdf"
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
        
        var urlString: String {
            switch self {
            case .normalization:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/3ba65020-0980-489d-96d9-012a8251f392/%EC%A0%95%EA%B7%9C%ED%99%94.pdf?table=block&id=14575dc3-4a16-8020-b306-d9d994c7d593&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=zqhIgD9Cn9asJtRAwUc1BFGB2ISTLb7Ezd_QBe1Ikf4&downloadName=%EC%A0%95%EA%B7%9C%ED%99%94.pdf"
            case .relationAndJoin:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/89c4f73b-afd4-4e42-8a9e-6051d01f626c/%EA%B4%80%EA%B3%84%EC%99%80_%EC%A1%B0%EC%9D%B8%EC%9D%98_%EC%9D%B4%ED%95%B4.pdf?table=block&id=14575dc3-4a16-80c7-a9dd-d12c5bf4d5d2&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=rT4w0nB3XE_qRKeFiT0ex2Y4SFScYI9caZ3o3wcZa-s&downloadName=%EA%B4%80%EA%B3%84%EC%99%80+%EC%A1%B0%EC%9D%B8%EC%9D%98+%EC%9D%B4%ED%95%B4.pdf"
            case .understandOfTransaction:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/bb203f79-8672-4331-9fab-c4773c7deb01/%EB%AA%A8%EB%8D%B8%EC%9D%B4_%ED%91%9C%ED%98%84%ED%95%98%EB%8A%94_%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98%EC%9D%98_%EC%9D%B4%ED%95%B4.pdf?table=block&id=14575dc3-4a16-807e-abab-fef6d3c53e89&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=h-8r4q4AXIW2Dc-2HrGeJ5mOOw1Mq5HAWZafTtQp6sU&downloadName=%EB%AA%A8%EB%8D%B8%EC%9D%B4+%ED%91%9C%ED%98%84%ED%95%98%EB%8A%94+%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98%EC%9D%98+%EC%9D%B4%ED%95%B4.pdf"
            case .understandOfNull:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/a61c8f02-74de-425c-9cbc-39b62e3aa88d/NULL_%EC%86%8D%EC%84%B1%EC%9D%98_%EC%9D%B4%ED%95%B4.pdf?table=block&id=14575dc3-4a16-802e-8813-edf53c52cd16&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=AXPKzNujuGpGat7ijdL_YC2umvqOSDR14vukpcPgmBc&downloadName=NULL+%EC%86%8D%EC%84%B1%EC%9D%98+%EC%9D%B4%ED%95%B4.pdf"
            case .naturalAndSurrogate:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/c87b29a8-894c-4187-8819-f69febcb004c/%EB%B3%B8%EC%A7%88%EC%8B%9D%EB%B3%84%EC%9E%90_vs_%EC%9D%B8%EC%A1%B0%EC%8B%9D%EB%B3%84%EC%9E%90.pdf?table=block&id=14575dc3-4a16-8029-ba7e-dedb9c267f34&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=Ev9FfJICfSoxIT1dDsGZ14cKNBmtHU414KlJx82o7qs&downloadName=%EB%B3%B8%EC%A7%88%EC%8B%9D%EB%B3%84%EC%9E%90+vs+%EC%9D%B8%EC%A1%B0%EC%8B%9D%EB%B3%84%EC%9E%90.pdf"
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
        
        var urlString: String {
            switch self {
            case .rdbms:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/885071ac-10eb-45a7-9dc7-4f40f72f2b2c/%EA%B4%80%EA%B3%84%ED%98%95_%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4_%EA%B0%9C%EC%9A%94.pdf?table=block&id=14275dc3-4a16-8081-9565-e5d3e5952795&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=3Q4l5TOu80ckY6eARQJCBluNAFhjlLCdb3w24A4Mh4c&downloadName=%EA%B4%80%EA%B3%84%ED%98%95+%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4+%EA%B0%9C%EC%9A%94.pdf"
            case .selectQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/cc726578-047f-40dc-a83c-970c62be4a1d/SELECT%EB%AC%B8.pdf?table=block&id=14275dc3-4a16-808d-9ca9-ef4be3aa5a01&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=NcE_7JIz2jQDezKLDyCrL_v7Ri3z9uPre2CwRR365RE&downloadName=SELECT%EB%AC%B8.pdf"
            case .function:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/b8f33afe-6a80-4ba4-bc15-e9bf3ef1c53e/%ED%95%A8%EC%88%98.pdf?table=block&id=14575dc3-4a16-808a-85a2-e637bfdd52c3&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=qPrh8YKc9A-4NwbvpkhZU8hGvqb7ZxvSNb7qOFSpVSo&downloadName=%ED%95%A8%EC%88%98.pdf"
            case .whereQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/c2544532-8c06-4a8c-b182-4762fed4dfdf/WHERE%EC%A0%88.pdf?table=block&id=14175dc3-4a16-8031-97de-fb76b198c051&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=dJ9ZpzajlLTXUxtYdnWjvDl-xNhwoukhf2yg3XNPPvg&downloadName=WHERE%EC%A0%88.pdf"
            case .groupByHavingQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/7567c334-2ed9-45b4-8f48-f6bb3660af8c/GROUP_BY_HAVING_%EC%A0%88.pdf?table=block&id=14175dc3-4a16-8028-ab87-c413cbb1446d&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=ql4sBg3IWSHgGbBM1cmiDFVop2FsdLYZnDmz6a4nY-w&downloadName=GROUP+BY%2C+HAVING+%EC%A0%88.pdf"
            case .orderByQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/53a024ac-735a-4694-8da6-4c5e87d85af7/ORDER_BY%EC%A0%88.pdf?table=block&id=14275dc3-4a16-80ea-8c4e-db5e0e2fecfa&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=jTn-yVASi53T5r9L9meXq3VvjYRTNFlm3KT_zzR7x4s&downloadName=ORDER+BY%EC%A0%88.pdf"
            case .joinQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/5032c976-24cb-4a1d-9503-97ce46b0b256/%EC%A1%B0%EC%9D%B8.pdf?table=block&id=14275dc3-4a16-801b-8060-c7f03e4fa9db&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=U8P53KHpIL3Zy0ok49T-oCNhYhhO7OsJMZvPfw69H-0&downloadName=%EC%A1%B0%EC%9D%B8.pdf"
            case .standardJoin:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/0e2530da-5364-468e-804d-517f0da389cd/%ED%91%9C%EC%A4%80_%EC%A1%B0%EC%9D%B8.pdf?table=block&id=14275dc3-4a16-8027-9a0b-ddd439821627&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=mBNmQJEcFJQ1S8jzflDj_pcjNJYWgzJHFPXdnmAC4eQ&downloadName=%ED%91%9C%EC%A4%80+%EC%A1%B0%EC%9D%B8.pdf"
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
        
        var urlString: String {
            switch self {
            case .subQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/bd731f60-0ad6-4a1a-9d86-6ea7e75c7f45/%EC%84%9C%EB%B8%8C_%EC%BF%BC%EB%A6%AC.pdf?table=block&id=14275dc3-4a16-80e8-a563-f5a1aca88ae5&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=_8_Dq_2ef2Lpfm2XW7ikEX_bRodG5vs3De8qHlcodP4&downloadName=%EC%84%9C%EB%B8%8C+%EC%BF%BC%EB%A6%AC.pdf"
            case .unionOperator:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/718bb0ab-4633-453b-9e65-901d0052c67b/%EC%A7%91%ED%95%A9_%EC%97%B0%EC%82%B0%EC%9E%90.pdf?table=block&id=14275dc3-4a16-8026-a0d7-ee1e8df5c399&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=UbCevdpYBau7SQPX4cAKJ2IxYmx6BgyrKzB9GN2njvU&downloadName=%EC%A7%91%ED%95%A9+%EC%97%B0%EC%82%B0%EC%9E%90.pdf"
            case .groupFunction:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/19ac94c3-28cb-48b4-8e68-858effab465f/%EA%B7%B8%EB%A3%B9_%ED%95%A8%EC%88%98.pdf?table=block&id=14175dc3-4a16-80aa-b946-d47e9ff0d31b&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=DvdIjhDnPX4_bzlj6ISE8AHw_jQBAlNXD3iYQdhA5lM&downloadName=%EA%B7%B8%EB%A3%B9+%ED%95%A8%EC%88%98.pdf"
            case .windowFunction:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/05e73030-92ff-4bae-a805-f19facd0e499/%EC%9C%88%EB%8F%84%EC%9A%B0_%ED%95%A8%EC%88%98.pdf?table=block&id=14275dc3-4a16-8027-b120-cad978c03973&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=EmSonzDMS7QSTO2tjEBVj4bHN_0I4Nbo6T6UlqZyrqI&downloadName=%EC%9C%88%EB%8F%84%EC%9A%B0+%ED%95%A8%EC%88%98.pdf"
            case .topNQuery:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/f3c737b9-a6cf-4701-80b5-77e40dfe3ecf/Top_N_%EC%BF%BC%EB%A6%AC.pdf?table=block&id=14275dc3-4a16-8068-abac-d683c26c8ece&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=w_icEizw_2BuAQULFpMpPYBit8zIZAryAJsyArDaEc4&downloadName=Top+N+%EC%BF%BC%EB%A6%AC.pdf"
            case .hierarchicalQueryAndSelfJoin:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/dd5bcfe4-9f18-4f2f-af81-b1b22b9c0cac/%EA%B3%84%EC%B8%B5%ED%98%95_%EC%A7%88%EC%9D%98%EC%99%80_%EC%85%80%ED%94%84_%EC%A1%B0%EC%9D%B8.pdf?table=block&id=14275dc3-4a16-80c3-9e35-ef129128672f&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=5vokZH2ZzesnhJ2mzV38kDESfqfZ4D2-OCUo2Sg6rZc&downloadName=%EA%B3%84%EC%B8%B5%ED%98%95+%EC%A7%88%EC%9D%98%EC%99%80+%EC%85%80%ED%94%84+%EC%A1%B0%EC%9D%B8.pdf"
            case .pivotAndUnpivot:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/204820c0-1a9d-41af-9dba-29b140b12f6d/PIVOT%EC%A0%88%EA%B3%BC_UNPIVOT%EC%A0%88.pdf?table=block&id=14275dc3-4a16-80fd-93d3-c96a70d452b1&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=FMY-VHBzm2BCH3-mE6BL0oR0fvbncc62yig-5sIbePs&downloadName=PIVOT%EC%A0%88%EA%B3%BC+UNPIVOT%EC%A0%88.pdf"
            case .regularExpression:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/6e65dec5-a9dc-4ea7-a4ea-a203e8a2ecaf/%EC%A0%95%EA%B7%9C_%ED%91%9C%ED%98%84%EC%8B%9D.pdf?table=block&id=14275dc3-4a16-8058-9237-fefa84106345&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=cRtAUX9HRQxo-B2ttIrnj_PT8-Yfxk5poUFeLWD8Jl4&downloadName=%EC%A0%95%EA%B7%9C+%ED%91%9C%ED%98%84%EC%8B%9D.pdf"
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
        
        var urlString: String {
            switch self {
            case .dml:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/90d623d0-bb08-445b-9c85-d18ac4ecae5a/DML.pdf?table=block&id=14475dc3-4a16-807d-89ce-ca7c36601890&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=C_NXr8wF72hpTzFc8pi2rcK83iD3GeH1qCG5x2duDL0&downloadName=DML.pdf"
            case .tcl:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/8d0ff87b-5a42-4718-90e2-3d4ea691db72/TCL.pdf?table=block&id=14475dc3-4a16-8069-94ff-f9293874a2b8&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=ZdIBBXZxnuMjOBUMbnm8crfTRpnQK-b_ia2LiftXCSg&downloadName=TCL.pdf"
            case .ddl:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/ffa913fa-e93b-4511-a8f0-ac7b52b11ea5/DDL.pdf?table=block&id=14175dc3-4a16-8082-9c29-c3e11ac2d7b7&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=hjwdZJMPbjrAbwkBOW-GStgVGHay9uRpqnkexn6PyBI&downloadName=DDL.pdf"
            case .dcl:
                return "https://file.notion.so/f/f/9fbc8c20-b9f9-4780-999a-da78330799e6/20bbd852-46c3-4c30-9393-68ed47cb84d6/DCL.pdf?table=block&id=14475dc3-4a16-80d7-94b5-e7d4eb0633b9&spaceId=9fbc8c20-b9f9-4780-999a-da78330799e6&expirationTimestamp=1745085600000&signature=UOy6uZPYSvrLFzlf9CbVfpeh9kjglCM30ojmprEnRyc&downloadName=DCL.pdf"
            }
        }
    }
}
