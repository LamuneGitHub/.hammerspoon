------------------------------------------------------------------
-- 로깅 레벨 
-- •	debug: 디버깅용 세부 로그를 출력합니다.
-- •	info: 일반적인 정보성 메시지를 출력합니다.
-- •	warning: 경고 메시지만 출력합니다.
-- •	error: 에러 메시지만 출력합니다.
-- •	nothing: 모든 로그 출력을 끕니다.

-- 전역 로깅 레벨 셋팅
hs.logger.defaultLogLevel = "error"

-- hs.hotkey 모듈의 로깅 비활성화
hs.hotkey.setLogLevel("nothing")


--local eventtap = require("hs.eventtap")
--local hyper = {"fn", "f6"}  -- Fn+F6 감지 어려움, F18 등 대체 추천
--hs.hotkey.bind({}, "F18", function()  -- Karabiner로 Fn+F6 → F18 매핑 후
  --hs.caffeinate.sleepDisplay()
--end)

------------------------------------------------------------------
-- Common 전역변수 정의

-- 현재의 상태를 저장할 구조체
curStates = {}

-- curStates의 상태값을 이용하여 상태값 메세지를 반환
getMsg_CurStates = function()

    local cursorMode = 'Typing'
    if curStates.cursorMode == true then
        cursorMode = 'Cursor'
    end

    return cursorMode .. ' ' .. curStates.language
end

-- 현재 상태를 메세지 박스로 출력
alter_CurStates = function()
    -- 메시지 박스 위치가 변경되지 않도록 처리.

    if hs.keycodes.currentSourceID() == curStates.last_alerted_IM_ID then return end

    hs.alert.closeSpecific(curStates.last_IM_alert_uuid)
    curStates.last_IM_alert_uuid = hs.alert.show(getMsg_CurStates(), customStyle, 1)
    -- curStates.last_IM_alert_uuid = hs.alert.show(curStates.language, customStyle, 1)
    curStates.last_alerted_IM_ID = hs.keycodes.currentSourceID()
end

------------------------------------------------------------------
-- Common 상수 정의

mod = {
    empty = {},
    shift = {"shift"},
    alt = {"alt"},
    cmd = {"cmd"},
    ctrl = {"ctrl"},
    cmd_and_shift = {"cmd", "shift"},
    alt_and_shift = {"alt", "shift"},
    ctrl_and_shift = {"ctrl", "shift"},
    cmd_and_alt = {"cmd", "alt"},
    ctrl_and_alt = {"ctrl", "alt"},
    cmd_and_ctrl = {"cmd", "ctrl"},
}


------------------------------------------------------------------
-- Common 함수 정의


-- 문자열이 포함되어 있는지 여부 확인
function containsString(url, searchString)
    if string.find(url, searchString) then
        return true  -- 문자열이 포함되어 있으면 true 반환
    else
        return false -- 문자열이 없으면 false 반환
    end
end


-- 테이블의 속성 내용을 print 
function printTable(tbl)
    local msg = 'Attr: '
    for key, value in pairs(tbl) do
        if value then
            msg = msg .. ',' .. key .. ' = ' .. tostring(value)
        end
    end
    print ( msg )

    -- table.insert(tbl, "value") 로 입력한 내용 출력
    if #tbl > 0 then
        print ("Item: " .. table.concat(tbl, ", ") )
    end
end

-- 키 할당이 안된 키 호출 시 실행
noAct = function()
    return 
end


-- 키를 빠르게 눌렀다 떼기
fastKeyStroke = function(modifiers, character , delayTime)
    -- default value
    delayTime = delayTime or 0

    hs.eventtap.event.newKeyEvent(modifiers, string.lower(character), true):post()
    if delayTime >= 0 then  
        hs.timer.usleep(delayTime *1000000)
    end
    hs.eventtap.event.newKeyEvent(modifiers, string.lower(character), false):post()
end

-- 1초 딜레이 
-- 사용예 
--delay1s(function()
    --hs.alert.show("1초 지연 후 실행!")
    --hs.eventtap.keyStroke({}, 'return')
--end)
function delay(callback, delay)
    if delay == nil then delay = 0.1 end

    return hs.timer.doAfter(delay, callback)
end

-- 0.1초 딜레이 후 엔터 입력
function delayEnter()
    delay(function()
        fastKeyStroke(mod.empty , "return")
    end)
end
-- 0.5초 딜레이 후 엔터 입력
function delayEnter2()
    delay(function()
        fastKeyStroke(mod.empty , "return")
    end, 1)
end




------------------------------------------------------------------
------------------------------------------------------------------
-- 키 바인딩 설정tbl 에 따라 키 맵핑
function loadKeyBinding( configTbl , historyTbl )
    historyTbl = historyTbl or nil
    -- print (historyTbl)

    for _, mapping in ipairs(configTbl) do
        local from = mapping.from
        local to = mapping.to
        local t = mapping.t

        --print ( table.concat(mapping, ", ")  )

        local bind
        if t == "key" then  
            bind = hs.hotkey.bind(from[1],from[2], 
                function() fastKeyStroke(to[1], to[2]) end,
                nil,
                function() fastKeyStroke(to[1], to[2]) end
                )
        elseif t == "fnc" then 
            bind = hs.hotkey.bind(from[1],from[2], to)
        elseif t == "app" then 
            bind = hs.hotkey.bind(from[1], from[2], function()
                toggleApplication(to)
            end)
        end 

        if historyTbl ~= nil  then
            table.insert(historyTbl, bind)
        end
    end
end



------------------------------------------------------------------
-- (Common 디자인) 

--메세지 박스 ui 디자인 정의
customStyle = hs.alert.defaultStyle
customStyle.fillColor = { white = 0, alpha = 0.5 }
customStyle.strokeColor = { alpha = 0 }
customStyle.textColor = { white = 0.75, alpha = 0.75 }
customStyle.textSize = 30
customStyle.fadeOutDuration = 0.1


------------------------------------------------------------------
-- (알림) 메뉴바 색상을 바꿔서 모드 바뀜을 알려주는 기능
-- enable_green_munebar_show , disable_green_menubar_show 함수 호출을 이용해 기능을 사용

local boxes = {}
local box_height = 23
local box_alpha = 0.45
GREEN = {red = 0, green = 1, blue = 0}
RED = {red = 1, green = 0, blue = 0}
BLUE = {red = 0, green = 0, blue = 1}

local screenCount = #hs.screen.allScreens()

-- 메뉴바 표시
function enable_munebar_show(color)

    -- 기존의 박스가 있으면 모두 삭제
    disable_menubar_show()

    reset_boxes()
    hs.fnutils.each(hs.screen.allScreens(), function(scr)
        local frame = scr:fullFrame()

        local box = newBox() -- 상단 박스
        draw_rectangle(box, frame.x, frame.y, frame.w, box_height, color)
        table.insert(boxes, box)

        local box2 = newBox() -- 하단 박스
        draw_rectangle(box2, frame.x, frame.y + frame.h - 10, frame.w, box_height, color)
        table.insert(boxes, box2)
    end)
end

-- 녹색 메뉴바 안보이게 
function disable_menubar_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
end

function reset_boxes()
    boxes = {}
end

function draw_rectangle(target_draw, x, y, width, height, fill_color)
  -- 그릴 영역 크기를 잡는다
  target_draw:setSize(hs.geometry.rect(x, y, width, height))
  -- 그릴 영역의 위치를 잡는다
  target_draw:setTopLeft(hs.geometry.point(x, y))

  target_draw:setFillColor(fill_color)
  target_draw:setFill(true)
  target_draw:setAlpha(box_alpha)
  target_draw:setLevel(hs.drawing.windowLevels.overlay)
  target_draw:setStroke(false)
  target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
  target_draw:show()
end

-- 스크린에 변동 사항이 생긴 경우 재 계산 처리
function change_menubar_color()
    disable_green_menubar_show()
end

function handleScreenEvent()
    -- hs.alert.show('모니터 수 변경')
    change_menubar_color() 
    -- local screens = hs.screen.allScreens()
    -- if not (#screens == screenCount) then
    --     screenCount = #screens
    --     show_autohide()
    -- end
end
hs.screen.watcher.new(handleScreenEvent):start()
hs.screen.watcher.newWithActiveScreen(handleScreenEvent):start()

------------------------------------------------------------------

--- 1. 현재 포커스된 창의 이름을 반환하는 함수
function getFocusedWindowTitle()
    local win = hs.window.focusedWindow()
    if win then
        local title = win:title()
        local appName = win:application():name()
        
        -- 콘솔(Console)에 앱 이름과 창 제목 출력
        print(string.format("현재 앱: %s | 창 제목: %s", appName, title))
        
        -- 필요에 따라 title 또는 appName을 반환할 수 있습니다.
        return title
    else
        print("포커스된 창이 없습니다.")
        return nil
    end
end

--- 2. 특정 이름(창 제목 또는 앱 이름)을 가진 창으로 포커스를 변경하는 함수
function focusWindowByName(targetName)
    local windows = hs.window.allWindows()
    
    for _, win in ipairs(windows) do
        local title = win:title()
        local app = win:application()
        local appName = app and app:name() or "UnknownApp"
        
        -- 창 제목이나 앱 이름에 targetName이 포함되어 있는지 확인 (부분 일치 검색)
        if (title and title:find(targetName, 1, true)) or (appName and appName:find(targetName, 1, true)) then
            win:focus()
            print(string.format("포커스 이동 성공 -> 앱: %s | 창 제목: %s", appName, title))
            return true
        end
    end
    
    print("일치하는 창을 찾지 못했습니다: " .. targetName)
    return false
end

-- ==========================================
-- 사용 예시 (단축키 바인딩)
-- ==========================================
-- 1. 현재 포커스된 창의 이름을 콘솔에 출력
-- hs.hotkey.bind({"cmd", "control"}, "1", function()
--     getFocusedWindowTitle()
-- end)
-- -- 2. 지정한 이름의 창으로 포커스 이동
-- hs.hotkey.bind({"cmd", "control"}, "2", function()
--     focusWindowByName("Google Chrome") -- 원하시는 창 이름이나 앱 이름으로 변경 가능합니다.
-- end)

--- 3. 앱 이름(appName)과 창 제목(title)을 모두 활용하여 포커스하는 업그레이드 함수
-- @param targetAppName string|nil : 찾을 앱 이름 (nil이면 무시)
-- @param targetTitle string|nil   : 찾을 창 제목 (nil이면 무시)
function focusWindowByAppAndTitle(targetAppName, targetTitle)
    local windows = hs.window.allWindows()
    
    for _, win in ipairs(windows) do
        local app = win:application()
        local appName = app and app:name() or ""
        local title = win:title() or ""
        
        -- 조건 일치 여부 확인 플래그
        local isAppMatch = true
        local isTitleMatch = true
        
        -- targetAppName이 지정된 경우, 앱 이름이 포함되어 있는지 확인 (대소문자 무시 검색 가능)
        if targetAppName and targetAppName ~= "" then
            if not appName:lower():find(targetAppName:lower(), 1, true) then
                isAppMatch = false
            end
        end
        
        -- targetTitle이 지정된 경우, 창 제목이 포함되어 있는지 확인
        if targetTitle and targetTitle ~= "" then
            if not title:lower():find(targetTitle:lower(), 1, true) then
                isTitleMatch = false
            end
        end
        
        -- 앱 이름과 창 제목 조건이 모두 부합하면 포커스 이동
        if isAppMatch and isTitleMatch then
            win:focus()
            print(string.format("포커스 이동 성공 -> 앱: '%s' | 창 제목: '%s'", appName, title))
            hs.alert.show(string.format("[%s] 창 포커스!", appName))
            return true
        end
    end
    
    print(string.format("일치하는 창을 찾지 못했습니다. (앱: %s, 제목: %s)", 
        targetAppName or "모든 앱", targetTitle or "모든 제목"))
    hs.alert.show("일치하는 창을 찾지 못했습니다.")
    return false
end


-- ==========================================
-- 사용 예시 (단축키 바인딩)
-- ==========================================
-- 예시 1: 앱 이름이 "Google Chrome"이고, 창 제목에 "GitHub"가 포함된 창으로 포커스 이동
--hs.hotkey.bind({"cmd", "alt"}, "3", function()
    -- focusWindowByAppAndTitle("Google Chrome", "GitHub")
-- end)
-- 예시 2: 앱 이름과 상관없이 창 제목에 "메모"가 포함된 창 찾기
-- hs.hotkey.bind({"cmd", "alt"}, "4", function()
    -- focusWindowByAppAndTitle(nil, "메모")
-- end)
-- 예시 3: 특정 앱("Terminal")의 모든 창 중 첫 번째 창으로 포커스 (제목은 무시)
-- hs.hotkey.bind({"cmd", "alt"}, "5", function()
    -- focusWindowByAppAndTitle("Terminal", nil)
-- end)


--------------------------------------------------------------------------------

-- 마우스 위치를 저장할 전역 테이블
local savedPositions = {}

--- 1. 현재 마우스 위치를 지정한 이름("A")으로 저장하는 함수
function saveMousePosition(name)
    -- hs.mouse.absolutePosition()은 현재 스크린상의 절대 마우스 좌표(점 객체)를 반환합니다.
    local point = hs.mouse.absolutePosition()
    
    -- 좌표를 테이블 형태로 저장
    savedPositions[name] = { x = point.x, y = point.y }
    
    print(string.format("마우스 위치 저장됨 [%s]: x = %.1f, y = %.1f", name, point.x, point.y))
    
    -- 시각적인 피드백을 원하시면 알림(Alert)을 띄울 수도 있습니다.
    --hs.alert.show(string.format("마우스 위치 '%s' 저장 완료!", name))
end

--- 2. 저장된 이름("A")을 입력받아 해당 위치로 마우스 커서를 이동시키는 함수
function moveMouseToPosition(name)
    local pos = savedPositions[name]
    
    if pos then
        -- 마우스 포인터를 지정한 좌표로 즉시 이동
        hs.mouse.absolutePosition(pos)
        print(string.format("마우스 이동 완료 [%s]: x = %.1f, y = %.1f", name, pos.x, pos.y))
    else
        print(string.format("저장된 위치를 찾을 수 없습니다: '%s'", name))
        hs.alert.show(string.format("'%s' 위치가 저장되어 있지 않습니다.", name))
    end
end

-- ==========================================
-- 사용 예시 (단축키 바인딩)
-- ==========================================
-- hs.hotkey.bind({"cmd", "control"}, "3", function()
--     saveMousePosition("A")
-- end)

-- hs.hotkey.bind({"cmd", "control"}, "4", function()
--     moveMouseToPosition("A")
-- end)
-----------------------------------------------------------------------------

-- 상태(앱 정보 + 마우스 좌표)를 저장할 전역 테이블
local savedStates = {}

--- 1. 현재 포커스된 창의 정보와 마우스 위치를 지정한 이름으로 함께 저장하는 함수
function saveWindowStateAndMouse(name)
    name = name or "Current"
    
    -- 현재 포커스된 창 가져오기
    local win = hs.window.focusedWindow()
    if not win then
        print("[저장 실패] 포커스된 창이 없습니다.")
        hs.alert.show("포커스된 창이 없습니다.")
        return false
    end
    
    local app = win:application()
    local appName = app and app:name() or ""
    local title = win:title() or ""
    
    -- 현재 마우스 위치 가져오기
    local mousePos = hs.mouse.absolutePosition()
    
    -- 테이블에 앱 정보와 좌표 저장
    savedStates[name] = {
        appName = appName,
        title = title,
        x = mousePos.x,
        y = mousePos.y
    }
    
    print(string.format("[상태 저장 [%s]] 앱: '%s' | 제목: '%s' | 마우스: (%.1f, %.1f)", 
        name, appName, title, mousePos.x, mousePos.y))
    --hs.alert.show(string.format("'%s' 상태(창+마우스) 저장 완료!", name))
    return true
end

--- 2. 지정한 이름에 해당하는 프로그램으로 포커스를 이동하고 마우스를 저장된 위치로 옮기는 함수
function restoreWindowStateAndMouse(name)
    name = name or "Current"
    local state = savedStates[name]
    
    if not state then
        print(string.format("[복원 실패] '%s'로 저장된 상태가 없습니다.", name))
        hs.alert.show(string.format("'%s' 상태가 없습니다.", name))
        return false
    end
    
    local windows = hs.window.allWindows()
    local targetWin = nil
    
    -- 1단계: 앱 이름과 창 제목이 모두 일치하는 창 찾기
    for _, win in ipairs(windows) do
        local app = win:application()
        local appName = app and app:name() or ""
        local title = win:title() or ""
        
        if appName == state.appName and title == state.title then
            targetWin = win
            break
        end
    end
    
    -- 2단계: 정확히 일치하는 창을 못 찾았다면, 동일한 앱 이름을 가진 첫 번째 창이라도 찾기
    if not targetWin and state.appName ~= "" then
        for _, win in ipairs(windows) do
            local app = win:application()
            local appName = app and app:name() or ""
            if appName == state.appName then
                targetWin = win
                break
            end
        end
    end
    
    if targetWin then
        -- 창 포커스 이동
        targetWin:focus()
        targetWin:raise() 
        
        -- 창이 활성화된 직후 마우스 커서 이동 (0.1초 딜레이를 주어 안정성 확보)
        hs.timer.doAfter(0.2, function()
            hs.mouse.absolutePosition({ x = state.x, y = state.y })
        end)
        
        print(string.format("[복원 성공 [%s]] 앱: '%s' | 마우스 이동: (%.1f, %.1f)", 
            name, state.appName, state.x, state.y))
        --hs.alert.show(string.format("'%s' 위치 및 창으로 복원!", name))
        return true
    else
        print(string.format("[복원 실패] 일치하는 창을 찾지 못했습니다. (앱: %s)", state.appName))
        hs.alert.show(string.format("'%s'에 해당하는 창을 찾을 수 없습니다.", state.appName))
        return false
    end
end

-- ==========================================
-- 사용 예시 (단축키 바인딩)
-- ==========================================
-- -- 단축키 Cmd + Alt + Shift + S 로 현재 상태를 "A"로 저장
-- hs.hotkey.bind({"cmd", "alt", "shift"}, "S", function()
--     saveWindowStateAndMouse("A")
-- end)
-- -- 단축키 Cmd + Alt + Shift + G 로 "A"에 해당하는 창과 마우스 위치로 복원
-- hs.hotkey.bind({"cmd", "alt", "shift"}, "G", function()
--     restoreWindowStateAndMouse("A")
-- end)

-- -- 단축키 Cmd + Alt + Shift + S 로 현재 상태를 "A"로 저장
-- hs.hotkey.bind({"cmd", "control"}, "1", function()
--     saveWindowStateAndMouse("Cur1")
-- end)
-- -- 단축키 Cmd + Alt + Shift + G 로 "A"에 해당하는 창과 마우스 위치로 복원
-- hs.hotkey.bind({"cmd", "control"}, "2", function()
--     restoreWindowStateAndMouse("Cur1")
-- end)

-- hs.hotkey.bind({"cmd", "control"}, "3", function()
--     saveWindowStateAndMouse("Cur2")
-- end)
-- -- 단축키 Cmd + Alt + Shift + G 로 "A"에 해당하는 창과 마우스 위치로 복원
-- hs.hotkey.bind({"cmd", "control"}, "4", function()
--     restoreWindowStateAndMouse("Cur2")
-- end)

-------------------------------------------------------------------------------------------------------------


--- 입력받은 초(seconds) 만큼 딜레이 후, 입력받은 함수(fn)를 실행하는 함수
-- @param seconds number : 지연시킬 시간 (초 단위, 소수점 가능 e.g., 1.5)
-- @param fn function    : 딜레이 후에 실행할 함수
function runAfterDelay(seconds, fn)
    if type(seconds) ~= "number" or type(fn) ~= "function" then
        print("[에러] 첫 번째 인자는 숫자(초), 두 번째 인자는 함수여야 합니다.")
        return nil
    end

    -- hs.timer.doAfter는 지정된 초 뒤에 함수를 한 번 실행하고 타이머 객체를 반환합니다.
    return hs.timer.doAfter(seconds, fn)
end


--- 시스템 기본 경고음을 재생하여 알람 소리를 내는 함수
function playAlarmSound()
    -- macOS 내장 사운드 객체 생성 (기본 사운드 이름: "Glass", "Sosumi", "Ping", "Purr" 등)
    local sound = hs.sound.getByName("Glass")
    
    if sound then
        sound:play()
        print("[알람] 알람 사운드 재생 완료")
    else
        -- 사운드를 불러오지 못한 경우 시스템 기본 삐삐 소리(beep) 출력
        hs.alert.show("🔔 알람!")
        print("[알람] 기본 사운드를 찾지 못해 알림으로 대체합니다.")
    end
end


--- 음악 플레이
local audioPlayer = nil
local audioPath = "/Users/lamune/Documents/$phone_sync/#Music/(벨소리)IOI-갑자기.mp3"

function playAlarmMusic()
    audioPlayer = hs.sound.getByFile(audioPath)
    if audioPlayer then
        audioPlayer:play()
    end
end

-- hs.hotkey.bind({"cmd", "ctrl"}, "1", function()
--     playAlarmSound()
-- end)

-- hs.hotkey.bind({"cmd", "ctrl"}, "2", function()
--     playAlarmMusic()
-- end)

---------------------------------------------------------------

-- [공통 헬퍼] 지정된 앱 목록(targetApps)에서만 동작하고, 그 외에는 원래 단축키를 app에 전달
-- ex :  Chrome과 Ego Lite에서만 동작하도록 바인딩 (단축키는 기존에 쓰시던 키로 변경)
--          bindForApps({ "chrome", "ego" }, {"cmd", "shift"}, "d", download_image)
function bindForApps(targetApps, mods, key, callback)
    local hk
    hk = hs.hotkey.new(mods, key, function()
        local frontApp = hs.application.frontmostApplication()
        local isMatched = false

        if frontApp then
            local name = (frontApp:name() or ""):lower()
            local bundleID = (frontApp:bundleID() or ""):lower()

            for _, target in ipairs(targetApps) do
                local t = target:lower()
                if name:find(t, 1, true) or bundleID:find(t, 1, true) then
                    isMatched = true
                    break
                end
            end
        end

        if isMatched then
            -- 대상 앱일 경우 지정된 함수 실행
            callback()
        else
            -- 대상 앱이 아닐 경우 핫키를 잠시 끄고 원래 단축키 그대로 입력
            hk:disable()
            hs.eventtap.keyStroke(mods, key, 0)
            hs.timer.doAfter(0.05, function()
                hk:enable()
            end)
        end
    end)

    hk:enable()
    return hk
end
