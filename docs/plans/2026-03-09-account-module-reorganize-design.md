# Account 모듈 파일/폴더 정리 Design

**Date:** 2026-03-09
**Scope:** Account SPM 모듈 소스 및 테스트 폴더 구조 가독성 개선

## 문제점

1. `SignUp/ViewModel/Common/` — 다른 피처에는 없는 서브폴더로 일관성 깨짐
2. 테스트 파일이 기능별로 묶이지 않고 루트에 나열되어 연관 파일 찾기 불편
3. `Snapshot/` 폴더에 스텁/헬퍼가 혼재하고, `Mocks/`와 역할이 중복

## 결정사항

- **소스**: `Common/` 폴더 제거, 두 파일을 `ViewModel/` 바로 아래로 이동
- **테스트**: 소스 구조와 동일한 기능별 폴더(`Login/`, `SignUp/`, `FindAccount/`) 도입
- **`Mocks/`**: `SnapshotServiceStubs.swift`를 `Mocks/`로 통합
- **`SnapshotTestHelpers.swift`**: 루트로 이동, `Snapshot/` 폴더 삭제
- `View/Components/` 구조 및 파일명 패턴은 변경하지 않음

## 최종 구조

### Sources

```
Sources/Account/
├── Extensions/
│   └── Logger+Account.swift
├── FindAccount/
│   ├── Coordinator/
│   ├── View/Components/
│   ├── ViewController/
│   └── ViewModel/
├── Login/
│   ├── Coordinator/
│   ├── View/Components/
│   ├── ViewController/
│   └── ViewModel/
└── SignUp/
    ├── Coordinator/
    ├── View/Components/
    ├── ViewController/
    └── ViewModel/
        ├── EmailVerificationViewModel.swift  ← Common/ 에서 이동
        ├── SignUpFlowViewModel.swift         ← Common/ 에서 이동
        └── (기존 파일들)
```

### Tests

```
Tests/AccountTests/
├── Login/
│   ├── LoginViewModelTests.swift
│   └── LoginSnapshotTests.swift
├── SignUp/
│   ├── IDInputViewModelTests.swift
│   ├── NameInputViewModelTests.swift
│   ├── PasswordInputViewModelTests.swift
│   ├── TermsAgreementModalViewModelTests.swift
│   └── SignUpSnapshotTests.swift
├── FindAccount/
│   ├── FindIDViewModelTests.swift
│   ├── ResetPasswordViewModelTests.swift
│   └── FindAccountSnapshotTests.swift
├── Mocks/
│   ├── MockAccountRecoveryService.swift
│   ├── MockLoginService.swift
│   ├── MockSignUpService.swift
│   ├── MockSocialLoginService.swift
│   ├── MockUserInfoService.swift
│   └── SnapshotServiceStubs.swift  ← Snapshot/ 에서 이동
├── TestHelpers.swift
└── SnapshotTestHelpers.swift       ← Snapshot/ 에서 이동
```
