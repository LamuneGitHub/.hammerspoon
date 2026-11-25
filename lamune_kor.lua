-------------------------------------------------------------------------
-- 한/영 입력 모드 정의 및 ModeManager 등록
-- 오른쪽 cmd 더블클릭 = 영문 (change_eng)
-- 오른쪽 alt 더블클릭 = 한글 (change_kor)
-------------------------------------------------------------------------

local inputSource = {
    english = "com.apple.keylayout.ABC",
    korean1 = "com.apple.inputmethod.Korean.2SetKorean",
    korean2 = "com.navilera.inputmethod.NavilIME",
}

-- 저수준 입력 소스 전환 헬퍼 (모드 전환 없이 입력기만 변경)
local function setEnglishRaw()
    hs.keycodes.currentSourceID(inputSource.english)
    curStates.language = " 🇺🇸 ABC "
end

local function setKoreanRaw()
    hs.keycodes.currentSourceID(inputSource.korean1)
    curStates.language = " 🇰🇷 가나다1 "
end

-- -- 기존 코드 하위 호환용 전역 함수 유지
-- change_eng_withoutCursorModeChange = setEnglishRaw
-- change_kor_withoutCursorModeChange = setKoreanRaw

-------------------------------------------------------------------------
-- ModeManager 등록: 영문("eng") / 한글("kor")
-------------------------------------------------------------------------

ModeManager.register("eng", {
    label = "Typing 🇺🇸 ABC",
    color = nil, -- 영문 기본 상태는 메뉴바 색상 OFF
    forceEnglish = false,
    onEnter = function()
        setEnglishRaw()
    end,
    onExit = function()
        -- 별도 정리 작업 없음
    end,
})

ModeManager.register("kor", {
    label = "Typing 🇰🇷 가나다",
    color = BLUE, -- 한글 상태는 파란색 메뉴바 표시
    forceEnglish = false,
    onEnter = function()
        -- macOS 한영 전환 누락 버그 우회용 반복 전환 유지
        setEnglishRaw()
        setKoreanRaw()
        setEnglishRaw()
        setKoreanRaw()
        setEnglishRaw()
        setKoreanRaw()
    end,
    onExit = function()
        -- 별도 정리 작업 없음
    end,
})

-------------------------------------------------------------------------
-- 외부(macOS 시스템 등)에서 입력 소스가 변경되었을 때 감지
-------------------------------------------------------------------------
function IM_alert()
    -- ModeManager가 의도적으로 모드를 전환하는 중이면 무시 (충돌 방지)
    if ModeManager.isTransitioning() then
        return
    end

    -- 특수 모드(cursor, keypad, filer)가 활성화된 상태에서는 무시
    local cur = ModeManager.getCurrentMode()
    if cur ~= "eng" and cur ~= "kor" then
        return
    end

    local current = hs.keycodes.currentSourceID()
    if current == inputSource.korean1 or current == inputSource.korean2 then
        curStates.language = (current == inputSource.korean1) and " 🇰🇷 가나다1 " or " 🇰🇷 가나다2 "
        if cur ~= "kor" then
            ModeManager.switch("kor", { silent = false })
        end
    elseif current == inputSource.english then
        curStates.language = " 🇺🇸 ABC "
        if cur ~= "eng" then
            ModeManager.switch("eng", { silent = false })
        end
    else
        curStates.language = current
    end
end

hs.keycodes.inputSourceChanged(IM_alert)

-------------------------------------------------------------------------
-- 기존 전역 함수 인터페이스 유지 (내부는 모두 ModeManager로 위임)
-------------------------------------------------------------------------

-- 영문 입력 상태로 변경 (다른 모든 특수 모드 자동 종료)
change_eng = function()
    ModeManager.switch("eng", { force = true })
end

-- 한글 입력 상태로 변경 (다른 모든 특수 모드 자동 종료)
change_kor = function()
    ModeManager.switch("kor", { force = true })
end

-- 한/영 토글
local change_lang = function()
    if ModeManager.isMode("kor") then
        change_eng()
    else
        change_kor()
    end
end
