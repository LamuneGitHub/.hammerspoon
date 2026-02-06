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
