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

------------------------------------------------------------------
-- Common 전역변수 정의

-- 현재의 상태를 저장할 구조체 (ModeManager와 동기화 유지)
curStates = {
    currentMode = "eng",
    cursorMode = false,
    keypad_Mode = false,
    fileManageMode = false,
    language = " 🇺🇸 ABC ",
}

-- curStates의 상태값을 이용하여 상태값 메세지를 반환
getMsg_CurStates = function()
    if ModeManager then
        local cfg = ModeManager.getCurrentModeConfig()
        if cfg and cfg.label then
            return cfg.label
        end
    end

    local cursorMode = 'Typing'
    if curStates.cursorMode == true then
        cursorMode = 'Cursor'
    elseif curStates.keypad_Mode == true then
        cursorMode = 'Keypad'
    elseif curStates.fileManageMode == true then
        cursorMode = 'File Manage'
    end

    return cursorMode .. ' ' .. (curStates.language or "")
end

-- 현재 상태를 메세지 박스로 출력
alter_CurStates = function()
    if hs.keycodes.currentSourceID() == curStates.last_alerted_IM_ID then return end

    if curStates.last_IM_alert_uuid then
        hs.alert.closeSpecific(curStates.last_IM_alert_uuid)
    end
    curStates.last_IM_alert_uuid = hs.alert.show(getMsg_CurStates(), customStyle, 1)
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
        return true
    else
        return false
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
    print(msg)

    if #tbl > 0 then
        print("Item: " .. table.concat(tbl, ", "))
    end
end

-- 키 할당이 안된 키 호출 시 실행
noAct = function()
    return 
end

-- 키를 빠르게 눌렀다 떼기
fastKeyStroke = function(modifiers, character, delayTime)
    delayTime = delayTime or 0

    hs.eventtap.event.newKeyEvent(modifiers, string.lower(character), true):post()
    if delayTime >= 0 then  
        hs.timer.usleep(delayTime * 1000000)
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
        fastKeyStroke(mod.empty, "return")
    end)
end

-- 0.5초 딜레이 후 엔터 입력
function delayEnter2()
    delay(function()
        fastKeyStroke(mod.empty, "return")
    end, 1)
end

------------------------------------------------------------------
-- 키 바인딩 설정tbl 에 따라 키 맵핑
-- @param autoEnable boolean|nil : true(기본값)면 즉시 활성화, false면 비활성 상태로 생성
function loadKeyBinding(configTbl, historyTbl, autoEnable)
    historyTbl = historyTbl or nil
    if autoEnable == nil then autoEnable = true end

    for _, mapping in ipairs(configTbl) do
        local from = mapping.from
        local to = mapping.to
        local t = mapping.t

        local bind
        if t == "key" then  
            bind = hs.hotkey.new(from[1], from[2], 
                function() fastKeyStroke(to[1], to[2]) end,
                nil,
                function() fastKeyStroke(to[1], to[2]) end
            )
        elseif t == "fnc" then 
            bind = hs.hotkey.new(from[1], from[2], to)
        elseif t == "app" then 
            bind = hs.hotkey.new(from[1], from[2], function()
                toggleApplication(to)
            end)
        end 

        if bind then
            if autoEnable then
                bind:enable()
            end
            if historyTbl ~= nil then
                table.insert(historyTbl, bind)
            end
        end
    end
end

------------------------------------------------------------------
-- (Common 디자인) 

-- 메세지 박스 ui 디자인 정의
customStyle = hs.alert.defaultStyle
customStyle.fillColor = { white = 0, alpha = 0.5 }
customStyle.strokeColor = { alpha = 0 }
customStyle.textColor = { white = 0.75, alpha = 0.75 }
customStyle.textSize = 30
customStyle.fadeOutDuration = 0.1

------------------------------------------------------------------
-- (알림) 메뉴바 색상을 바꿔서 모드 바뀜을 알려주는 기능

local boxes = {}
local box_height = 23
local box_alpha = 0.45
GREEN = { red = 0,   green = 1,   blue = 0   }
RED   = { red = 1,   green = 0,   blue = 0   }
BLUE  = { red = 0,   green = 0,   blue = 1   }
BROWN = { red = 0.6, green = 0.4, blue = 0.2 }

-- 메뉴바 표시
function enable_menubar_show(color)
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

-- -- 기존 코드 하위 호환용 별칭 (오타 함수명 유지)
-- enable_munebar_show = enable_menubar_show

-- 메뉴바 안보이게 
function disable_menubar_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
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

-- 스크린에 변동 사항이 생긴 경우 현재 활성 모드의 UI 재계산 처리
function change_menubar_color()
    if ModeManager then
        ModeManager.refreshUI()
    else
        disable_menubar_show()
    end
end

function handleScreenEvent()
    change_menubar_color()
end

hs.screen.watcher.new(handleScreenEvent):start()
hs.screen.watcher.newWithActiveScreen(handleScreenEvent):start()

------------------------------------------------------------------
-- 창 제어 / 마우스 위치 / 알람 / 앱별 단축키 / 문서 경로 유틸리티

--- 1. 현재 포커스된 창의 이름을 반환하는 함수
function getFocusedWindowTitle()
    local win = hs.window.focusedWindow()
    if win then
        local title = win:title()
        local appName = win:application():name()
        print(string.format("현재 앱: %s | 창 제목: %s", appName, title))
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
        if targetTitle and targetTitle ~= "" then
            if not title:lower():find(targetTitle:lower(), 1, true) then
                isTitleMatch = false
            end
        end
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

--- 1. 현재 마우스 위치를 name으로 저장하는 함수
function saveMousePosition(name)
    local point = hs.mouse.absolutePosition()
    savedPositions[name] = { x = point.x, y = point.y }
    print(string.format("마우스 위치 저장됨 [%s]: x = %.1f, y = %.1f", name, point.x, point.y))
end

-- 2. name 입력받아 해당 위치로 마우스 커서를 이동시키는 함수
function moveMouseToPosition(name)
    local pos = savedPositions[name]
    if pos then
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

-- 1. 현재 포커스된 창의 정보와 마우스 위치를 지정한 이름으로 함께 저장하는 함수
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
    return true
end

-- 2. 지정한 이름에 해당하는 프로그램으로 포커스를 이동하고 마우스를 저장된 위치로 옮기는 함수
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
        targetWin:focus()
        targetWin:raise()
        hs.timer.doAfter(0.2, function()
            hs.mouse.absolutePosition({ x = state.x, y = state.y })
        end)
        print(string.format("[복원 성공 [%s]] 앱: '%s' | 마우스 이동: (%.1f, %.1f)", 
            name, state.appName, state.x, state.y))
        return true
    else
        print(string.format("[복원 실패] 일치하는 창을 찾지 못했습니다. (앱: %s)", state.appName))
        hs.alert.show(string.format("'%s'에 해당하는 창을 찾을 수 없습니다.", state.appName))
        return false
    end
end

--- 입력받은 초(seconds) 만큼 딜레이 후, 입력받은 함수(fn)를 실행하는 함수
-- @param seconds number : 지연시킬 시간 (초 단위, 소수점 가능 e.g., 1.5)
-- @param fn function    : 딜레이 후에 실행할 함수
function runAfterDelay(seconds, fn)
    if type(seconds) ~= "number" or type(fn) ~= "function" then
        print("[에러] 첫 번째 인자는 숫자(초), 두 번째 인자는 함수여야 합니다.")
        return nil
    end
    return hs.timer.doAfter(seconds, fn)
end

-- 시스템 기본 경고음을 재생하여 알람 소리를 내는 함수
function playAlarmSound()
    local sound = hs.sound.getByName("Blow")
    if sound then
        sound:play()
        print("[알람] 알람 사운드 재생 완료")
    else
        hs.alert.show("🔔 알람!")
        print("[알람] 기본 사운드를 찾지 못해 알림으로 대체합니다.")
    end
end

local audioPlayer = nil
local audioPath = "/Users/lamune/Documents/$phone_sync/#Music/(벨소리)IOI-갑자기.mp3"

function playAlarmMusic()
    audioPlayer = hs.sound.getByFile(audioPath)
    if audioPlayer then
        audioPlayer:play()
    end
end

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
            callback()
        else
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

function decodeURI(str)
    return (str:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

function getFinderPath()
    local script = [[
        tell application "Finder"
            set sel to selection
            if (count of sel) > 0 then
                set paths to {}
                repeat with f in sel
                    set end of paths to POSIX path of (f as alias)
                end repeat
                set AppleScript's text item delimiters to linefeed
                return paths as text
            else
                try
                    return POSIX path of (target of front window as alias)
                on error
                    return POSIX path of (path to desktop)
                end try
            end if
        end tell
    ]]
    local ok, result = hs.osascript.applescript(script)
    if ok and result and result ~= "" then
        return result
    end
    return nil
end

function getAXDocumentPath(app)
    local axApp = hs.axuielement.applicationElement(app)
    if not axApp then return nil end
    local axWin = axApp:attributeValue("AXFocusedWindow")
    if not axWin then return nil end
    local doc = axWin:attributeValue("AXDocument")
    if doc and type(doc) == "string" and doc ~= "" then
        local path = doc:gsub("^file://localhost", ""):gsub("^file://", "")
        return decodeURI(path)
    end
    return nil
end

function getActiveAppDocumentPath()
    local app = hs.application.frontmostApplication()
    if not app then return nil end
    local path = (app:bundleID() == "com.apple.finder")
        and getFinderPath()
        or getAXDocumentPath(app)
    if path then
        return path:gsub("%s+$", "")
    end
    return nil
end
