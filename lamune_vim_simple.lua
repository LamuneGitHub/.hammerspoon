curStates.cursorMode = false
local activeBindings = {}

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정 (Cursor Mode)
local keyMappings = {
    {t="key", from = {{},"u"}, to = {{},"pageup"}},
    {t="key", from = {{},"o"}, to = {{},"pagedown"}},
    {t="key", from = {{},"n"}, to = {{},"home"}},
    {t="key", from = {{},"m"}, to = {{},"end"}},
        --{t="key", from = {{},"h"}, to = {{"cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{},";"}, to = {{"cmd"}, "right"}}, -- end of line

    {t="key", from = {{"shift"},"u"}, to = {{"shift"},"pageup"}},
    {t="key", from = {{"shift"},"o"}, to = {{"shift"},"pagedown"}},
    {t="key", from = {{"shift"},"n"}, to = {{"shift"},"home"}},
    {t="key", from = {{"shift"},"m"}, to = {{"shift"},"end"}},
    --{t="key", from = {{"shift"},"h"}, to = {{"shift","cmd"}, "left"}}, -- beginning of line
    --{t="key", from = {{"shift"},";"}, to = {{"shift","cmd"}, "right"}}, -- end of line


    {t="key", from = {{"cmd"},"u"}, to = {{"cmd"},"pageup"}},
    {t="key", from = {{"cmd"},"o"}, to = {{"cmd"},"pagedown"}},
    {t="key", from = {{"cmd"},"n"}, to = {{"cmd"},"home"}},
    {t="key", from = {{"cmd"},"m"}, to = {{"cmd"},"end"}},

    -------------------------------------------------------------------------
    {t="key", from = {{},"j"}, to = {{},"left"}},
    {t="key", from = {{},"l"}, to = {{},"right"}},
    {t="key", from = {{},"i"}, to = {{},"up"}},
    {t="key", from = {{},"k"}, to = {{},"down"}},
    {t="key", from = {{},"h"}, to = {{"alt"}, "left"}},-- back word
    {t="key", from = {{},";"}, to = {{"alt"}, "right"}},-- forward word 

    {t="key", from = {{"shift"},"j"}, to = {{"shift"},"left"}},
    {t="key", from = {{"shift"},"l"}, to = {{"shift"},"right"}},
    {t="key", from = {{"shift"},"i"}, to = {{"shift"},"up"}},
    {t="key", from = {{"shift"},"k"}, to = {{"shift"},"down"}},
    {t="key", from = {{"shift"},"h"}, to = {{"shift","alt"}, "left"}},-- back word
    {t="key", from = {{"shift"},";"}, to = {{"shift","alt"}, "right"}},-- forward word 

    -------------------------------------------------------------------------
    {t="fnc", from = {{},"p"}, to = function() -- cmd + c
        fastKeyStroke(mod.cmd, "c")
    end},
    {t="fnc", from = {{"cmd"},"p"}, to = function() -- 뒤쪽 복사
        fastKeyStroke({"cmd","shift"}, "right")
        fastKeyStroke(mod.cmd, "c")
    end},
    {t="fnc", from = {{"alt"},"p"}, to = function() -- 앞쪽 복사
        fastKeyStroke({"cmd","shift"}, "left")
        fastKeyStroke(mod.cmd, "c")
    end},
    {t="fnc", from = {{"shift"},"p"}, to = function() -- 한줄 복사
        fastKeyStroke(mod.cmd, "right")
        fastKeyStroke(mod.cmd_and_shift, "left")
        fastKeyStroke(mod.cmd, "c")
    end},

    ------------------------------------------------------------------------
    {t="fnc", from = {{},"["}, to = function() -- cmd + v
        fastKeyStroke(mod.cmd, "v")
    end},
    {t="fnc", from = {{"cmd"},"["}, to = pasteLine },-- 현재 줄에 클립보드 내용 삽입

    ------------------------------------------------------------------------
    {t="key", from = {{},"'"}, to = {{},"delete"}},-- delete ⬅️
    {t="key", from = {{"cmd"},"'"}, to = {{},"forwarddelete"}},-- forward delete ➡️

    ------------------------------------------------------------------------
    {t="fnc", from = {{},"."}, to = function() -- 새로운 라인
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end},
    {t="fnc", from = {{"cmd"},"."}, to = function() -- 새로운 라인 (위쪽)
        fastKeyStroke({}, "up")
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end},
    {t="fnc", from = {{"shift"},"."}, to = duplicateLine },-- 줄 복제

    ------------------------------------------------------------------------
    {t="fnc", from = {{},"/"}, to = deleteLine },-- 한줄 삭제
    {t="fnc", from = {{"shift"},"/"}, to = cutLine },-- 한줄 잘라내기
    

    -- {t="fnc", from = {"cmd","/"}, to = function() -- 한줄 주석
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "home")
        
    --     fastKeyStroke({}, "-")
    --     fastKeyStroke({}, "-")
    --     fastKeyStroke({}, "end")
    --     fastKeyStroke({}, "home")
        
    --     fastKeyStroke({}, "down")
    -- end}, 
    -- {t="fnc", from = {{"cmd","alt"},"/"}, to = function() -- 한줄 주석 해제
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "home")
        
    --     fastKeyStroke({}, "forwarddelete")
    --     fastKeyStroke({}, "forwarddelete")
        
    --     fastKeyStroke({}, "down")
    -- end}, 

    -------------------------------------------------------------------------
    {t="key", from = {{"cmd","alt"},"n"}, to = {{},"0"}},
    {t="key", from = {{"cmd","alt"},"m"}, to = {{},"1"}},
    {t="key", from = {{"cmd","alt"},","}, to = {{},"2"}},
    {t="key", from = {{"cmd","alt"},"."}, to = {{},"3"}},
    {t="key", from = {{"cmd","alt"},"j"}, to = {{},"4"}},
    {t="key", from = {{"cmd","alt"},"k"}, to = {{},"5"}},
    {t="key", from = {{"cmd","alt"},"l"}, to = {{},"6"}},
    {t="key", from = {{"cmd","alt"},"u"}, to = {{},"7"}},
    {t="key", from = {{"cmd","alt"},"i"}, to = {{},"8"}},
    {t="key", from = {{"cmd","alt"},"o"}, to = {{},"9"}},

}

------------------------------------------------------------------------
-- 내부 키 바인딩 활성화 / 비활성화 (다른 모드에 대한 의존성 제거)

local function loadMode()
    loadKeyBinding(keyMappings, activeBindings)
end

local function enterCursorMode()
    curStates.cursorMode = true
    for _, bind in ipairs(activeBindings) do
        bind:enable()
    end
end

local function exitCursorMode()
    curStates.cursorMode = false
    for _, bind in ipairs(activeBindings) do
        bind:disable()
    end
end

------------------------------------------------------------------------
-- ModeManager 등록 ("cursor")

ModeManager.register("cursor", {
    label = "Cursor 🇺🇸 ABC",
    color = RED,
    forceEnglish = true, -- 진입 시 영문 입력기 자동 전환
    onEnter = enterCursorMode,
    onExit = exitCursorMode,
})

------------------------------------------------------------------------
-- 기존 전역 함수 호환 유지 (외부에서 직접 호출 시에도 ModeManager 경유)

function enableCursorMode()
    ModeManager.switch("cursor")
end

function disableCursorMode()
    if ModeManager.isMode("cursor") then
        ModeManager.switch("eng", { force = true })
    else
        exitCursorMode()
    end
end

local function toggleCursorMode()
    ModeManager.toggle("cursor")
end

-------------------------------------------------------------------------
-- 단축키 바인딩 및 초기화

-- (PRE) karabiner에서 capslock을 f13으로 사전 매핑
hs.hotkey.bind({}, "f13", toggleCursorMode)

loadMode()
exitCursorMode()
