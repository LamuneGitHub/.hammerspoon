curStates.cursorMode = false
local activeBindings = {}

-------------------------------------------------------------------------
--- 복합키 정의 

-- bind 'u' +  : 복사 기능 
local u_modal = hs.hotkey.modal.new()

-- + 'u' : 현재 커서위치 줄을 복사하여 붙여넣기
u_modal:bind({}, "u", function() 
    fastKeyStroke(mod.cmd, "right")
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd, "c")

    fastKeyStroke(mod.cmd, "right") 
    fastKeyStroke(mod.empty, "return")

    fastKeyStroke(mod.cmd, "v")
    

    -- hs.timer.usleep(200000) -- 이게 없으면 이상하게도 아래 cmd left 에서 붙여 넣기 했던 내용이 지워진다.
    -- fastKeyStroke(mod.cmd, "left")

    u_modal:exit()
end)

-- + 'd' : 현재 커서위치 단어 선택 후 
u_modal:bind({}, "d", function() 
    fastKeyStroke(mod.alt, "left")
    fastKeyStroke(mod.alt_and_shift, "right") 
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 'e' : 한줄 복사
u_modal:bind({}, "e", function() 
    fastKeyStroke(mod.cmd, "left")
    fastKeyStroke(mod.cmd_and_shift, "right") 
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 'a' : 전체 복사
u_modal:bind({}, "a", function() 
    fastKeyStroke(mod.cmd, "a")
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 'q' : 커서기준 한줄 맨 앞까지 복사  
u_modal:bind({}, "q", function()     
    fastKeyStroke(mod.cmd_and_shift, "left")
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 't' : 커서기준 한줄 맨 뒤까지 복사  
u_modal:bind({}, "t", function()     
    fastKeyStroke(mod.cmd_and_shift, "right")
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 'w' : 커서기준 한단어 앞까지 복사  
u_modal:bind({}, "w", function()     
    fastKeyStroke(mod.alt_and_shift, "left")
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)

-- + 'r' : 커서기준 한단어 맨 뒤까지 복사  
u_modal:bind({}, "r", function()     
    fastKeyStroke(mod.alt_and_shift, "right")
    fastKeyStroke(mod.cmd, "c") 
    u_modal:exit()
end)


local u_with_other_bind = hs.hotkey.new({}, "u",
    function() 
        u_modal:enter() 
    end
):enable()

--table.insert(activeBindings, u_with_other_bind)
-------------------------------------------------------------------------
-- bind 'o' +  : 치환 기능 
local o_modal = hs.hotkey.modal.new()

-- + 'o' : 현재 커서아래 한줄 삽입
o_modal:bind({}, "o", function() 
    fastKeyStroke(mod.cmd, "right")
    fastKeyStroke(mod.empty, "return")

    disableCursorMode()
    o_modal:exit()
end)

-- + 'd' : 현재 커서위치 단어 선택 후 
o_modal:bind({}, "d", function() 
    fastKeyStroke(mod.alt, "left")
    fastKeyStroke(mod.alt_and_shift, "right") 
    disableCursorMode()
    o_modal:exit()
end)

-- + 'e' : 한줄
o_modal:bind({}, "e", function() 
    fastKeyStroke(mod.cmd, "left")
    fastKeyStroke(mod.cmd_and_shift, "right") 
    disableCursorMode()
    o_modal:exit()
end)

-- + 'a' : 전체
o_modal:bind({}, "a", function() 
    fastKeyStroke(mod.cmd, "a")
    disableCursorMode()     
    o_modal:exit()
end)

-- + 'q' : 커서기준 한줄 맨 앞까지 
o_modal:bind({}, "q", function()     
    fastKeyStroke(mod.cmd_and_shift, "left")
    disableCursorMode() 
    o_modal:exit()
end)

-- + 't' : 커서기준 한줄 맨 뒤까지
o_modal:bind({}, "t", function()     
    fastKeyStroke(mod.cmd_and_shift, "right")
    disableCursorMode()
    o_modal:exit()
end)

-- + 'w' : 커서기준 한단어 앞까지 
o_modal:bind({}, "w", function()     
    fastKeyStroke(mod.alt_and_shift, "left")
    disableCursorMode()
    o_modal:exit()
end)

-- + 'r' : 커서기준 한단어 맨 뒤까지 
o_modal:bind({}, "r", function()     
    fastKeyStroke(mod.alt_and_shift, "right")
    disableCursorMode()
    o_modal:exit()
end)


local o_with_other_bind = hs.hotkey.new({}, "o",
    function() 
        o_modal:enter() 
    end
):enable()

--table.insert(activeBindings, o_with_other_bind)

-------------------------------------------------------------------------
-- i  : 삭제 기능

--i + i : 현재 라인 삭제
--i + w : 커서 기준 다음 단어 삭제
--i + b : 커서 기준 이전 단어 삭제
local i_modal = hs.hotkey.modal.new()


-- 한줄 삭제 (잘라내기)
i_modal:bind({}, "i", function() 
    fastKeyStroke(mod.cmd, "right") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    -- fastKeyStroke(mod.cmd_and_shift, "left") 

    fastKeyStroke(mod.cmd, "x") 
    --fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)



-- + 'e' : 현재 커서위치 단어 선택 후 
i_modal:bind({}, "d", function() 
    fastKeyStroke(mod.alt, "left")
    fastKeyStroke(mod.alt_and_shift, "right") 
    fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)

i_modal:bind({}, "u", function() 
    fastKeyStroke(mod.empty, "delete")
    i_modal:exit()
end)
i_modal:bind({}, "o", function() 
    fastKeyStroke(mod.empty, "forwarddelete") 
    i_modal:exit()
end)



-- 한줄 삭제
i_modal:bind({}, "e", function() 
    fastKeyStroke(mod.cmd, "right") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd_and_shift, "left") 

    fastKeyStroke(mod.cmd, "x") 
    fastKeyStroke(mod.empty, "forwarddelete") 
    i_modal:exit()
end)

-- + 'a' : 전체 
i_modal:bind({}, "a", function() 
    fastKeyStroke(mod.cmd, "a")
    fastKeyStroke(mod.empty, "delete")  
    i_modal:exit()
end)



-- + 'q' : 커서기준 한줄 맨 앞까지 
i_modal:bind({}, "q", function()     
    fastKeyStroke(mod.cmd_and_shift, "left")
    fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)

-- + 't' : 커서기준 한줄 맨 뒤까지 
i_modal:bind({}, "t", function()     
    fastKeyStroke(mod.cmd_and_shift, "right")
    fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)

-- + 'w' : 커서기준 한단어 앞까지  
i_modal:bind({}, "w", function()     
    fastKeyStroke(mod.alt_and_shift, "left")
    fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)

-- + 'r' : 커서기준 한단어 맨 뒤까지  
i_modal:bind({}, "r", function()     
    fastKeyStroke(mod.alt_and_shift, "right")
    fastKeyStroke(mod.empty, "delete") 
    i_modal:exit()
end)


local i_with_other_bind = hs.hotkey.new({}, "i", 
    function() 
        i_modal:enter() 
    end
):enable()

--table.insert(activeBindings, i_with_other_bind)




-------------------------------------------------------------------------
-- 단일 키 맵핑

-- Key mappings for cursor mode
local keyMappings = {

    {t="key", from = {{},"s"}, to = {{},"left"}},
    {t="key", from = {{},"f"}, to = {{},"right"}},
    {t="key", from = {{},"e"}, to = {{},"up"}},
    {t="key", from = {{},"d"}, to = {{},"down"}},
    {t="key", from = {{},"q"}, to = {{"cmd"}, "left"}}, -- beginning of line
    {t="key", from = {{},"t"}, to = {{"cmd"}, "right"}}, -- end of line
    {t="key", from = {{},"w"}, to = {{"alt"}, "left"}}, -- back word
    {t="key", from = {{},"r"}, to = {{"alt"}, "right"}}, -- forward word  

    {t="key", from = {{},"h"}, to = {{},"left"}},
    {t="key", from = {{},"l"}, to = {{},"right"}},
    {t="key", from = {{},"k"}, to = {{},"up"}},
    {t="key", from = {{},"j"}, to = {{},"down"}},

    -------------------------------------------------------------------------
    {t="key", from = {{"shift"},"s"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"f"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"e"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"d"}, to = {{"shift"},"down"}},
    {t="key", from = {{"shift"},"q"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    {t="key", from = {{"shift"},"t"}, to = {{"shift","cmd"}, "right"}}, -- end of line
    {t="key", from = {{"shift"},"w"}, to = {{"shift","alt"}, "left"}}, -- back word
    {t="key", from = {{"shift"},"r"}, to = {{"shift","alt"}, "right"}}, -- forward word  

    {t="key", from = {{"shift"},"h"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"l"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"k"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"j"}, to = {{"shift"},"down"}},

    -------------------------------------------------------------------------
    {t="key", from = {{"shift"},"s"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"f"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"e"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"d"}, to = {{"shift"},"down"}},
    {t="key", from = {{"shift"},"q"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    {t="key", from = {{"shift"},"t"}, to = {{"shift","cmd"}, "right"}}, -- end of line
    {t="key", from = {{"shift"},"w"}, to = {{"shift","alt"}, "left"}}, -- back word
    {t="key", from = {{"shift"},"r"}, to = {{"shift","alt"}, "right"}}, -- forward word  

    {t="key", from = {{"shift"},"h"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"l"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"k"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"j"}, to = {{"shift"},"down"}},


    -- {t="key", from = {{"shift"},"h"}, to = {{"alt"},"left"}},
    -- {t="key", from = {{"shift"},"l"}, to = {{"alt"},"right"}},
    -- {t="key", from = {{"shift"},"k"}, to = {{},"pageup"}},
    -- {t="key", from = {{"shift"},"j"}, to = {{},"pagedown"}},
    {t="key", from = {{"cmd"},"h"}, to = {{"cmd"},"left"}},
    {t="key", from = {{"cmd"},"l"}, to = {{"cmd"},"right"}},
    {t="key", from = {{"cmd"},"k"}, to = {{"cmd"},"up"}},
    {t="key", from = {{"cmd"},"j"}, to = {{"cmd"},"down"}},


    {t="key", from = {{},"c"}, to = {{},"pageup"}},
    {t="key", from = {{},"v"}, to = {{},"pagedown"}},
    {t="key", from = {{},"g"}, to = {{},"home"}},
    {t="key", from = {{},"b"}, to = {{},"end"}},
    {t="key", from = {{},"3"}, to = {{},"home"}},
    {t="key", from = {{},"4"}, to = {{},"end"}},


    {t="key", from = {{"shift"},"u"}, to = {{"cmd"},"c"}}, -- 선택부분 복사
    {t="key", from = {{},"p"}, to = {{"cmd"}, "v"}}, -- 붙여 넣기
    {t="fnc", from = {{"shift"},"p"}, to = insert_cur_line }, -- 현재줄 위치에 붙여 넣

    {t="key", from = {{},"y"}, to = {{"cmd"}, "z"}}, -- 되돌리기 


    {t="key", from = {{},"1"}, to = {{},"escape"}},


    -- 마우스 기능
    {t="fnc", from = {{},"n"}, to = leftMouseClick },
    {t="fnc", from = {{},"m"}, to = doubleLeftClick },
    {t="fnc", from = {{},","}, to = rightMouseClick },


    -- 매크로
    {t="fnc", from = {{},"/"}, to = noAct },


    -- 미정의 키 ( ... )
    {t="fnc", from = {{},"a"}, to = noAct },
    {t="fnc", from = {{},"x"}, to = noAct },
    {t="fnc", from = {{},"z"}, to = noAct },
    
    {t="fnc", from = {{},"`"}, to = noAct },
    {t="fnc", from = {{},"2"}, to = noAct },
    {t="fnc", from = {{},"5"}, to = noAct },
    {t="fnc", from = {{},"6"}, to = noAct },
    {t="fnc", from = {{},"7"}, to = noAct },
    {t="fnc", from = {{},"8"}, to = noAct },
    {t="fnc", from = {{},"9"}, to = noAct },
    {t="fnc", from = {{},"0"}, to = noAct },
    {t="fnc", from = {{},"-"}, to = noAct },
    {t="fnc", from = {{},"="}, to = noAct },
    
    {t="fnc", from = {{},"."}, to = noAct },
    {t="fnc", from = {{},";"}, to = noAct },
    {t="fnc", from = {{},"'"}, to = noAct },
    {t="fnc", from = {{},"["}, to = noAct },
    {t="fnc", from = {{},"]"}, to = noAct },

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




