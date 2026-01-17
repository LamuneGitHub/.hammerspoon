curStates.cursorMode = false
local activeBindings = {}

-------------------------------------------------------------------------
--- 복합키 정의 


-------------------------------------------------------------------------
-- 단일 키 맵핑

-- Key mappings for cursor mode
local keyMappings = {

    {t="key", from = {{},"j"}, to = {{},"left"}},
    {t="key", from = {{},"l"}, to = {{},"right"}},
    {t="key", from = {{},"i"}, to = {{},"up"}},
    {t="key", from = {{},"k"}, to = {{},"down"}},
    {t="key", from = {{},"n"}, to = {{"alt"}, "left"}}, -- back word
    {t="key", from = {{},"m"}, to = {{"alt"}, "right"}}, -- forward word  

    -------------------------------------------------------------------------
    {t="key", from = {{"shift"},"j"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"l"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"i"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"k"}, to = {{"shift"},"down"}},
    {t="key", from = {{"shift"},"n"}, to = {{"shift","alt"}, "left"}}, -- back word
    {t="key", from = {{"shift"},"m"}, to = {{"shift","alt"}, "right"}}, -- forward word  

    -------------------------------------------------------------------------
    {t="key", from = {{},"u"}, to = {{},"pageup"}},
    {t="key", from = {{},"o"}, to = {{},"pagedown"}},
    {t="key", from = {{},"9"}, to = {{},"home"}},
    {t="key", from = {{},"0"}, to = {{},"end"}},
    {t="key", from = {{},"h"}, to = {{"cmd"}, "left"}}, -- beginning of line
    {t="key", from = {{},";"}, to = {{"cmd"}, "right"}}, -- end of line

    {t="key", from = {{"shift"},"u"}, to = {{"shift"},"pageup"}},
    {t="key", from = {{"shift"},"o"}, to = {{"shift"},"pagedown"}},
    {t="key", from = {{"shift"},"9"}, to = {{"shift"},"home"}},
    {t="key", from = {{"shift"},"0"}, to = {{"shift"},"end"}},
    {t="key", from = {{"shift"},"h"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    {t="key", from = {{"shift"},";"}, to = {{"shift","cmd"}, "right"}}, -- end of line

    -------------------------------------------------------------------------
    {t="key", from = {{"cmd"},"n"}, to = {{},"0"}},

    {t="key", from = {{"cmd"},"m"}, to = {{},"1"}},
    {t="key", from = {{"cmd"},","}, to = {{},"2"}},
    {t="key", from = {{"cmd"},"."}, to = {{},"3"}},
    {t="key", from = {{"cmd"},"j"}, to = {{},"4"}},
    {t="key", from = {{"cmd"},"k"}, to = {{},"5"}},
    {t="key", from = {{"cmd"},"l"}, to = {{},"6"}},
    {t="key", from = {{"cmd"},"u"}, to = {{},"7"}},
    {t="key", from = {{"cmd"},"i"}, to = {{},"8"}},
    {t="key", from = {{"cmd"},"o"}, to = {{},"9"}},

}

local function loadMode()
    -- print ( "loadMode"  )

    loadKeyBinding( keyMappings , activeBindings )

    table.insert(activeBindings, u_with_other_bind)
    table.insert(activeBindings, i_with_other_bind)
    table.insert(activeBindings, o_with_other_bind)

end




-------------------------------------------------------------------------
-- 커서 모드 실행/해제/전환

function enableCursorMode()
    curStates.cursorMode = true

    enable_munebar_show(RED)

    for _, bind in ipairs(activeBindings) do
        bind:enable()
    end   

    -- 영문 입력 모드로 변경
    change_eng_withoutCursorModeChange()
end

-- Function to disable cursor mode key mappings
function disableCursorMode()
    curStates.cursorMode = false
    
    disable_menubar_show()

    for _, bind in ipairs(activeBindings) do
        bind:disable()
        --bind:delete()
    end
end

-- Function to toggle cursor mode
local function toggleCursorMode()
    -- print ( "toggleCursorMode"  )
    -- print( curStates.cursorMode )

    if not curStates.cursorMode then
        enableCursorMode()
    else
        disableCursorMode()
    end

    -- 현재 상태를 메세지 박스로 출력
    alter_CurStates()
end

-------------------------------------------------------------------------
-- vim 키 기능 실행

-- (PRE) karabiner에서 caplock 를 f14로 사전 맵핑 시켜 놓았음 
hs.hotkey.bind({}, "f14", toggleCursorMode)

-- Initialize by disabling cursor mode
loadMode()
disableCursorMode()


--------------------------------------------------------------------------------




