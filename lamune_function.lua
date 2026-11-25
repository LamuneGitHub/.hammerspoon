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

-- 날짜 입력
function keyInput_date()  
    hs.eventtap.keyStrokes(os.date("(%Y-%m-%d)"))
end

-- 날짜 및 시간 입력
function keyInput_dateTime()  
    hs.eventtap.keyStrokes(os.date("(%Y-%m-%d-%H%M)"))
end

-- T O D O 입력
function keyInput_Todo()
  hs.eventtap.keyStrokes( "#TO")
  hs.eventtap.keyStrokes( "DO: ")
end

-- md 에서 강제 space 
function md_HardSpace()
  hs.eventtap.keyStrokes( "$\\quad$")
end 


------------------------------------------------------------------
-- 시스템 전체 소리 음소거 토글 함수
function toggleSystemMute()
    local device = hs.audiodevice.defaultOutputDevice()
    
    if not device then
        hs.alert.show("출력 오디오 장치를 찾을 수 없습니다.")
        return
    end

    -- 현재 음소거 상태 확인 후 반전
    local isMuted = device:muted()
    device:setMuted(not isMuted)

    -- 현재 상태 알림 표시 (원하지 않으면 아래 if문 삭제 가능)
    if not isMuted then
        hs.alert.show("🔇 시스템 음소거")
    else
        hs.alert.show("🔊 소리 복원됨")
    end
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

    -- -- 1. 현재 포커스된 창을 확실히 가져옴
    -- local win = hs.window.focusedWindow()
    
    -- if win then
    --     -- 2. 창을 앞으로 끌어오고 포커스를 강제로 고정
    --     win:raise()
    --     win:focus()
    -- end

    
    hs.timer.usleep(0.1 *1000000)

    local mousePos = hs.mouse.absolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, mousePos):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, mousePos):post()

    end


-- -- 마우스 오른쪽 클릭 함수 (개선됨)
-- function rightMouseClick()
--     -- 1. 현재 포커스된 창을 확실히 가져옴
--     local win = hs.window.focusedWindow()
    
--     if win then
--         -- 2. 창을 앞으로 끌어오고 포커스를 강제로 고정
--         win:raise()
--         win:focus()
--     end

--     -- 3. 현재 마우스 커서 위치 가져오기
--     -- (참고: hs.mouse.getAbsolutePosition 대신 hs.mouse.absolutePosition이 최신 Hammerspoon 표준입니다)
--     local mousePos = hs.mouse.absolutePosition()

--     -- 4. 포커스가 확실히 이동할 수 있도록 아주 짧은 딜레이(0.02초) 후 클릭 이벤트 발생
--     hs.timer.doAfter(0.02, function()
--         local downEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, mousePos)
--         local upEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, mousePos)
        
--         downEvent:post()
--         upEvent:post()
--     end)
    
--     print("[우클릭 실행] 현재 포커스 창에 우클릭 전달 완료")
-- end

----------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------



-- vimac mode 실행
vimac = function()
    change_eng()
    fastKeyStroke(mod.cmd_and_alt, "=")
end

-- 한줄 복제
function duplicateLine() 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd, "right") 
    fastKeyStroke(mod.cmd, "c") 
    fastKeyStroke("cmd", "v")
    fastKeyStroke({}, "home")
end

-- 한줄 삭제
function deleteLine()
    fastKeyStroke({}, "end")
    fastKeyStroke({"shift"}, "home")
    fastKeyStroke({"shift"}, "home")
    fastKeyStroke({}, "forwarddelete")
    fastKeyStroke({}, "forwarddelete")
end

-- 한줄 잘라내기
function cutLine() 
    fastKeyStroke(mod.cmd, "right") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd_and_shift, "left") 
    fastKeyStroke(mod.cmd, "x")
    fastKeyStroke({}, "forwarddelete")
end

-- 현재줄에 복사한 내용 끼워 넣기
pasteLine = function()
    fastKeyStroke(mod.cmd, "left")
    fastKeyStroke(mod.cmd, "v")
    delayEnter()
end

-- 현재 마우스 위치를 클립보드에 저장
copyMousePosition = function()
    local mousePos = hs.mouse.absolutePosition()
    local frontWin = hs.window.frontmostWindow()
    
    if not frontWin then
        hs.pasteboard.setContents("No frontmost window found.")
        return
    end
    
    -- 반올림하여 정수 변환
    local absX = math.floor(mousePos.x + 0.5)
    local absY = math.floor(mousePos.y + 0.5)
    
    local winFrame = frontWin:frame()
    local relX = math.floor((mousePos.x - winFrame.x) + 0.5)
    local relY = math.floor((mousePos.y - winFrame.y) + 0.5)
    
    local text = string.format(
        "(Abs: %d , %d Rel: %d , %d)",
        absX, absY,
        relX, relY
    )

    hs.pasteboard.setContents(text)
    hs.alert.show("Mouse position copied to clipboard!")
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

    hs.timer.usleep(100000)
    hs.eventtap.keyStroke({"cmd"}, "delete")
    hs.eventtap.keyStroke({"cmd"}, "v")

    -- local clipboardContent = hs.pasteboard.getContents()
    -- hs.eventtap.keyStrokes(clipboardContent)

    fastKeyStroke({}, "delete")
end


--------------------------------------------------------    
-- chrome 활용

-- tumbler에서 이미지를 다운로드
download_image = function()

    if isUrl("tumblr") then
        rightMouseClick()
        hs.timer.usleep(0.1 *1000000)
        hs.eventtap.keyStrokes("Download image")
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
        hs.eventtap.keyStrokes("Download image")
        fastKeyStroke(mod.empty, "return")
    end

end



------------------------------------

-- Cmd + Ctrl + F : 현재 선택 파일의 경로에서 Lokii 호출
--   현재 폴더 경로를 작은따옴표('...')로 감싸서 입력
hs.hotkey.bind({"cmd", "ctrl"}, "f", function()
    local finderScript = [[
        tell application "Finder"
            set sel to selection
            if (count of sel) > 0 then
                set targetItem to item 1 of sel as alias
                set itemKind to kind of (item 1 of sel)
                if itemKind is "폴더" or itemKind is "Folder" or itemKind is "디스크" or itemKind is "Volume" then
                    set targetPath to POSIX path of targetItem
                else
                    set targetPath to POSIX path of (container of (item 1 of sel) as alias)
                end if
            else
                if (count of windows) > 0 then
                    set targetPath to POSIX path of (target of front window as alias)
                else
                    set targetPath to POSIX path of (path to desktop)
                end if
            end if
        end tell
        return targetPath
    ]]

    local ok, targetPath = hs.osascript.applescript(finderScript)
    if not ok or not targetPath or targetPath == "" then
        hs.alert.show("경로를 가져올 수 없습니다.")
        return
    end

    -- AppleScript 반환값 끝에 붙을 수 있는 줄바꿈 제거 후 작은따옴표로 감싸기
    targetPath = targetPath:gsub("%s+$", "")
    local quotedPath = "'" .. targetPath .. "' "

    -- 1. Lokii 앱 실행 및 활성화
    hs.application.launchOrFocus("Lokii")

    -- 2. 앱 창이 포커스를 받을 때까지 잠시 대기 후 붙여넣기 실행
    hs.timer.doAfter(0.5, function()
        local prevClipboard = hs.pasteboard.getContents()
        hs.pasteboard.setContents(quotedPath)
        hs.eventtap.keyStroke({"cmd"}, "v")

        hs.timer.doAfter(0.2, function()
            if prevClipboard then
                hs.pasteboard.setContents(prevClipboard)
            end
        end)
    end)
end)

-- Cmd + Ctrl + U :  현재 파일의 폴더 위치에서 새 Terminal 창 열기
hs.hotkey.bind({"cmd", "ctrl"}, "u", function()
    local script = [[
        tell application "Finder"
            set sel to selection
            if (count of sel) > 0 then
                set targetItem to item 1 of sel as alias
                set itemKind to kind of (item 1 of sel)
                if itemKind is "폴더" or itemKind is "Folder" or itemKind is "디스크" or itemKind is "Volume" then
                    set targetPath to POSIX path of targetItem
                else
                    set targetPath to POSIX path of (container of (item 1 of sel) as alias)
                end if
            else
                if (count of windows) > 0 then
                    set targetPath to POSIX path of (target of front window as alias)
                else
                    set targetPath to POSIX path of (path to desktop)
                end if
            end if
        end tell
        return targetPath
    ]]

    local ok, targetPath = hs.osascript.applescript(script)
    if not ok or not targetPath or targetPath == "" then
        hs.alert.show("경로를 가져올 수 없습니다.")
        return
    end

    -- 공백이나 특수문자([], ★, ● 등)가 포함된 경로를 안전하게 이스케이프 처리
    local escapedPath = targetPath:gsub("'", "'\\''")
    local cmd = string.format([[osascript -e 'tell application "Terminal" to do script "cd '\''%s'\''"' -e 'tell application "Terminal" to activate']], escapedPath)
    
    hs.execute(cmd)
end)

-- Cmd + Ctrl + I : 현재 Finder 선택 항목의 폴더 위치에서 새 iTerm 창 열기
hs.hotkey.bind({"cmd", "ctrl"}, "i", function()
    local finderScript = [[
        tell application "Finder"
            set sel to selection
            if (count of sel) > 0 then
                set targetItem to item 1 of sel as alias
                set itemKind to kind of (item 1 of sel)
                if itemKind is "폴더" or itemKind is "Folder" or itemKind is "디스크" or itemKind is "Volume" then
                    set targetPath to POSIX path of targetItem
                else
                    set targetPath to POSIX path of (container of (item 1 of sel) as alias)
                end if
            else
                if (count of windows) > 0 then
                    set targetPath to POSIX path of (target of front window as alias)
                else
                    set targetPath to POSIX path of (path to desktop)
                end if
            end if
        end tell
        return targetPath
    ]]

    local ok, targetPath = hs.osascript.applescript(finderScript)
    if not ok or not targetPath or targetPath == "" then
        hs.alert.show("경로를 가져올 수 없습니다.")
        return
    end

    -- AppleScript 문자열 내부에서 안전하게 쓰기 위해 백슬래시와 큰따옴표 이스케이프 처리
    local escapedPath = targetPath:gsub("\\", "\\\\"):gsub('"', '\\"')

    local itermScript = string.format([[
        tell application "iTerm"
            create window with default profile
            tell current session of current window
                write text "cd \"%s\" && clear"
            end tell
            activate
        end tell
    ]], escapedPath)

    hs.osascript.applescript(itermScript)
end)

-- 모든 프로그램에서 현재 창(또는 Finder 선택 파일)을 VS Code로 즉시 열기
hs.hotkey.bind({"cmd", "ctrl"}, "E", function()
    -- local frontApp = hs.application.frontmostApplication()
    -- if not frontApp then return end

    -- local appName = frontApp:name()
    -- local filePath = nil

    -- -- 1. Finder가 활성화된 경우: 현재 선택된 파일 경로 가져오기
    -- if appName == "Finder" then
    --     local script = [[
    --         tell application "Finder"
    --             set sel to selection
    --             if (count of sel) > 0 then
    --                 return POSIX path of (item 1 of sel as alias)
    --             end if
    --         end tell
    --     ]]
    --     local ok, result = hs.osascript.applescript(script)
    --     if ok and result ~= "" then
    --         filePath = result
    --     end
    -- else
    --     -- 2. 그 외 모든 문서 기반 앱: Hammerspoon 네이티브 AX API로 즉시 경로 추출 (AppleScript 불필요)
    --     local win = hs.window.focusedWindow()
    --     if win then
    --         local axWin = hs.axuielement.windowElement(win)
    --         if axWin then
    --             local docURL = axWin:attributeValue("AXDocument")
    --             if docURL then
    --                 filePath = hs.http.urlParts(docURL).path
    --                 -- URL 인코딩(한글/공백 등) 디코딩 처리
    --                 filePath = string.gsub(filePath, "%%(%x%x)", function(h)
    --                     return string.char(tonumber(h, 16))
    --                 end)
    --             end
    --         end
    --     end
    -- end

    local filePath = getActiveAppDocumentPath()

    -- 3. 경로가 확인되면 VS Code로 즉시 실행
    if filePath and filePath ~= "" then
        hs.task.new("/usr/bin/open", nil, {"-a", "Visual Studio Code", filePath}):start()
    else
        hs.alert.show("열 수 있는 파일 경로가 없는 창입니다 (" .. appName .. ")", 1.2)
    end
end)


-- Ctrl + Shift + C 단축키 바인딩
hs.hotkey.bind({"cmd", "shift"}, "c", function()
    local path = getActiveAppDocumentPath()
    if path then
        hs.pasteboard.setContents(path)
        hs.alert.show("경로 복사됨:\n" .. path, 1.5)
    else
        hs.alert.show("현재 창에서 파일/폴더 경로를 찾을 수 없습니다.", 1.5)
    end
end)

----------------------------------------------------------------------

function bindEscToToggleApp(appNames)
    local targetSet = {}
    for _, name in ipairs(appNames) do
        targetSet[name] = true
    end

    local escToggleHotkey = hs.hotkey.new({}, "escape", function()
        local app = hs.application.frontmostApplication()
        if app and targetSet[app:name()] then
            local appName = app:name()
            -- 정의해 두신 toggleApplication 함수에 앱 이름을 전달하여 호출
            toggleApplication(appName)
        end
    end)

    -- hs.window.filter 대신 가벼운 hs.application.watcher 사용 (로딩 지연 개선)
    local appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if eventType == hs.application.watcher.activated then
            if targetSet[appName] then
                escToggleHotkey:enable()
            else
                escToggleHotkey:disable()
            end
        elseif eventType == hs.application.watcher.deactivated then
            if targetSet[appName] then
                escToggleHotkey:disable()
            end
        end
    end)
    appWatcher:start()

    local currentApp = hs.application.frontmostApplication()
    if currentApp and targetSet[currentApp:name()] then
        escToggleHotkey:enable()
    end

    return escToggleHotkey, appWatcher
end

_G.escToggleManager = {
    bindEscToToggleApp({
        "qView",
        "Markdown Peek",
        "Preview",
    })
}


