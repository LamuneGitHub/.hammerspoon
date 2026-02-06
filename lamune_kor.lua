-------------------------------------------------------------------------
--입력 소스가 변경될 때마다 사용자에게 이를 알리는 기능을 구현합니다.
-- 오른쪽 cmd 더블클릭 = 영문
-- 오른쪽 alt 더블클릭 = 한글 
-- shift + space 한영 전환


-------------------------------------------------------------------------
--• 입력 소스 정의:
--• inputSource 테이블은 영어와 두 가지 한국어 입력 소스의 고유 식별자를 저장합니다.
local inputSource = {
    english = "com.apple.keylayout.ABC",
    korean1 = "com.apple.inputmethod.Korean.2SetKorean",
    korean2 = "com.navilera.inputmethod.NavilIME",
}

--• IM_alert 함수:
--• 현재 입력 소스를 확인하고, 해당 소스에 따라 적절한 언어 표시를 설정합니다.
--• 동일한 입력 소스에서 반복해서 알림을 표시하지 않도록 합니다.
--• 새로운 입력 소스를 확인할 때마다 이전 알림을 닫고 새 알림을 표시합니다.
curStates.language = ""
function IM_alert()
    -- print( "IM_alert" .. tostring(cursorMode))
    -- -- 언어가 변경된 경우는 문자 입력을 위한 경우 이므로 cursor모드를 해제 
    -- !예상과 달리 IM_alert이벤트가 시도때도 없이 호출됨
    -- disableCursorMode()

    local current = hs.keycodes.currentSourceID()
    
    if current == inputSource.korean1 then
        curStates.language = ' 🇰🇷 가나다1 '
    elseif current == inputSource.korean2 then
        curStates.language = ' 🇰🇷 가나다2 '
    elseif current == inputSource.english then
        curStates.language = ' 🇺🇸 ABC '
    else
        curStates.language = current
    end

    -- 현재 상태를 메세지 박스로 출력
    alter_CurStates()
end

--• 입력 소스 변경 감지:
--• 입력 소스가 변경될 때마다 IM_alert 함수를 호출하여 알림을 표시합니다.
hs.keycodes.inputSourceChanged(IM_alert)

-- 영문 입력 상태로 변경
change_eng = function()
    -- 커서모드 해제 
    disableCursorMode()

    -- 영문으로 변경
    hs.keycodes.currentSourceID(inputSource.english)
    curStates.language = ' 🇺🇸 ABC '

    -- bar  -- 영문 상태를 표시
    -- enable_munebar_show(GREEN)

end

-- 커서모드 변경 없이 영문으로 변경
change_eng_withoutCursorModeChange = function()
    hs.keycodes.currentSourceID(inputSource.english)
    curStates.language = ' 🇺🇸 ABC '
end

-- 한글 입력 상태로 변경
change_kor = function()
    -- ! 가끔씩 한글로 바뀌었다고 나오지만 한글로 안바뀌는 경우가 있음... 영문키를 다시 눌러주고 하면 되는것 같기도 하고...
    -- change_eng()

    -- 커서모드 해제
    disableCursorMode()

    -- 한글로 변경
    hs.keycodes.currentSourceID(inputSource.korean1)
    curStates.language = ' 🇰🇷 가나다1 '

    -- bar  -- 한글 상태를 표시
    enable_munebar_show(BLUE)

end

-- 언어를 변경 
local change_lang = function()
    -- print( "change_lang" .. tostring(cursorMode) )
    local current = hs.keycodes.currentSourceID()
    if current == inputSource.korean1 then
        change_eng()
    elseif current == inputSource.korean2 then
        change_eng()
    elseif current == inputSource.english then
        change_kor()
    else
        curStates.language = current
    end
end


-- hs.hotkey.bind({}, "f17", change_eng)
-- hs.hotkey.bind({}, "f18", change_kor)

--------------------------------------------------------------------------------

--hs.keycodes.inputSourceChanged(show_autohide)




-- TODO  임시로 막아 놓음 
-- -- shift + space 
--hs.hotkey.bind({"shift"}, "space", function()
    --toggleCursorMode()
    --change_eng()

    --change_lang()

    -- 페러럴 용 한영키 변경
    --fastKeyStroke({},"F19")
--end)
