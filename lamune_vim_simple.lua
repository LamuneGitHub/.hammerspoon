curStates.cursorMode = false
local activeBindings = {}

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정
-- Key mappings for cursor mode
local keyMappings = {

    {t="key", from = {{},"y"}, to = {{},"pageup"}},
    {t="key", from = {{},"h"}, to = {{},"pagedown"}},
    {t="key", from = {{},"u"}, to = {{},"home"}},
    {t="key", from = {{},"o"}, to = {{},"end"}},
    --{t="key", from = {{},"h"}, to = {{"cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{},";"}, to = {{"cmd"}, "right"}}, -- end of line

    {t="key", from = {{"shift"},"y"}, to = {{"shift"},"pageup"}},
    {t="key", from = {{"shift"},"h"}, to = {{"shift"},"pagedown"}},
    {t="key", from = {{"shift"},"u"}, to = {{"shift"},"home"}},
    {t="key", from = {{"shift"},"o"}, to = {{"shift"},"end"}},
    --{t="key", from = {{"shift"},"h"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{"shift"},";"}, to = {{"shift","cmd"}, "right"}}, -- end of line

    {t="key", from = {{"cmd"},"y"}, to = {{"cmd"},"pageup"}},
    {t="key", from = {{"cmd"},"h"}, to = {{"cmd"},"pagedown"}},
    {t="key", from = {{"cmd"},"u"}, to = {{"cmd"},"home"}},
    {t="key", from = {{"cmd"},"o"}, to = {{"cmd"},"end"}},

    -------------------------------------------------------------------------



    {t="fnc", from = {{},"p"}, to = function() -- ctrl + v 
        fastKeyStroke(mod.cmd, "v") 
    end}, 

    {t="key", from = {{},"["}, to = {{},"delete"}},         -- delete ⬅️
    {t="key", from = {{},"]"}, to = {{},"forwarddelete"}},  -- forward delete ➡️
    {t="key", from = {{},"'"}, to = {{},"delete"}},         -- delete ⬅️
    --{t="key", from = {{},"'"}, to = {{},"forwarddelete"}},  -- forward delete ➡️
    
    {t="key", from = {{},"z"}, to = {{"cmd"},"z"}},         -- cmd + z
    {t="key", from = {{},"x"}, to = {{"cmd"},"x"}},         -- cmd + z
    {t="key", from = {{},"c"}, to = {{"cmd"},"c"}},         -- cmd + z
    {t="key", from = {{},"v"}, to = {{"cmd"},"v"}},         -- cmd + z

    
    -------------------------------------------------------------------------

    {t="fnc", from = {{},"b"}, to = function() -- 줄 복제
        fastKeyStroke({}, "home")
        fastKeyStroke({"shift"}, "end")
        fastKeyStroke("cmd", "c")
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")

        -- todo 붙여 넣기 하고
        -- 아래로 이동
    end}, 
    {t="fnc", from = {{},"n"}, to = function() -- 새로운 라인
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end}, 
    {t="fnc", from = {{},"m"}, to = function() -- 한줄 복사
        fastKeyStroke(mod.cmd, "right") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd, "c") 
    end}, 
    {t="fnc", from = {{},","}, to = insert_cur_line},  -- 클립보드 현재 줄에 삽입
    {t="fnc", from = {{},"."}, to = function() -- 한줄 잘라내기
        fastKeyStroke(mod.cmd, "right") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd, "x")
    end}, 
    {t="fnc", from = {{},"/"}, to = function() -- 한줄 삭제
        fastKeyStroke({}, "end")
        fastKeyStroke({"shift"}, "home")
        fastKeyStroke({}, "delete")
        fastKeyStroke({}, "delete")
    end}, 


    {t="fnc", from = {mod.cmd,"/"}, to = function() -- 한줄 주석
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "home")
        fastKeyStroke({}, "-")
        fastKeyStroke({}, "-")
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "home")
        fastKeyStroke({}, "down")
    end}, 

    -------------------------------------------------------------------------

    {t="key", from = {{},"j"}, to = {{},"left"}},
    {t="key", from = {{},"l"}, to = {{},"right"}},
    {t="key", from = {{},"i"}, to = {{},"up"}},
    {t="key", from = {{},"k"}, to = {{},"down"}},
    {t="key", from = {{},"h"}, to = {{"alt"}, "left"}}, -- back word
    {t="key", from = {{},";"}, to = {{"alt"}, "right"}}, -- forward word  

    {t="key", from = {{"shift"},"j"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"l"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"i"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"k"}, to = {{"shift"},"down"}},
    {t="key", from = {{"shift"},"h"}, to = {{"shift","alt"}, "left"}}, -- back word
    {t="key", from = {{"shift"},";"}, to = {{"shift","alt"}, "right"}}, -- forward word  

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
    print ( "toggleCursorMode"  )
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

-- (PRE) karabiner에서 caplock 를 f13로 사전 맵핑 시켜 놓았음 
hs.hotkey.bind({}, "f13", toggleCursorMode)

-- Initialize by disabling cursor mode
loadMode()
disableCursorMode()


--------------------------------------------------------------------------------


