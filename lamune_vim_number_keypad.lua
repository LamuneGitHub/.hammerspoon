curStates.keypad_Mode = false
local activeBindings = {}

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정
-- Key mappings for cursor mode
local keyMappings = {

    {t="key", from = {{},"b"}, to = {{},"0"}},
    {t="key", from = {{},"n"}, to = {{},"1"}},
    {t="key", from = {{},"m"}, to = {{},"2"}},
    {t="key", from = {{},","}, to = {{},"3"}},
    {t="key", from = {{},"j"}, to = {{},"4"}},
    {t="key", from = {{},"k"}, to = {{},"5"}},
    {t="key", from = {{},"l"}, to = {{},"6"}},
    {t="key", from = {{},"u"}, to = {{},"7"}},
    {t="key", from = {{},"i"}, to = {{},"8"}},
    {t="key", from = {{},"o"}, to = {{},"9"}},

    {t="key", from = {{},"y"}, to = {{},"+"}},
    {t="key", from = {{},"h"}, to = {{},"-"}},
    {t="key", from = {{},"["}, to = {{},"*"}},
    {t="key", from = {{},"'"}, to = {{},"/"}},

    {t="key", from = {{},";"}, to = {{},"delete"}},         -- delete ⬅️
    {t="key", from = {{},"'"}, to = {{},"forwarddelete"}},  -- forward delete ➡️


    {t="fnc", from = {{},"p"}, to = function() -- ctrl + c
        fastKeyStroke(mod.cmd, "c") 
    end},     
    {t="fnc", from = {{"shift"},"p"}, to = function() -- ctrl + v 
        fastKeyStroke(mod.cmd, "v") 
    end}, 


    {t="key", from = {{"cmd"},"j"}, to = {{},"left"}},
    {t="key", from = {{"cmd"},"l"}, to = {{},"right"}},
    {t="key", from = {{"cmd"},"i"}, to = {{},"up"}},
    {t="key", from = {{"cmd"},"k"}, to = {{},"down"}},

}


------------------------------------------------------------------------
-- vim 모드 토클

local function loadMode()
    -- print ( "loadMode"  )

    loadKeyBinding( keyMappings , activeBindings )

--    table.insert(activeBindings, u_with_other_bind)
--    table.insert(activeBindings, i_with_other_bind)
--    table.insert(activeBindings, o_with_other_bind)

end

-- Function to enable cursor mode key mappings
function enableMode_Keypad()
    curStates.keypad_Mode = true

    enable_munebar_show(GREEN)

    for _, bind in ipairs(activeBindings) do
        bind:enable()
    end   

    -- 영문 입력 모드로 변경
    change_eng_withoutCursorModeChange()
end

-- Function to disable cursor mode key mappings
function disableMode_Keypad()
    curStates.keypad_Mode = false
    
    disable_menubar_show()

    for _, bind in ipairs(activeBindings) do
        bind:disable()
        --bind:delete()
    end
end


local function toggleMode_Keypad()
    print ( "toggleCursorMode"  )
    -- print( curStates.cursorMode )
    disableCursorMode()

    if not curStates.keypad_Mode then
        enableMode_Keypad()
    else
        disableMode_Keypad()
    end

    -- 현재 상태를 메세지 박스로 출력
    alter_CurStates()
end




-------------------------------------------------------------------------
-- vim 키 기능 실행

-- (PRE) karabiner에서 caplock 를 f13로 사전 맵핑 시켜 놓았음 
hs.hotkey.bind({}, "f15", toggleMode_Keypad)
hs.hotkey.bind({"shift"}, "f13", toggleMode_Keypad)

-- Initialize by disabling cursor mode
loadMode()
disableMode_Keypad()


--------------------------------------------------------------------------------

