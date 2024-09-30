--------------------------------------------------------------------------------
-- Modifier 키 제어
--------------------------------------------------------------------------------

-- 현재 Modifier키가 눌렸는지 여부 저장할 변수
curStates.lShift = false
curStates.rShift = false
curStates.lCmd = false
curStates.lAlt = false
curStates.lCtrl = false
curStates.fn = false
curStates.rCmd = false
curStates.rAlt = false  

curStates.lastKeyTime = 0   -- 마지막 키가 눌린 시간을 저장
curStates.lastKeyCode = 0   -- 마지막 눌렸던 키코드 값
curStates.sameKeyDownCount = 0     -- 같은 키가 눌렸던 횟수

curStates.lastModifierKeyTime = 0   -- 마지막 수정자 키가 눌린 시간을 저장
curStates.lastModifierKeyCode = 0   -- 마지막 눌렸던 수정자 키코드 값
curStates.sameModifierKeyDownCount = 0     -- 같은 수정자 키가 눌렸던 횟수

local doublePressInterval = 0.5  -- 두 번의 입력을 더블 프레스로 간주하는 최대 시간 간격 (초 단위)


-- --------------------------------------------------------------------------------

-- 키 상태 출력 함수
local function printKeyStatus(flag)
    print("l Shift:", curStates.lShift)
    print("r Shift:", curStates.rShift)
    print("l Cmd:", curStates.lCmd)
    print("l Alt:", curStates.lAlt)
    print("l Ctrl:", curStates.lCtrl)
    print("Fn:", curStates.fn)
    print("r Cmd:", curStates.rCmd)
    print("r Alt:", curStates.rAlt)

    -- printTable(curStates)

    -- 눌린 수정자 키 여부를 정리해서 출력
    local Keys = {}
    if flags.cmd then   table.insert(Keys, "Cmd")       end
    if flags.alt then   table.insert(Keys, "Option")    end
    if flags.ctrl then  table.insert(Keys, "Control")   end
    if flags.fn then    table.insert(Keys, "Fn")        end
    if flags.shift then table.insert(Keys, "shift")     end

    if #Keys > 0 then
        print ("눌린 키: " .. table.concat(Keys, ", ") .. " " .. event:getType() )
    end

end

-- -- 해당하는 키코드 값의 상태를 반환
-- function isKeyCodePress(keyCode)
--     attName = "keyCode_" .. keyCode
--     return curStates[attName] 
-- end


--------------------------------------------------------------------------------
-- 키 더블 클릭 감지 

-- todo 62키는 무엇 ? capslock = 0 ? 맞나?
-- 더블 프레스를 감지하는 함수
function checkDoublePress(event)
    -- print ( "checkDoublePress" )

    local keyCode = event:getKeyCode()
    local eventType = event:getType()
    local flags = event:getFlags()

    -- KeyUp 이벤트 인지 keyDown 이벤트 인지 여부 확인
    local isKeyUp = false
    if keyCode >= 54 and keyCode <= 63  then
        -- modifier인 경우에는 기본 라이브러리로 해결 불가... 특수한 방법을 써서 확인
        isKeyUp = curStates.isModifierKeyUp
    else 
        -- modifier가 아닌경우에는 정상적으로 keyup여부를 조회
        isKeyUp = eventType == hs.eventtap.event.types.keyUp
    end

    -- 더블클릭 여부를 확인
    --! #TODO: 키가 눌린 시점을 기준으로 하면 키가 눌려져 있는 동안에는 계속 이벤트가 반복호출되게 된다.
    if isKeyUp then return end

    -- print( "key press " .. curStates.lastKeyTime .. ' ' .. curStates.lastKeyCode .. ' ' .. keyCode .. '-' .. eventType )

    -- 현재 입력된 키의 입력 시간, 키 코드를 저장
    local currentTime = hs.timer.secondsSinceEpoch()
    local tmp_lastKeyTime = curStates.lastKeyTime
    curStates.lastKeyTime = currentTime
    local tmp_lastKeyCode = curStates.lastKeyCode
    curStates.lastKeyCode = keyCode

    -- 동일한 키가 눌렸는지 여부 확인
    if keyCode ~= tmp_lastKeyCode then 
        -- 키 반복이 아닌경우
        curStates.sameKeyPressCount = 1   
        return     
    end


    -- 제한 시간 안에 두번 눌렸는지 여부 확인
    if currentTime - tmp_lastKeyTime > doublePressInterval then 
        -- 키 반복이 아닌경우
        curStates.sameKeyPressCount = 1    
        return    
    end

    -- print( "더블 프레스 감지!")

    -- 키 반복인 경우
    curStates.sameKeyPressCount = curStates.sameKeyPressCount + 1
    -- print (curStates.sameKeyPressCount)

    -- (PRE) 더블클릭이라면 각 키의 구현
    if keyCode == hs.keycodes.map["a"] then
        print ( "double" )
        return
    elseif keyCode == hs.keycodes.map["b"] then
        print ( "double" )
        return

    -- curStates.rCmd = flags.cmd and keyCode == 54 or false
    -- curStates.rAlt = flags.alt and keyCode == 61 or false
    -- curStates.rShift = flags.shift and keyCode == 60 or false
    elseif keyCode == 54 then
        -- (pre) 오른쪽 cmd 더블클릭
    
        if curStates.lShift == true then 
            -- 왼쪽 shift가 눌려 있다면 창크기복원
            restoreMinimizedWindow()
        else 
            -- 단독으로 더블클릭이라면 영어     
            change_eng()
        end

        return
    elseif keyCode == 61 then
        -- (pre) 오른쪽 alt 더블클릭

        if curStates.lShift == true then 
            -- 왼쪽 shift가 눌려 있다면 창크기복원
            minimizeActiveWindow()
        else 
            -- 단독으로 더블클릭이라면 한글 
            change_kor()
        end

        return
    elseif keyCode == 60 then
        -- 오른쪽 shift 더블클릭은 입력중이던 단어 선택/삭제
        fastKeyStroke(mod.alt_and_shift, "left")
        -- fastKeyStroke(mod.empty, "delete")
        return

    elseif keyCode == 56 then
        -- 왼쪽 shift 더블클릭은 옵시디언 이미지 수정
        obsidian_fn02()
        return

    end

end

-- 키 더블 클릭 감지 등록
keyDown_checkDoublePress = hs.eventtap.new({hs.eventtap.event.types.keyDown}, checkDoublePress)
keyDown_checkDoublePress:start()
flagsChanged_checkDoublePress  = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, checkDoublePress):start()
flagsChanged_checkDoublePress:start()



--------------------------------------------------------------------------------







--------------------------------------------------------------------------------
--#TODO: 
-- local modifler_detail_map = {

--     lShift = 

--     tmp_curStates.lShift        = flags.shift       and keyCode == 56 or false
--     tmp_curStates.rShift        = flags.shift       and keyCode == 60 or false
--     tmp_curStates.lCmd          = flags.cmd         and keyCode == 55 or false
--     tmp_curStates.lAlt          = flags.alt         and keyCode == 58 or false
--     tmp_curStates.lCtrl         = flags.ctrl        and keyCode == 59 or false
--     tmp_curStates.fn            = flags.fn          and keyCode == 63 or false
--     tmp_curStates.rCmd          = flags.cmd         and keyCode == 54 or false
--     tmp_curStates.rAlt          = flags.alt         and keyCode == 61 or false
-- }

-- Modifier(수정자) 키 이벤트 발생시 현재 modifier의 상태를 왼쪽/오른쪽 여부로 분리하여 상세 관리
-- ! 늦게 등록된 이벤트가 먼저 실행되고 있다. 
-- ! 더블클릭 여부 감지 보다 먼저 실행되어야 한다.
modWatcher = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local keyCode = event:getKeyCode()

    -- print ( "flags")
    -- printTable( flags )
    -- print ('------')

    --modifier키가 keyUp상태일때 호출된 것인지 여부 확인
    -- ! Modifier 키는 키up 일때도 keydown 이벤트로 발생하는 bug가 있음
    -- !    이를 해결 하기위해 modifier가 눌려져 있지 않은 경우에는 keyup으로 간주 한다.   
    local isKeyUp = false
    if not flags.shift and not flags.cmd and not flags.alt and not flags.ctrl and not flags.fn or false then
        -- 모든 modifier키가 안 눌려져 있는 상태라면 수정자 keyup 상태이다
        isKeyUp = true
    elseif not flags.shift and keyCode == 56
        or not flags.shift and keyCode == 60
        or not flags.cmd and keyCode == 55
        or not flags.alt and keyCode == 58
        or not flags.ctrl and keyCode == 59
        or not flags.fn and keyCode == 63
        or not flags.cmd and keyCode == 54
        or not flags.alt and keyCode == 61
        then
        -- 변화가 발생한 keycode의 modifier키가 안 눌려져 있는 상태라면 수정자 keyup 상태이다
        isKeyUp = true

    elseif (curStates.lShift    and keyCode == 56)
        or (curStates.rShift   and keyCode == 60)
        or (curStates.lCmd      and keyCode == 55)
        or (curStates.lAlt      and keyCode == 58)
        or (curStates.lCtrl     and keyCode == 59)
        or (curStates.fn           and keyCode == 63)
        or (curStates.rCmd     and keyCode == 54)
        or (curStates.rAlt     and keyCode == 61)
        then
        -- 양쪽의 동일한 수정자가 같이 눌려 있다가 한쪽이 띄어지는 경우 처리
        --      기존에 이미 눌려져 있던것으로 처리되어 있는 키가 다시 호출된 경우
        isKeyUp = true
    end
    local isKeyDown = not isKeyUp


    -- 키로서 사용된 것인지 아니면 modifier사용된 것인지 구별
    -- How?
    -- 복합키로의 사용 여부 판단은?
    -- 
    --#TODO: 짧게 눌렀다가 떼어진 것인지(키로 사용된 것인지) 
    -- 길게 눌려지고 있다가 떼어진 것인지(modifier로 사용된 것인지) 여부를 확인하여 기록
    -- KeyUp 일때에 
    local isModifierKeyUsed4NormalKey = false   
    local currentTime = hs.timer.secondsSinceEpoch() 
    if isKeyUp then
        -- 동일한 키가 눌렸다가 떼어진 것이 맞는지 확인
        local tmp_lastKeyCode = curStates.lastKeyCode
        if keyCode == tmp_lastKeyCode then 
            -- 제한 시간(더블클릭 시간) 안에 눌렸는지 여부 확인
            local tmp_lastKeyTime = curStates.lastKeyTime
            if currentTime - tmp_lastKeyTime <= doublePressInterval then 
                isModifierKeyUsed4NormalKey = true
            end
        end
    end

    -----------------------------------------------------
    -- 상태 저장

    -- 공유 상태 객체의 modifier 키입력 여부 상태 갱신
    curStates.isModifierKeyUp = isKeyUp
    curStates.isModifierKeyDown = isKeyDown
    
    if isKeyDown then
        -- curStates.lastKeyCode = keyCode
        -- curStates.lastKeyTime = currentTime
        curStates.isModifierKeyUsed4NormalKey = false
    else
        curStates.isModifierKeyUsed4NormalKey = isModifierKeyUsed4NormalKey
    end

    -- print ('-isKeyUp : ' .. tostring(isKeyUp))
    -- print ('-keyCode : ' .. tostring(keyCode))

    -- 수정자들의 종합적인 눌림지속 상태를 확인 하여 기록
     -- 계산해서 알아 내야함
    if isKeyDown then
        -- 키가 눌린 경우라면 변경된 코드의 상태를 더하여 현재 상태의 값을 구한다.
        tmp_curStates = {}
        tmp_curStates.lShift        = flags.shift       and keyCode == 56 or false
        tmp_curStates.rShift        = flags.shift       and keyCode == 60 or false
        tmp_curStates.lCmd          = flags.cmd         and keyCode == 55 or false
        tmp_curStates.lAlt          = flags.alt         and keyCode == 58 or false
        tmp_curStates.lCtrl         = flags.ctrl        and keyCode == 59 or false
        tmp_curStates.fn            = flags.fn          and keyCode == 63 or false
        tmp_curStates.rCmd          = flags.cmd         and keyCode == 54 or false
        tmp_curStates.rAlt          = flags.alt         and keyCode == 61 or false

        curStates.lShift            = curStates.lShift  or tmp_curStates.lShift  
        curStates.rShift            = curStates.rShift  or tmp_curStates.rShift 
        curStates.lCmd              = curStates.lCmd    or tmp_curStates.lCmd    
        curStates.lAlt              = curStates.lAlt    or tmp_curStates.lAlt    
        curStates.lCtrl             = curStates.lCtrl   or tmp_curStates.lCtrl   
        curStates.fn                = curStates.fn      or tmp_curStates.fn         
        curStates.rCmd              = curStates.rCmd    or tmp_curStates.rCmd   
        curStates.rAlt              = curStates.rAlt    or tmp_curStates.rAlt   
    else 
        -- 키가 떼어진 경우라면 상태를 빼서 현재 상태의 값을 구한다.
        tmp_curStates = {}
        tmp_curStates.lShift        = keyCode ~= 56 or false
        tmp_curStates.rShift        = keyCode ~= 60 or false
        tmp_curStates.lCmd          = keyCode ~= 55 or false
        tmp_curStates.lAlt          = keyCode ~= 58 or false
        tmp_curStates.lCtrl         = keyCode ~= 59 or false
        tmp_curStates.fn            = keyCode ~= 63 or false
        tmp_curStates.rCmd          = keyCode ~= 54 or false
        tmp_curStates.rAlt          = keyCode ~= 61 or false

        curStates.lShift            = curStates.lShift  and tmp_curStates.lShift  
        curStates.rShift            = curStates.rShift  and tmp_curStates.rShift 
        curStates.lCmd              = curStates.lCmd    and tmp_curStates.lCmd    
        curStates.lAlt              = curStates.lAlt    and tmp_curStates.lAlt    
        curStates.lCtrl             = curStates.lCtrl   and tmp_curStates.lCtrl   
        curStates.fn                = curStates.fn      and tmp_curStates.fn         
        curStates.rCmd              = curStates.rCmd    and tmp_curStates.rCmd   
        curStates.rAlt              = curStates.rAlt    and tmp_curStates.rAlt   
    end

    --------------------------------
    -- 상태에 따른 기능 수행
    -- cf: lShift , rShift , lCmd , lCtrl ,lAlt , rCmd , rAlt , fn
    
    -- !shift가 양쪽 모두 눌리는 경우 양쪽 쉬프트키가 (키입력으로써) 무한 반복 입력 되는 문제가 있으으로 
    -- !수정자의 조합으로 이루어진 키에 대한 처리는 이곳에서 처리해야 함

    -- 특별하게 keyUp시에 시행할 기능 수행
    if isKeyUp then 
        
        -- 오른쪽 cmd, alt키는 단독을 짧게 누르면 영문/한글 키로 동작
        if curStates.isModifierKeyUsed4NormalKey and keyCode == 54 then
            -- 한글
            change_eng()-- 가끔 한글로 바뀌었다고 나오지만 실제로는 한글로 안 바뀌는 경우에 영문키를 다시 눌러주고서 다시 한글로 바꾸면 잘 되었음
            change_kor()
            change_eng()-- 가끔 한글로 바뀌었다고 나오지만 실제로는 한글로 안 바뀌는 경우에 영문키를 다시 눌러주고서 다시 한글로 바꾸면 잘 되었음
            change_kor()    
        elseif curStates.isModifierKeyUsed4NormalKey and keyCode == 61 then
            -- 영어
            change_eng()
        end

        return 
    end

    -- if isKeyDown then
    --     if curStates.lShift and curStates.rCmd then
    --         -- 영어
    --         change_eng()
    --     elseif curStates.lShift and curStates.rAlt then
    --         -- 한글
    --         change_kor()
    --     elseif curStates.lShift and curStates.rShift then
    --         -- Vmac 실행
    --         vimac()

    --         -- change_eng()
    --         -- fastKeyStroke(mod.cmd_and_alt, "=")
    --     end
    -- end

end)
modWatcher:start()
