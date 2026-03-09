# Account 모듈 파일/폴더 정리 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Account SPM 모듈의 소스 및 테스트 폴더 구조를 가독성 있게 재정리한다.

**Architecture:** 소스의 `Common/` 서브폴더를 제거하고, 테스트를 소스 구조와 동일한 기능별 폴더(`Login/`, `SignUp/`, `FindAccount/`)로 재구성한다. `SnapshotServiceStubs.swift`를 `Mocks/`로 통합하고 `SnapshotTestHelpers.swift`를 루트로 이동하여 `Snapshot/` 폴더를 삭제한다.

**Tech Stack:** Swift, Swift Package Manager, git mv (파일 이동 시 히스토리 보존)

---

### Task 1: Source — SignUp/ViewModel/Common/ 제거

**Files:**
- Move: `Account/Sources/Account/SignUp/ViewModel/Common/EmailVerificationViewModel.swift` → `Account/Sources/Account/SignUp/ViewModel/EmailVerificationViewModel.swift`
- Move: `Account/Sources/Account/SignUp/ViewModel/Common/SignUpFlowViewModel.swift` → `Account/Sources/Account/SignUp/ViewModel/SignUpFlowViewModel.swift`
- Delete: `Account/Sources/Account/SignUp/ViewModel/Common/` (폴더)

**Step 1: git mv로 파일 이동**

```bash
cd /Users/hun/iOS
git mv Account/Sources/Account/SignUp/ViewModel/Common/EmailVerificationViewModel.swift \
       Account/Sources/Account/SignUp/ViewModel/EmailVerificationViewModel.swift
git mv Account/Sources/Account/SignUp/ViewModel/Common/SignUpFlowViewModel.swift \
       Account/Sources/Account/SignUp/ViewModel/SignUpFlowViewModel.swift
```

**Step 2: 빌드 확인**

Xcode에서 Account 타겟 빌드 (⌘B). `Common/` 폴더가 없어졌으므로 import 경로 변경은 없음 (SPM은 폴더 구조를 import에 반영하지 않음). 에러 없어야 함.

**Step 3: Commit**

```bash
git commit -m "refactor: SignUp/ViewModel/Common/ 폴더 제거 및 파일 상위 폴더로 이동"
```

---

### Task 2: Tests — Snapshot/ 헬퍼 파일 루트로 이동

**Files:**
- Move: `Account/Tests/AccountTests/Snapshot/SnapshotTestHelpers.swift` → `Account/Tests/AccountTests/SnapshotTestHelpers.swift`
- Move: `Account/Tests/AccountTests/Snapshot/SnapshotServiceStubs.swift` → `Account/Tests/AccountTests/Mocks/SnapshotServiceStubs.swift`

**Step 1: git mv로 파일 이동**

```bash
git mv Account/Tests/AccountTests/Snapshot/SnapshotTestHelpers.swift \
       Account/Tests/AccountTests/SnapshotTestHelpers.swift
git mv Account/Tests/AccountTests/Snapshot/SnapshotServiceStubs.swift \
       Account/Tests/AccountTests/Mocks/SnapshotServiceStubs.swift
```

**Step 2: 빌드 확인**

Xcode에서 AccountTests 빌드. 에러 없어야 함.

**Step 3: Commit**

```bash
git commit -m "refactor: 스냅샷 헬퍼/스텁 파일 위치 정리"
```

---

### Task 3: Tests — Login/ 폴더 구성

**Files:**
- Create dir: `Account/Tests/AccountTests/Login/`
- Move: `Account/Tests/AccountTests/LoginViewModelTests.swift` → `Account/Tests/AccountTests/Login/LoginViewModelTests.swift`
- Move: `Account/Tests/AccountTests/Snapshot/LoginSnapshotTests.swift` → `Account/Tests/AccountTests/Login/LoginSnapshotTests.swift`

**Step 1: 디렉토리 생성 및 git mv**

```bash
mkdir -p Account/Tests/AccountTests/Login
git mv Account/Tests/AccountTests/LoginViewModelTests.swift \
       Account/Tests/AccountTests/Login/LoginViewModelTests.swift
git mv Account/Tests/AccountTests/Snapshot/LoginSnapshotTests.swift \
       Account/Tests/AccountTests/Login/LoginSnapshotTests.swift
```

**Step 2: 빌드 확인**

Xcode에서 AccountTests 빌드. 에러 없어야 함.

**Step 3: Commit**

```bash
git commit -m "refactor: 테스트 Login/ 폴더 구성"
```

---

### Task 4: Tests — SignUp/ 폴더 구성

**Files:**
- Create dir: `Account/Tests/AccountTests/SignUp/`
- Move: `Account/Tests/AccountTests/IDInputViewModelTests.swift` → `Account/Tests/AccountTests/SignUp/`
- Move: `Account/Tests/AccountTests/NameInputViewModelTests.swift` → `Account/Tests/AccountTests/SignUp/`
- Move: `Account/Tests/AccountTests/PasswordInputViewModelTests.swift` → `Account/Tests/AccountTests/SignUp/`
- Move: `Account/Tests/AccountTests/TermsAgreementModalViewModelTests.swift` → `Account/Tests/AccountTests/SignUp/`
- Move: `Account/Tests/AccountTests/Snapshot/SignUpSnapshotTests.swift` → `Account/Tests/AccountTests/SignUp/`

**Step 1: 디렉토리 생성 및 git mv**

```bash
mkdir -p Account/Tests/AccountTests/SignUp
git mv Account/Tests/AccountTests/IDInputViewModelTests.swift \
       Account/Tests/AccountTests/SignUp/IDInputViewModelTests.swift
git mv Account/Tests/AccountTests/NameInputViewModelTests.swift \
       Account/Tests/AccountTests/SignUp/NameInputViewModelTests.swift
git mv Account/Tests/AccountTests/PasswordInputViewModelTests.swift \
       Account/Tests/AccountTests/SignUp/PasswordInputViewModelTests.swift
git mv Account/Tests/AccountTests/TermsAgreementModalViewModelTests.swift \
       Account/Tests/AccountTests/SignUp/TermsAgreementModalViewModelTests.swift
git mv Account/Tests/AccountTests/Snapshot/SignUpSnapshotTests.swift \
       Account/Tests/AccountTests/SignUp/SignUpSnapshotTests.swift
```

**Step 2: 빌드 확인**

Xcode에서 AccountTests 빌드. 에러 없어야 함.

**Step 3: Commit**

```bash
git commit -m "refactor: 테스트 SignUp/ 폴더 구성"
```

---

### Task 5: Tests — FindAccount/ 폴더 구성 + Snapshot/ 폴더 삭제

**Files:**
- Create dir: `Account/Tests/AccountTests/FindAccount/`
- Move: `Account/Tests/AccountTests/FindIDViewModelTests.swift` → `Account/Tests/AccountTests/FindAccount/`
- Move: `Account/Tests/AccountTests/ResetPasswordViewModelTests.swift` → `Account/Tests/AccountTests/FindAccount/`
- Move: `Account/Tests/AccountTests/Snapshot/FindAccountSnapshotTests.swift` → `Account/Tests/AccountTests/FindAccount/`
- Delete: `Account/Tests/AccountTests/Snapshot/` (비어있으므로 삭제)

**Step 1: 디렉토리 생성 및 git mv**

```bash
mkdir -p Account/Tests/AccountTests/FindAccount
git mv Account/Tests/AccountTests/FindIDViewModelTests.swift \
       Account/Tests/AccountTests/FindAccount/FindIDViewModelTests.swift
git mv Account/Tests/AccountTests/ResetPasswordViewModelTests.swift \
       Account/Tests/AccountTests/FindAccount/ResetPasswordViewModelTests.swift
git mv Account/Tests/AccountTests/Snapshot/FindAccountSnapshotTests.swift \
       Account/Tests/AccountTests/FindAccount/FindAccountSnapshotTests.swift
```

**Step 2: Snapshot/ 폴더가 비었는지 확인 후 삭제**

```bash
ls Account/Tests/AccountTests/Snapshot/
# 출력 없어야 함 (비어있어야 함)
rmdir Account/Tests/AccountTests/Snapshot/
```

**Step 3: 빌드 확인**

Xcode에서 AccountTests 빌드. 에러 없어야 함.

**Step 4: Commit**

```bash
git commit -m "refactor: 테스트 FindAccount/ 폴더 구성 및 Snapshot/ 폴더 제거"
```
