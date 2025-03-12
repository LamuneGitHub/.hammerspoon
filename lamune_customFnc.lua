--------------------------------------------------------

-- (단축키) Hammer spoon 설정 Reloading 단축키 기능 정의
reloadHammerSpoon = function()
    hs.reload()
end

-- 프로그램 정보 확인
runningAppInfo = function()
    local app = hs.application.frontmostApplication()
    print("name = " .. tostring(app:name()) )
    print("title = " .. tostring(app:title()) )
    print("url = " .. tostring(getChromeURL()) )

    hs.alert.show(app:name())
end

------------------------------------------------------------------
-- chrome 관련 

-- 현재 포커스된 Chrome의 URL을 가져오는 함수
function getChromeURL()
    local script = [[
        tell application "Google Chrome"
            set currentTabURL to URL of active tab of front window
        end tell
        return currentTabURL
    ]]

    -- AppleScript 실행 및 결과 반환
    local success, result = hs.osascript.applescript(script)
    if success then
        return result
    else
        return "Error: Could not retrieve URL."
    end
end

-- 현재 크롬 브라우저의 url에 text가 포함되어 있는지 여부 반환
function isUrl(text) 
    local url = getChromeURL()

    return containsString(url,text)
end

-- Chrome에서 현재 선택된 tab의 이름을 반환
function getChromeTabName()
    local script = [[
        tell application "Google Chrome"
            set currentTabTitle to title of active tab of front window
        end tell
        return currentTabTitle
    ]]

    -- AppleScript 실행 및 결과 반환
    local success, result = hs.osascript.applescript(script)
    if success then
        return result
    else
        return "Error: Could not retrieve tab name."
    end
end

------------------------------------------------------------------

-- 마우스 왼쪽 클릭 
leftMouseClick = function()
    local mousePos = hs.mouse.getAbsolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, mousePos):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, mousePos):post()
end

-- 마우스 더블클릭
doubleLeftClick = function()
    --print('mouse double click')

    local mousePos = hs.mouse.getAbsolutePosition()

    local clickState = hs.eventtap.event.properties.mouseEventClickState
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], mousePos):setProperty(clickState, 1):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], mousePos):setProperty(clickState, 1):post()
    hs.timer.usleep(1000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], mousePos):setProperty(clickState, 2):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], mousePos):setProperty(clickState, 2):post()
end

-- 마우스 오른쪽 클릭
rightMouseClick = function()
    local mousePos = hs.mouse.getAbsolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, mousePos):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, mousePos):post()
end

-- vimac mode 실행
vimac = function()
    change_eng()
    fastKeyStroke(mod.cmd_and_alt, "=")
end


-- 현재줄에 복사한 내용 끼워 넣기
insert_cur_line = function()
    fastKeyStroke(mod.cmd, "left")
    fastKeyStroke(mod.cmd, "v")
    fastKeyStroke(mod.empty , "return")
    fastKeyStroke(mod.empty, "up")
end


--------------------------------------------------------    
-- 옵시디언 활용

-- Chrome의 현재 선택된 탭의 "[탭 이름](URL)" 출력
obsidian_fn01 = function()
    local tabName = getChromeTabName()
    local url = getChromeURL()
    
    if tabName and url then
        local clipboardText = string.format("[# %s](%s)", tabName, url)
        -- hs.pasteboard.setContents(clipboardText) -- 클립보드에 복사
        -- hs.alert.show("Copied to Clipboard: " .. clipboardText)

        hs.eventtap.keyStrokes(clipboardText)
    else
        hs.alert.show("Error: Could not retrieve tab name or URL.")
    end

end

--로컬 이미지를 web 이미지로 변경
obsidian_fn02 = function()
    rightMouseClick()
    -- hs.timer.usleep(1000000)
    fastKeyStroke(mod.empty , "escape")
    fastKeyStroke(mod.empty , "escape")
    -- hs.timer.usleep(1000000)
    -- doubleLeftClick()
    leftMouseClick()
    -- leftMouseClick()

    -- hs.timer.usleep(100000)
    hs.eventtap.keyStroke({"cmd"}, "delete")
    hs.eventtap.keyStroke({"cmd"}, "v")

    -- local clipboardContent = hs.pasteboard.getContents()
    -- hs.eventtap.keyStrokes(clipboardContent)
end


--------------------------------------------------------    
-- chrome 활용

-- tumbler에서 이미지를 다운로드
download_image = function()

    if isUrl("tumblr") then
        rightMouseClick()
        hs.timer.usleep(0.1 *1000000)
        hs.eventtap.keyStrokes("save image to")
        fastKeyStroke(mod.empty, "return")

    elseif isUrl("pixiv") then
        rightMouseClick()
        -- hs.timer.usleep(0.1 *1000000)
        hs.eventtap.keyStrokes("이미지를")

        fastKeyStroke(mod.empty, "return")

        hs.timer.usleep(5*100000) 
        fastKeyStroke(mod.empty, "return")
    else 
        rightMouseClick()
        hs.timer.usleep(5*100000)
        hs.eventtap.keyStrokes("save image to")
        fastKeyStroke(mod.empty, "return")
    end

end