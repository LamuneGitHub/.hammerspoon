curStates.cursorMode = false
local activeBindings = {}

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정
-- Key mappings for cursor mode
local keyMappings = {

    {t="key", from = {{},"["}, to = {{},"pageup"}},
    {t="key", from = {{},"'"}, to = {{},"pagedown"}},
    {t="key", from = {{},"u"}, to = {{},"home"}},
    {t="key", from = {{},"o"}, to = {{},"end"}},
    --{t="key", from = {{},"h"}, to = {{"cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{},";"}, to = {{"cmd"}, "right"}}, -- end of line

    {t="key", from = {{"shift"},"["}, to = {{"shift"},"pageup"}},
    {t="key", from = {{"shift"},"'"}, to = {{"shift"},"pagedown"}},
    {t="key", from = {{"shift"},"u"}, to = {{"shift"},"home"}},
    {t="key", from = {{"shift"},"o"}, to = {{"shift"},"end"}},
    --{t="key", from = {{"shift"},"h"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{"shift"},";"}, to = {{"shift","cmd"}, "right"}}, -- end of line

    {t="key", from = {{"cmd"},"["}, to = {{"cmd"},"pageup"}},
    {t="key", from = {{"cmd"},"'"}, to = {{"cmd"},"pagedown"}},
    {t="key", from = {{"cmd"},"u"}, to = {{"cmd"},"home"}},
    {t="key", from = {{"cmd"},"o"}, to = {{"cmd"},"end"}},

    -------------------------------------------------------------------------


    {t="fnc", from = {{},"p"}, to = function() -- ctrl + c
        fastKeyStroke(mod.cmd, "c") 
    end}, 
    {t="fnc", from = {{"shift"},"p"}, to = function() -- ctrl + v 
        fastKeyStroke(mod.cmd, "v") 
    end}, 

    {t="key", from = {{},"]"}, to = {{},"delete"}},         -- delete ⬅️
    {t="key", from = {{},"\\"}, to = {{},"forwarddelete"}},  -- forward delete ➡️
    
    --{t="key", from = {{},"z"}, to = {{"cmd"},"z"}},         -- cmd + z --> 동작안함
    --{t="key", from = {{},"x"}, to = {{"cmd"},"x"}},         -- cmd + z --> 동작안함
    --{t="key", from = {{},"c"}, to = {{"cmd"},"c"}},         -- cmd + z --> 동작안함
    --{t="key", from = {{},"v"}, to = {{"cmd"},"v"}},         -- cmd + z --> 동작안함

    
    ------------------------------------------------------------------------

    
    {t="fnc", from = {{},"."}, to = function() -- 한줄 복사
        fastKeyStroke(mod.cmd, "right") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd, "c") 
    end}, 
    {t="fnc", from = {{"shift"},"."}, to = insert_cur_line},  -- 현재 줄에 클립보드 삽입
    -- cmd . => 숫자 3
    {t="fnc", from = {{"cmd","shift"},"."}, to = function() -- 줄 복제
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd, "right") 
        fastKeyStroke(mod.cmd, "c") 
        fastKeyStroke("cmd", "v")
        fastKeyStroke({}, "home")
    end}, 

    {t="fnc", from = {{"cmd","alt"},"."}, to = function() -- 새로운 라인
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end}, 

-------------------------------------------------------------------------
    {t="fnc", from = {{},"/"}, to = function() -- 한줄 삭제
        fastKeyStroke({}, "end")
        fastKeyStroke({"shift"}, "home")
        fastKeyStroke({"shift"}, "home")
        fastKeyStroke({}, "forwarddelete")
        fastKeyStroke({}, "forwarddelete")
    end}, 
    {t="fnc", from = {{"shift"},"/"}, to = function() -- 한줄 잘라내기
        fastKeyStroke(mod.cmd, "right") 
        fastKeyStroke(mod.cmd_and_shift, "left") 
        fastKeyStroke(mod.cmd, "x")
    end}, 

    {t="fnc", from = {"cmd","/"}, to = function() -- 한줄 주석
        fastKeyStroke({}, "home")
        fastKeyStroke({}, "home")
        
        fastKeyStroke({}, "-")
        fastKeyStroke({}, "-")
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "home")
        
        fastKeyStroke({}, "down")
    end}, 
    {t="fnc", from = {{"cmd","alt"},"/"}, to = function() -- 한줄 주석 해제
        fastKeyStroke({}, "home")
        fastKeyStroke({}, "home")
        
        fastKeyStroke({}, "forwarddelete")
        fastKeyStroke({}, "forwarddelete")
        
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


local function toggleCursorMode()
    print ( "toggleCursorMode"  )
    -- print( curStates.cursorMode )
    disableMode_Keypad()

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


