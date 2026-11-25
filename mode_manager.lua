-- mode_manager.lua
-- Hammerspoon 중앙 집중식 입력/특수 모드 관리자
-- 모든 모드는 서로 직접 참조하지 않고 이 모듈에만 등록(register) 및 전환(switch/toggle)을 위임합니다.

local M = {}

local modes = {}
local currentMode = nil
local defaultMode = "eng" -- 특수 모드 종료(Toggle OFF) 시 기본 복귀 모드 (옵션 A)
local isTransitioning = false
local transitionTimer = nil
local lastAlertUUID = nil

-- 영문 입력 소스 ID (특수 모드 진입 시 강제 전환용)
local ENGLISH_SOURCE_ID = "com.apple.keylayout.ABC"

-- 전환 중 플래그 설정 (macOS inputSourceChanged 비동기 이벤트 충돌 방지)
local function beginTransition()
    isTransitioning = true
    if transitionTimer then
        transitionTimer:stop()
        transitionTimer = nil
    end
end

local function endTransitionDelayed()
    if transitionTimer then
        transitionTimer:stop()
    end
    transitionTimer = hs.timer.doAfter(0.15, function()
        isTransitioning = false
        transitionTimer = nil
    end)
end

-- 알림 표시 (이전 알림을 닫고 중앙 스타일로 출력)
local function showModeAlert(message, duration)
    if not message or message == "" then return end
    if lastAlertUUID then
        hs.alert.closeSpecific(lastAlertUUID)
        lastAlertUUID = nil
    end
    local style = customStyle or hs.alert.defaultStyle
    lastAlertUUID = hs.alert.show(message, style, duration or 1.0)
end

--- 모드 등록
-- @param id string : 모드 고유 식별자 (예: "eng", "kor", "cursor", "keypad", "filer")
-- @param config table : {
--     label         = string,   -- 상태 표시용 이름
--     color         = table|nil,-- 메뉴바 색상 상수 (nil이면 메뉴바 표시 끄기)
--     forceEnglish  = boolean,  -- 진입 시 영문 입력기 강제 전환 여부
--     alertMessage  = string,   -- 진입 시 커스텀 알림 문구 (생략 시 label 사용)
--     alertDuration = number,   -- 알림 표시 시간(초, 기본 1.0)
--     onEnter       = function, -- 모드 진입 콜백
--     onExit        = function, -- 모드 종료 콜백
-- }
function M.register(id, config)
    modes[id] = {
        id = id,
        label = config.label or id,
        color = config.color,
        forceEnglish = config.forceEnglish or false,
        alertMessage = config.alertMessage,
        alertDuration = config.alertDuration or 1.0,
        onEnter = config.onEnter or function() end,
        onExit = config.onExit or function() end,
    }
end

--- 현재 모드의 메뉴바 UI 갱신 (모니터 변경 이벤트 등에서도 호출)
function M.refreshUI()
    local cfg = currentMode and modes[currentMode]
    if cfg and cfg.color then
        enable_menubar_show(cfg.color)
    else
        disable_menubar_show()
    end
end

--- 지정된 모드로 전환
-- @param targetId string : 전환할 모드 ID
-- @param opts table|nil  : { silent = boolean, force = boolean }
function M.switch(targetId, opts)
    opts = opts or {}
    local target = modes[targetId]
    if not target then
        hs.alert.show("[ModeManager] 등록되지 않은 모드: " .. tostring(targetId))
        return false
    end

    -- 이미 동일한 모드이고 강제 재진입이 아니면 UI만 보정 후 종료
    if currentMode == targetId and not opts.force then
        M.refreshUI()
        return true
    end

    beginTransition()

    -- 1. 이전 모드 종료 (항상 안전하게 호출)
    if currentMode and modes[currentMode] then
        local ok, err = pcall(modes[currentMode].onExit)
        if not ok then
            print(string.format("[ModeManager] onExit 오류 (%s): %s", currentMode, tostring(err)))
        end
    end

    -- 2. 특수 모드인 경우 영문 입력기로 강제 전환
    if target.forceEnglish then
        hs.keycodes.currentSourceID(ENGLISH_SOURCE_ID)
        if curStates then
            curStates.language = " 🇺🇸 ABC "
        end
    end

    -- 3. 현재 모드 상태 갱신
    currentMode = targetId
    if curStates then
        curStates.currentMode = targetId
    end

    -- 4. 새 모드 진입
    local ok, err = pcall(target.onEnter)
    if not ok then
        print(string.format("[ModeManager] onEnter 오류 (%s): %s", targetId, tostring(err)))
    end

    -- 5. 메뉴바 색상 및 알림 통합 처리
    M.refreshUI()

    if not opts.silent then
        local msg = target.alertMessage or target.label
        showModeAlert(msg, target.alertDuration)
    end

    endTransitionDelayed()
    return true
end

--- 모드 토글 (현재 해당 모드이면 기본 모드 'eng'로 복귀)
-- @param targetId string : 토글할 모드 ID
function M.toggle(targetId)
    if currentMode == targetId then
        return M.switch(defaultMode, { force = true })
    else
        return M.switch(targetId)
    end
end

--- 비상 초기화: 등록된 모든 모드를 강제 종료하고 기본 모드('eng')로 복귀
function M.reset()
    beginTransition()
    for id, cfg in pairs(modes) do
        local ok, err = pcall(cfg.onExit)
        if not ok then
            print(string.format("[ModeManager] reset onExit 오류 (%s): %s", id, tostring(err)))
        end
    end
    currentMode = nil
    endTransitionDelayed()
    M.switch(defaultMode, { force = true })
end

--- 현재 활성화된 모드 ID 반환
function M.getCurrentMode()
    return currentMode
end

--- 현재 활성화된 모드 설정 객체 반환
function M.getCurrentModeConfig()
    return currentMode and modes[currentMode] or nil
end

--- 특정 모드 활성화 여부 확인
function M.isMode(id)
    return currentMode == id
end

--- 모드 전환 진행 중 여부 (inputSourceChanged 이벤트 필터링용)
function M.isTransitioning()
    return isTransitioning
end

--- 기본 복귀 모드 변경 (기본값: "eng")
function M.setDefaultMode(id)
    defaultMode = id
end

return M
