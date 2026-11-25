# Hammerspoon 모드 관리자 리팩토링 적용 가이드

## 1. 포함된 파일 목록
아래 파일들을 `~/.hammerspoon/` 디렉토리에 복사(덮어쓰기)한 뒤 Hammerspoon을 리로드하세요.  
*(기존 파일은 적용 전 백업해 두시는 것을 권장합니다.)*

1. **`mode_manager.lua`** *(신규)*: 중앙 모드 관리자 (상태 전환, 이전 모드 자동 종료, 메뉴바 색상 및 알림 통합 처리)
2. **`init.lua`**: `ModeManager` 로드 순서 정리 및 중복 `require` 제거
3. **`lamune_common.lua`**: `BROWN` 색상 추가, `enable_menubar_show` 함수명 정리(기존 `enable_munebar_show` 호환 유지), 모니터 변경 시 `ModeManager.refreshUI()` 연동
4. **`lamune_kor.lua`**: `"eng"`, `"kor"` 모드 등록 및 `inputSourceChanged` 이벤트 충돌 방지 적용
5. **`lamune_vim_simple.lua`**: `"cursor"` 모드 등록 및 타 모드 직접 호출 제거
6. **`lamune_vim_number_keypad.lua`**: `"keypad"` 모드 등록 및 타 모드 직접 호출 제거
7. **`quick_filer.lua`**: `"filer"` 모드 등록 및 `ModeManager.toggle("filer")` 연동

---

## 2. 동작 정책 요약
- **단일 활성 모드 보장**: 어떤 모드로 전환하든 이전 활성 모드의 `onExit()`이 자동으로 먼저 실행됩니다.
- **특수 모드 종료(Toggle OFF) 시 기본 복귀**: 커서/키패드/파일 관리 모드를 토글로 끄면 항상 영문(`eng`) 모드로 복귀합니다.
- **영문 입력기 자동 전환**: `cursor`, `keypad`, `filer` 모드 진입 시 `forceEnglish = true` 옵션에 의해 자동으로 영문(`ABC`) 입력기로 전환됩니다.
- **하위 호환성 유지**: `lamune_modifier.lua` 등 다른 파일에서 호출하는 `change_eng()`, `change_kor()`, `enableCursorMode()`, `disableCursorMode()`, `enableMode_Keypad()`, `disableMode_Keypad()` 전역 함수는 그대로 유지되며 내부적으로 `ModeManager`를 거치도록 연결되어 있습니다.

---

## 3. 향후 새로운 모드 추가 방법
기존 파일들을 수정할 필요 없이 새 파일에서 `ModeManager.register`만 호출하면 됩니다.

```lua
ModeManager.register("my_new_mode", {
    label = "My New Mode",
    color = { red = 0.8, green = 0.2, blue = 0.8 }, -- 보라색 메뉴바
    forceEnglish = true,
    onEnter = function()
        -- 키 바인딩 활성화
    end,
    onExit = function()
        -- 키 바인딩 비활성화 및 리소스 정리
    end,
})

hs.hotkey.bind({"cmd", "ctrl"}, "f14", function()
    ModeManager.toggle("my_new_mode")
end)
```
