local M = {}

local iniPath = os.getenv("HOME") .. "/.hammerspoon/quick_filer.ini"
local destinations = {}
local destOrder = {}
local showNotification = true
local useParentBaseDir = false
local useRootBaseDir = false
local rootBaseDir = ""
local undoStack = {}
local lastSelectedDir = nil -- 마지막으로 선택/처리되었던 파일의 부모 폴더 경로 저장

local isFileManageMode = false -- 파일 관리 모드 상태 플래그
local overlayCanvas = nil
local overlayKeyTap = nil
local globalHotkeyTap = nil

-- INI 파일 열기
function M.openConfig()
    if not hs.fs.attributes(iniPath) then
        local defaultIni = [[
[Destinations]
// 형식: 할당키 = 경로 (절대경로 및 상대경로 모두 지원)
1 = ~/Downloads/Sorted/Images
2 = ~/Downloads/Sorted/Documents
q = ./selected
w = ./backup

[Settings]
// 실행 후 우측 상단 알림 표시 여부 (true / false)
show_notification = true
useParentBaseDir = false
useRootBaseDir = false
rootBaseDir = ~/Downloads
]]
        local f = io.open(iniPath, "w")
        if f then
            f:write(defaultIni)
            f:close()
        end
    end
    hs.execute(string.format('open %q', iniPath))
end

-- 1. INI 파일 파싱
function M.loadConfig()
    destinations = {}
    destOrder = {}
    -- 리로드 시 기본값 초기화
    showNotification = true
    useParentBaseDir = false
    useRootBaseDir = false
    rootBaseDir = ""

    local file = io.open(iniPath, "r")
    if not file then
        hs.alert.show("quick_filer.ini 파일을 찾을 수 없습니다. 생성 후 엽니다.")
        M.openConfig()
        return false
    end

    local currentSection = ""
    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")
        -- '//'로 시작하는 줄만 주석으로 무시
        if line ~= "" and not line:match("^//") then
            local section = line:match("^%[(.-)%]$")
            if section then
                currentSection = section
            elseif currentSection == "Destinations" then
                local k, v = line:match("^(.-)%s*=%s*(.+)$")
                if k and v then
                    k = k:lower()
                    destinations[k] = v
                    table.insert(destOrder, { key = k, path = v })
                end
            elseif currentSection == "Settings" then
                local k, v = line:match("^(.-)%s*=%s*(.+)$")
                if k and v then
                    local keyLower = k:lower()
                    if keyLower == "show_notification" then
                        showNotification = (v:lower() == "true")
                    elseif keyLower == "useparentbasedir" then
                        useParentBaseDir = (v:lower() == "true")
                    elseif keyLower == "userootbasedir" then
                        useRootBaseDir = (v:lower() == "true")
                    elseif keyLower == "rootbasedir" then
                        rootBaseDir = v
                    end
                end
            end
        end
    end
    file:close()
    return true
end

-- 경로 변환
local function resolvePath(rawPath, baseDir)
    local path = rawPath:gsub("^~", os.getenv("HOME"))
    if not path:match("^/") then
        path = baseDir .. "/" .. path
    end
    path = path:gsub("/%./", "/"):gsub("//+", "/")
    return path
end

-- 상대경로 기준 디렉토리 결정 (우선순위: useRootBaseDir > useParentBaseDir > 현재 파일 폴더)
local function getEffectiveBaseDir(currentFileDir)
    if useRootBaseDir and rootBaseDir ~= "" then
        local resolvedRoot = rootBaseDir:gsub("^~", os.getenv("HOME")):gsub("/+$", "")
        return resolvedRoot ~= "" and resolvedRoot or "/"
    elseif useParentBaseDir then
        local parentOfCurrent = currentFileDir:match("^(.*)/[^/]+$")
        if parentOfCurrent and parentOfCurrent ~= "" then
            return parentOfCurrent
        elseif currentFileDir:match("^/[^/]+$") then
            return "/"
        end
    end
    return currentFileDir
end

-- 2. 현재 선택/열람 중인 파일 추출
local function getSelectedFiles()
    local frontApp = hs.application.frontmostApplication()
    local files = {}
    if not frontApp then return files end

    local bundleID = frontApp:bundleID() or ""

    -- [1] Finder
    if bundleID == "com.apple.finder" then
        local script = [[
            tell application "Finder"
                set sel to selection
                set pathList to {}
                repeat with itemRef in sel
                    set end of pathList to POSIX path of (itemRef as alias)
                end repeat
                return pathList
            end tell
        ]]
        local ok, result = hs.osascript.applescript(script)
        if ok and type(result) == "table" then
            for _, p in ipairs(result) do
                table.insert(files, (p:gsub("/$", "")))
            end
        end
        if #files > 0 then
            lastSelectedDir = files[1]:match("^(.*)/[^/]+$") or lastSelectedDir
        end
        return files
    end

    -- [2] qView 및 이미지/문서 뷰어
    local win = frontApp:focusedWindow()
    if win then
        local axWin = hs.axuielement.windowElement(win)
        if axWin then
            local docUrl = axWin:attributeValue("AXDocument")
            if docUrl and type(docUrl) == "string" and docUrl:match("^file://") then
                local decoded = hs.http.urlParts(docUrl).path
                if decoded and hs.fs.attributes(decoded) then
                    table.insert(files, decoded)
                    lastSelectedDir = decoded:match("^(.*)/[^/]+$") or lastSelectedDir
                    return files
                end
            end
        end

        local title = win:title() or ""
        local possiblePath = title:match("(/[^%-%(%)%[%]]+%.%w+)")
        if possiblePath then
            possiblePath = possiblePath:match("^%s*(.-)%s*$")
            if hs.fs.attributes(possiblePath) then
                table.insert(files, possiblePath)
                lastSelectedDir = possiblePath:match("^(.*)/[^/]+$") or lastSelectedDir
                return files
            end
        end
    end

    -- [3] 범용 앱 클립보드 우회 추출
    local prevContents = hs.pasteboard.readAllData()
    hs.pasteboard.clearContents()
    hs.eventtap.keyStroke({"cmd"}, "c", 0)
    hs.timer.usleep(100000)
    
    local urls = hs.pasteboard.readURL()
    if urls then
        if type(urls) == "table" then
            for _, u in ipairs(urls) do
                if u.filePath then table.insert(files, u.filePath) end
            end
        elseif type(urls) == "string" and urls:match("^file://") then
            local decoded = hs.http.urlParts(urls).path
            if decoded then table.insert(files, decoded) end
        end
    end
    hs.pasteboard.writeAllData(prevContents)

    if #files > 0 then
        lastSelectedDir = files[1]:match("^(.*)/[^/]+$") or lastSelectedDir
    end

    return files
end

-- 중복 파일명 방지
local function getUniqueTargetPath(dir, filename)
    local target = dir .. "/" .. filename
    if not hs.fs.attributes(target) then return target end
    local name, ext = filename:match("^(.*)%.([^%.]+)$")
    if not name then name = filename; ext = "" else ext = "." .. ext end
    local counter = 1
    while true do
        local candidate = string.format("%s/%s_%d%s", dir, name, counter, ext)
        if not hs.fs.attributes(candidate) then return candidate end
        counter = counter + 1
    end
end

-- 3. 파일 작업 수행 (이동 / 복사 / 삭제)
local function executeFileAction(mode, files, rawDestPath)
    local historyRecord = { mode = mode, items = {} }
    local successCount = 0

    for _, src in ipairs(files) do
        local currentFileDir = src:match("^(.*)/[^/]+$") or "."
        local filename = src:match("([^/]+)$")
        lastSelectedDir = currentFileDir

        if mode == "delete" then
            local trashDir = os.getenv("HOME") .. "/.Trash"
            local dst = getUniqueTargetPath(trashDir, filename)
            local ok = os.rename(src, dst)
            if not ok then os.execute(string.format('mv %q %q', src, dst)) end
            if hs.fs.attributes(dst) then
                table.insert(historyRecord.items, { src = src, dst = dst })
                successCount = successCount + 1
            end
        else
            local baseDir = getEffectiveBaseDir(currentFileDir)
            local targetDir = resolvePath(rawDestPath, baseDir)
            os.execute(string.format('mkdir -p %q', targetDir))
            local dst = getUniqueTargetPath(targetDir, filename)

            if mode == "move" then
                local ok = os.rename(src, dst)
                if not ok then os.execute(string.format('mv %q %q', src, dst)) end
                if hs.fs.attributes(dst) then
                    table.insert(historyRecord.items, { src = src, dst = dst })
                    successCount = successCount + 1
                end
            elseif mode == "copy" then
                os.execute(string.format('cp -R %q %q', src, dst))
                if hs.fs.attributes(dst) then
                    table.insert(historyRecord.items, { src = src, dst = dst })
                    successCount = successCount + 1
                end
            end
        end
    end

    if successCount > 0 then
        table.insert(undoStack, historyRecord)
        if showNotification then
            local label = (mode == "move" and "이동 완료") or (mode == "copy" and "복사 완료") or "휴지통 이동"
            hs.alert.show(string.format("%s (%d개)", label, successCount), 0.8)
        end

        -- 이동 또는 삭제 후 오른쪽 방향키(Right Arrow) 한 번 입력
        if mode == "move" or mode == "delete" then
            hs.timer.doAfter(0.05, function()
                hs.eventtap.keyStroke({}, "right", 0)
            end)
        end
    end
end

-- 4. 실행 취소 (Undo)
function M.undoLastAction()
    if #undoStack == 0 then
        hs.alert.show("취소할 이전 작업이 없습니다.", 1.2)
        return
    end

    local last = table.remove(undoStack)
    local restored = 0

    for _, item in ipairs(last.items) do
        lastSelectedDir = item.src:match("^(.*)/[^/]+$") or lastSelectedDir
        if last.mode == "move" or last.mode == "delete" then
            if hs.fs.attributes(item.dst) then
                local ok = os.rename(item.dst, item.src)
                if not ok then os.execute(string.format('mv %q %q', item.dst, item.src)) end
                if hs.fs.attributes(item.src) then restored = restored + 1 end
            end
        elseif last.mode == "copy" then
            if hs.fs.attributes(item.dst) then
                os.execute(string.format('rm -rf %q', item.dst))
                restored = restored + 1
            end
        end
    end

    local actionName = (last.mode == "move" and "이동") or (last.mode == "copy" and "복사") or "삭제"
    hs.alert.show(string.format("실행 취소: %s 복구 완료 (%d개)", actionName, restored), 1.5)

    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({}, "left", 0)
    end)
end

-- 5. 오버레이 닫기
local function closeOverlay()
    if overlayKeyTap then
        overlayKeyTap:stop()
        overlayKeyTap = nil
    end
    if overlayCanvas then
        overlayCanvas:delete()
        overlayCanvas = nil
    end
end

-- 6. 오버레이 표시 (mode: "move", "copy", 또는 "view"(단순 조회용))
local function showDestinationOverlay(mode, files)
    closeOverlay()
    if not M.loadConfig() then return end

    local screen = hs.screen.mainScreen():frame()
    local rowHeight = 30
    local headerHeight = 55
    local footerHeight = 35
    local width = 540
    local height = headerHeight + (#destOrder * rowHeight) + footerHeight

    overlayCanvas = hs.canvas.new({
        x = screen.x + (screen.w - width) / 2,
        y = screen.y + (screen.h - height) / 2,
        w = width,
        h = height
    })

    overlayCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.12, green = 0.13, blue = 0.15, alpha = 0.94 },
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    local strokeColor = { red = 0.9, green = 0.7, blue = 0.2, alpha = 0.85 }
    local titleText = "설정된 단축키 및 목적지 목록 (조회 모드)"
    if mode == "move" then
        strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 0.85 }
        titleText = string.format("파일 이동 (MOVE) — 대상 키 입력 (%d개 선택됨)", #files)
    elseif mode == "copy" then
        strokeColor = { red = 0.3, green = 0.9, blue = 0.5, alpha = 0.85 }
        titleText = string.format("파일 복사 (COPY) — 대상 키 입력 (%d개 선택됨)", #files)
    end

    overlayCanvas[2] = {
        type = "rectangle",
        action = "stroke",
        strokeColor = strokeColor,
        strokeWidth = 2,
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    overlayCanvas[3] = {
        type = "text",
        text = titleText,
        textSize = 15,
        textColor = { white = 1.0, alpha = 1.0 },
        frame = { x = 20, y = 15, w = width - 40, h = 25 }
    }

    local idx = 4
    for i, item in ipairs(destOrder) do
        local yPos = headerHeight + (i - 1) * rowHeight
        overlayCanvas[idx] = {
            type = "text",
            text = string.format("[%s]", item.key:upper()),
            textSize = 14,
            textFont = "Menlo-Bold",
            textColor = { red = 1.0, green = 0.8, blue = 0.2, alpha = 1.0 },
            frame = { x = 25, y = yPos, w = 50, h = 24 }
        }
        idx = idx + 1
        overlayCanvas[idx] = {
            type = "text",
            text = item.path,
            textSize = 14,
            textFont = "Menlo",
            textColor = { white = 0.9, alpha = 0.95 },
            frame = { x = 80, y = yPos, w = width - 100, h = 24 }
        }
        idx = idx + 1
    end

    local footerText = (mode == "view")
        and "ESC 또는 [m]: 닫기  |  Cmd+Ctrl+[m]: 설정 파일(INI) 편집"
        or "ESC: 취소  |  [m]: 설정 파일(INI) 편집"

    overlayCanvas[idx] = {
        type = "text",
        text = footerText,
        textSize = 11,
        textColor = { white = 0.6, alpha = 0.9 },
        frame = { x = 20, y = height - 26, w = width - 40, h = 20 }
    }

    overlayCanvas:behavior({"canJoinAllSpaces", "fullScreenAuxiliary"})
    overlayCanvas:level(hs.canvas.windowLevels.screenSaver)
    overlayCanvas:show()

    overlayKeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local char = (event:getCharacters(true) or ""):lower()

        if keyCode == 53 or (mode == "view" and char == "m") then
            closeOverlay()
            return true
        end

        if mode ~= "view" then
            if char == "m" then
                closeOverlay()
                M.openConfig()
                return true
            end

            if destinations[char] then
                local targetRaw = destinations[char]
                closeOverlay()
                executeFileAction(mode, files, targetRaw)
                return true
            end
        end

        return true
    end)
    overlayKeyTap:start()
end

-- 트리거 함수 (rawDestPath가 전달되면 오버레이 없이 즉시 실행)
function M.trigger(mode, rawDestPath)
    hs.timer.doAfter(0, function()
        -- 실행 시점마다 최신 INI 설정(플래그 포함) 반영
        M.loadConfig()
        local files = getSelectedFiles()
        if #files == 0 then
            hs.alert.show("선택된 파일이 없습니다.", 1.0)
            return
        end

        if mode == "delete" then
            executeFileAction("delete", files, nil)
        elseif rawDestPath then
            executeFileAction(mode, files, rawDestPath)
        else
            showDestinationOverlay(mode, files)
        end
    end)
end

-- 모드 전환 함수
function M.toggleMode()
    isFileManageMode = not isFileManageMode
    closeOverlay()
    if isFileManageMode then
        M.loadConfig()
        hs.alert.show("🟢 파일 관리 모드 ON\n[키]: 이동 | [Shift+키]: 복사 | [/]: 삭제 | [m]: 목록", 2.0)
        enable_munebar_show(BROWN)
    else
        hs.alert.show("⚪️ 일반 상태 (파일 관리 모드 OFF)", 1.5)
        disable_menubar_show()
    end
end

-- 물리 keyCode를 문자(소문자)로 변환하는 헬퍼
local function getBaseCharFromKeyCode(keyCode)
    local keyStr = hs.keycodes.map[keyCode]
    if keyStr and #keyStr == 1 then
        return keyStr:lower()
    end
    return nil
end

-- 현재 선택/열람 중인 파일을 Finder에서 선택된 상태로 열기
function M.revealInFinder()
    hs.timer.doAfter(0, function()
        local files = getSelectedFiles()
        if #files == 0 then
            hs.alert.show("선택된 파일이 없습니다.", 1.0)
            return
        end

        if #files == 1 then
            os.execute(string.format('open -R %q', files[1]))
            return
        end

        local posixItems = {}
        for _, path in ipairs(files) do
            local escaped = path:gsub('\\', '\\\\'):gsub('"', '\\"')
            table.insert(posixItems, string.format('(POSIX file "%s")', escaped))
        end

        local script = string.format([[
            tell application "Finder"
                activate
                select {%s}
            end tell
        ]], table.concat(posixItems, ", "))

        hs.osascript.applescript(script)
    end)
end

-- 마지막으로 선택되었던 파일이 있던 폴더를 Finder에서 열기
function M.openLastFolderInFinder()
    hs.timer.doAfter(0, function()
        local targetDir = lastSelectedDir

        -- lastSelectedDir가 비어있다면 undoStack의 마지막 이력에서 추출
        if not targetDir and #undoStack > 0 then
            local lastItem = undoStack[#undoStack].items[1]
            if lastItem and lastItem.src then
                targetDir = lastItem.src:match("^(.*)/[^/]+$")
            end
        end

        if not targetDir or not hs.fs.attributes(targetDir) then
            hs.alert.show("열 수 있는 마지막 폴더 기록이 없습니다.", 1.2)
            return
        end

        os.execute(string.format('open %q', targetDir))
    end)
end

-- 7. OS 저수준 전역 단축키 바인딩
function M.init()
    M.loadConfig()
    if globalHotkeyTap then
        globalHotkeyTap:stop()
    end

    globalHotkeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        if overlayCanvas then return false end

        local flags = event:getFlags()
        local keyCode = event:getKeyCode()

        -- [A] Cmd + Ctrl + Alt + F13 : 파일 관리 모드 <-> 일반 상태 토글
        if flags.cmd and not flags.ctrl and flags.alt and not flags.shift and keyCode == 105 then
            hs.timer.doAfter(0, function() M.toggleMode() end)
            return true
        end

        -- [B] 공통 조합 단축키 (Cmd + Ctrl 기반)
        if flags.cmd and flags.ctrl then
            if keyCode == hs.keycodes.map["/"] then
                if not flags.shift and not flags.alt then
                    M.trigger("move", nil)
                    return true
                elseif flags.shift and not flags.alt then
                    M.trigger("copy", nil)
                    return true
                elseif not flags.shift and flags.alt then
                    M.trigger("delete", nil)
                    return true
                end
            elseif keyCode == hs.keycodes.map["m"] and not flags.shift and not flags.alt then
                hs.timer.doAfter(0, function() M.openConfig() end)
                return true
            elseif keyCode == hs.keycodes.map["o"] and not flags.shift and not flags.alt then
                M.revealInFinder()
                return true
            elseif keyCode == hs.keycodes.map["z"] and flags.shift and not flags.alt then
                hs.timer.doAfter(0, function() M.undoLastAction() end)
                return true
            end
        end

        -- [C] "파일 관리 모드" 활성화 시 단독 키 처리
        if isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt then
            if keyCode == 31 and not flags.shift then
                M.revealInFinder()
                return true
            end

            -- 'p' 단독 입력 -> 마지막 선택되었던 파일의 폴더를 Finder에서 열기
            if keyCode == hs.keycodes.map["p"] and not flags.shift then
                M.openLastFolderInFinder()
                return true
            end

            if keyCode == 44 and not flags.shift then
                M.trigger("delete", nil)
                return true
            end

            if keyCode == hs.keycodes.map["m"] and not flags.shift then
                hs.timer.doAfter(0, function() showDestinationOverlay("view", {}) end)
                return true
            end

            if keyCode == hs.keycodes.map["delete"] then
                hs.timer.doAfter(0, function() M.undoLastAction() end)
                return true
            end

            -- INI에 설정된 목적지 키 매칭
            local baseChar = getBaseCharFromKeyCode(keyCode)
            if baseChar and destinations[baseChar] then
                local targetRaw = destinations[baseChar]
                if flags.shift then
                    M.trigger("copy", targetRaw)
                else
                    M.trigger("move", targetRaw)
                end
                return true
            end
        end

        return false
    end)

    globalHotkeyTap:start()
end

return M
