//
//  MockDailyResultData.swift
//  QRIZ
//
//  Created by Claude on 12/30/25.
//

import Foundation

enum MockDailyResultData {

    /// 정답 샘플
    static let correctSample = DailyResultDetail(
        skillName: "조인",
        questionText: "다음 요구사항을 만족하는 가장 적절한 SQL문은?",
        questionNum: 2,
        description: """
        ```sql
        [요구사항]
        1. 부서별 사원 수 조회
        2. 사원이 없는 부서도 포함
        3. 부서가 없는 사원도 포함
        4. 부서 이름 기준 오름차순 정렬
        ```
        """,
        option1: "SELECT COALESCE(d.department_name, 'No Department') as dept_name, COUNT(e.employee_id) as emp_count FROM departments d FULL OUTER JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_name ORDER BY dept_name;",
        option2: "SELECT d.department_name, COUNT(e.employee_id) as emp_count FROM departments d LEFT OUTER JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_name ORDER BY d.department_name NULLS LAST;",
        option3: "SELECT NVL(d.department_name, 'No Department') as dept_name, COUNT(e.employee_id) as emp_count FROM departments d FULL OUTER JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_name ORDER BY CASE WHEN d.department_name IS NULL THEN 'No Department' ELSE d.department_name END;",
        option4: "SELECT COALESCE(d.department_name, 'No Department') as dept_name, COUNT(*) as emp_count FROM employees e RIGHT OUTER JOIN departments d ON e.department_id = d.department_id GROUP BY d.department_name ORDER BY dept_name;",
        answer: 3,
        solution: """
        최적의 해결방안 선택 이유:
        1. FULL OUTER JOIN으로 모든 케이스 포함
        2. NVL로 NULL 부서명 처리
        3. COUNT(employee_id)로 정확한 직원 수 계산
        4. CASE 식으로 NULL 정렬 처리
        5. ORDER BY로 정렬 요건 충족
        """,
        checked: 3,
        correction: true,
        testInfo: "Day1",
        skillId: 17,
        title: "2과목",
        keyConcepts: "조인"
    )

    /// 오답 샘플
    static let incorrectSample = DailyResultDetail(
        skillName: "조인",
        questionText: "다음 요구사항을 만족하는 가장 적절한 SQL문은?",
        questionNum: 1,
        description: """
        ```sql
        [요구사항]
        1. 직원의 이름과 부서명 조회
        2. 부서가 없는 직원도 포함
        ```
        """,
        option1: "SELECT e.name, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.department_id;",
        option2: "SELECT e.name, d.department_name FROM employees e LEFT OUTER JOIN departments d ON e.department_id = d.department_id;",
        option3: "SELECT e.name, d.department_name FROM employees e RIGHT OUTER JOIN departments d ON e.department_id = d.department_id;",
        option4: "SELECT e.name, d.department_name FROM employees e FULL OUTER JOIN departments d ON e.department_id = d.department_id;",
        answer: 2,
        solution: """
        최적의 해결방안 선택 이유:
        1. LEFT OUTER JOIN으로 부서가 없는 직원도 포함
        2. INNER JOIN은 부서가 있는 직원만 조회
        3. RIGHT OUTER JOIN은 직원이 없는 부서도 포함되어 요건 불충족
        """,
        checked: 1,
        correction: false,
        testInfo: "Day1",
        skillId: 17,
        title: "2과목",
        keyConcepts: "조인"
    )
}
