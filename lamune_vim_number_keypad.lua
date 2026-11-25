curStates.keypad_Mode = false
local activeBindings = {}

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정 (Keypad Mode)
local keyMappings = {
    {t="key", from = {{},"n"}, to = {{},"0"}},
    {t="key", from = {{},"m"}, to = {{},"1"}},
    {t="key", from = {{},","}, to = {{},"2"}},
    {t="key", from = {{},"."}, to = {{},"3"}},
    {t="key", from = {{},"j"}, to = {{},"4"}},
    {t="key", from = {{},"k"}, to = {{},"5"}},
    {t="key", from = {{},"l"}, to = {{},"6"}},
    {t="key", from = {{},"u"}, to = {{},"7"}},
    {t="key", from = {{},"i"}, to = {{},"8"}},
    {t="key", from = {{},"o"}, to = {{},"9"}},

    {t="key", from = {{},"y"}, to = {{"shift"},"="}}, -- +
    {t="key", from = {{},"h"}, to = {{},"-"}},
    {t="key", from = {{},"t"}, to = {{"shift"},"8"}}, -- *
    {t="key", from = {{},"g"}, to = {{},"/"}},

    {t="key", from = {{},"p"}, to = {{},"delete"}},         -- delete ⬅️
    {t="key", from = {{},"["}, to = {{},"forwarddelete"}},  -- forward delete ➡️
    -- {t="key", from = {{},"]"}, to = {{},"="}},

    {t="key", from = {{"cmd"},"j"}, to = {{},"left"}},
    {t="key", from = {{"cmd"},"l"}, to = {{},"right"}},
    {t="key", from = {{"cmd"},"i"}, to = {{},"up"}},
    {t="key", from = {{"cmd"},"k"}, to = {{},"down"}},
}

------------------------------------------------------------------------
-- 내부 키 바인딩 활성화 / 비활성화 (다른 모드에 대한 의존성 제거)

local function loadMode()
    -- 로딩 시 불필요한 등록/해제 방지를 위해 비활성 상태로 생성
    loadKeyBinding(keyMappings, activeBindings, false)
end

local function enterKeypadMode()
    curStates.keypad_Mode = true
    for _, bind in ipairs(activeBindings) do
        bind:enable()
    end
end

local function exitKeypadMode()
    curStates.keypad_Mode = false
    for _, bind in ipairs(activeBindings) do
        bind:disable()
    end
end

------------------------------------------------------------------------
-- ModeManager 등록 ("keypad")

ModeManager.register("keypad", {
    label = "Keypad 🇺🇸 ABC",
    color = GREEN,
    forceEnglish = true, -- 진입 시 영문 입력기 자동 전환
    onEnter = enterKeypadMode,
    onExit = exitKeypadMode,
})

------------------------------------------------------------------------
-- 기존 전역 함수 호환 유지 (외부에서 직접 호출 시에도 ModeManager 경유)

function enableMode_Keypad()
    ModeManager.switch("keypad")
end

function disableMode_Keypad()
    if ModeManager.isMode("keypad") then
        ModeManager.switch("eng", { force = true })
    else
        exitKeypadMode()
    end
end

local function toggleMode_Keypad()
    ModeManager.toggle("keypad")
end

-------------------------------------------------------------------------
-- 단축키 바인딩 및 초기화

-- (PRE) karabiner에서 capslock을 f13으로 사전 매핑
hs.hotkey.bind({"shift"}, "f13", toggleMode_Keypad)
hs.hotkey.bind({}, "f15", toggleMode_Keypad)

loadMode()
curStates.keypad_Mode = false
