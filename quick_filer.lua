local M = {}

-- =========================================================================
-- 전역 상태 및 설정 변수
-- =========================================================================
local iniPath = os.getenv("HOME") .. "/.hammerspoon/quick_filer.ini"
local destinations = {}       -- 단축키(문자) -> 목적지 경로 매핑 테이블
local destOrder = {}          -- 오버레이에 표시할 목적지 순서 유지용 배열
local showNotification = true -- 작업 완료 후 알림 표시 여부
local useParentBaseDir = false
local useRootBaseDir = false
local rootBaseDir = ""
local undoStack = {}          -- 실행 취소(Undo) 이력 스택
local lastSelectedDir = nil   -- 마지막으로 선택/처리되었던 파일의 부모 폴더 경로 저장

local isFileManageMode = false -- 파일 관리 모드 활성화 여부 플래그
local overlayCanvas = nil      -- 목적 폴더 선택 화면(오버레이) 캔버스 객체
local overlayKeyTap = nil      -- 오버레이 전용 키 이벤트 가로채기 객체
local globalHotkeyTap = nil    -- 전역 키 이벤트 가로채기 객체

-- =========================================================================
-- 1. INI 설정 파일 열기, 로드 및 옵션 저장
-- =========================================================================

-- 설정 파일(quick_filer.ini)을 기본 편집기로 열기 (파일이 없으면 기본 템플릿 생성)
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

-- INI 파일 파싱 및 내부 설정 갱신
function M.loadConfig()
    destinations = {}
    destOrder = {}

    -- 리로드 시 설정값 기본값으로 초기화
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

-- INI 파일 내 [Settings] 섹션의 불리언 설정값을 갱신하고 저장하는 공통 헬퍼
local function updateIniBooleanSetting(keyName, newValue)
    local valueStr = newValue and "true" or "false"
    local keyLowerTarget = keyName:lower()

    local file = io.open(iniPath, "r")
    if not file then
        return false
    end

    local lines = {}
    local inSettings = false
    local updated = false

    for line in file:lines() do
        local trimmed = line:match("^%s*(.-)%s*$")
        local section = trimmed:match("^%[(.-)%]$")
        if section then
            inSettings = (section == "Settings")
            table.insert(lines, line)
        elseif inSettings and not trimmed:match("^//") then
            local k = trimmed:match("^(.-)%s*=")
            if k and k:lower() == keyLowerTarget then
                table.insert(lines, keyName .. " = " .. valueStr)
                updated = true
            else
                table.insert(lines, line)
            end
        else
            table.insert(lines, line)
        end
    end
    file:close()

    -- 기존 INI에 해당 항목이 없었다면 [Settings] 하단에 추가
    if not updated then
        if not inSettings then
            table.insert(lines, "")
            table.insert(lines, "[Settings]")
        end
        table.insert(lines, keyName .. " = " .. valueStr)
    end

    local out = io.open(iniPath, "w")
    if out then
        out:write(table.concat(lines, "\n") .. "\n")
        out:close()
        return true
    end
    return false
end

-- INI 파일 내 useRootBaseDir 값을 즉시 토글하고 파일에 반영 (F10)
local function toggleUseRootBaseDir()
    local newValue = not useRootBaseDir
    useRootBaseDir = newValue
    updateIniBooleanSetting("useRootBaseDir", newValue)

    local statusMsg = newValue
        and ("ON (" .. (rootBaseDir ~= "" and rootBaseDir or "경로 미지정") .. ")")
        or "OFF"
    hs.alert.show("useRootBaseDir: " .. statusMsg, 1.0)
end

-- INI 파일 내 useParentBaseDir 값을 즉시 토글하고 파일에 반영 (F11)
local function toggleUseParentBaseDir()
    local newValue = not useParentBaseDir
    useParentBaseDir = newValue
    updateIniBooleanSetting("useParentBaseDir", newValue)

    hs.alert.show("useParentBaseDir: " .. (newValue and "ON (부모 폴더 기준)" or "OFF (현재 폴더 기준)"), 1.0)
end

-- =========================================================================
-- 2. 경로 계산 및 현재 선택된 파일 추출
-- =========================================================================

-- 상대경로/물결표(~)를 실제 절대경로로 변환
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

-- 현재 활성 앱에서 선택되거나 열람 중인 파일 목록 추출
local function getSelectedFiles()
    local frontApp = hs.application.frontmostApplication()
    local files = {}
    if not frontApp then return files end

    local bundleID = frontApp:bundleID() or ""

    -- [1] Finder: AppleScript로 선택된 항목 추출
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

    -- [2] qView 및 문서/이미지 뷰어: AXDocument 속성 또는 창 제목에서 경로 추출
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

    -- [3] 범용 앱: Cmd+C 클립보드 우회 추출 후 기존 클립보드 복원
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

-- 대상 폴더에 동일 파일명이 존재할 경우 _1, _2 등의 접미사를 붙여 충돌 방지
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

-- =========================================================================
-- 3. 파일 작업 수행 (이동 / 복사 / 삭제) 및 실행 취소 (Undo)
-- =========================================================================

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

        -- 이동 또는 삭제 후 다음 파일로 넘어가기 위해 오른쪽 방향키(Right Arrow) 입력
        if mode == "move" or mode == "delete" then
            hs.timer.doAfter(0.05, function()
                hs.eventtap.keyStroke({}, "right", 0)
            end)
        end
    end
end

-- 마지막 파일 작업 실행 취소 (Undo)
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

    -- 복구된 파일을 다시 보기 위해 왼쪽 방향키(Left Arrow) 입력
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({}, "left", 0)
    end)
end

-- =========================================================================
-- 4. 목적 폴더 선택 화면 (오버레이) 표시 및 닫기
-- =========================================================================

-- 목적 폴더 선택 화면(오버레이) 닫기 및 리소스 정리
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

-- 목적 폴더 선택 화면(오버레이) 표시
-- mode: "move"(이동), "copy"(복사), "view"(선택된 파일 없이 조회/설정 편집용)
local function showDestinationOverlay(mode, files)
    closeOverlay()
    if not M.loadConfig() then return end

    local screen = hs.screen.mainScreen():frame()
    local rowHeight = 30
    local headerHeight = 92
    local footerHeight = 35
    local width = 660
    local height = headerHeight + (#destOrder * rowHeight) + footerHeight

    overlayCanvas = hs.canvas.new({
        x = screen.x + (screen.w - width) / 2,
        y = screen.y + (screen.h - height) / 2,
        w = width,
        h = height
    })

    -- 배경 박스
    overlayCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.12, green = 0.13, blue = 0.15, alpha = 0.94 },
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    -- 모드별 테두리 색상 및 타이틀 문구 설정
    local strokeColor = { red = 0.9, green = 0.7, blue = 0.2, alpha = 0.85 }
    local titleText = "목적 폴더 선택 화면 (조회 모드 — 선택된 파일 없음)"
    if mode == "move" then
        strokeColor = { red = 0.3, green = 0.7, blue = 1.0, alpha = 0.85 }
        titleText = string.format("목적 폴더 선택 — 이동(MOVE) (%d개 선택됨)", #files)
    elseif mode == "copy" then
        strokeColor = { red = 0.3, green = 0.9, blue = 0.5, alpha = 0.85 }
        titleText = string.format("목적 폴더 선택 — 복사(COPY) (%d개 선택됨)", #files)
    end

    -- 테두리 선
    overlayCanvas[2] = {
        type = "rectangle",
        action = "stroke",
        strokeColor = strokeColor,
        strokeWidth = 2,
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    -- 상단 타이틀 텍스트
    overlayCanvas[3] = {
        type = "text",
        text = titleText,
        textSize = 15,
        textColor = { white = 1.0, alpha = 1.0 },
        frame = { x = 20, y = 14, w = width - 40, h = 24 }
    }

    -- useRootBaseDir 현재 상태 표시 (F10으로 즉시 토글 가능, 최우선 적용)
    local rootDirStatusText = useRootBaseDir
        and string.format("[F10] 루트 폴더 사용 (useRootBaseDir = ON: %s)", rootBaseDir ~= "" and rootBaseDir or "미지정")
        or "[F10] 루트 폴더 사용 (useRootBaseDir = OFF)"
    local rootDirStatusColor = useRootBaseDir
        and { red = 0.4, green = 0.85, blue = 1.0, alpha = 1.0 }
        or { white = 0.65, alpha = 0.85 }

    overlayCanvas[4] = {
        type = "text",
        text = rootDirStatusText,
        textSize = 12,
        textFont = "Menlo",
        textColor = rootDirStatusColor,
        frame = { x = 20, y = 40, w = width - 40, h = 18 }
    }

    -- useParentBaseDir 현재 상태 표시 (F11로 즉시 토글 가능)
    local parentDirStatusText = useParentBaseDir
        and "[F11] 부모 폴더 사용 (useParentBaseDir = ON)"
        or "[F11] 부모 폴더 사용 (useParentBaseDir = OFF)"
    local parentDirStatusColor = useParentBaseDir
        and { red = 0.4, green = 0.9, blue = 0.55, alpha = 1.0 }
        or { white = 0.65, alpha = 0.85 }

    overlayCanvas[5] = {
        type = "text",
        text = parentDirStatusText,
        textSize = 12,
        textFont = "Menlo",
        textColor = parentDirStatusColor,
        frame = { x = 20, y = 60, w = width - 40, h = 18 }
    }

    -- INI에 정의된 목적지 단축키 목록 렌더링
    local idx = 6
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

    -- 하단 조작 안내 문구
    overlayCanvas[idx] = {
        type = "text",
        text = "ESC/Enter/F12/Cmd+Ctrl+/: 닫기 | [F10]: 루트폴더 | [F11]: 부모폴더 | [m]: INI 편집",
        textSize = 11,
        textColor = { white = 0.65, alpha = 0.9 },
        frame = { x = 20, y = height - 26, w = width - 40, h = 20 }
    }

    -- 전체 화면 앱(qView 등) 위에서도 표시되도록 레벨 및 동작 설정
    overlayCanvas:behavior({"canJoinAllSpaces", "fullScreenAuxiliary"})
    overlayCanvas:level(hs.canvas.windowLevels.screenSaver)
    overlayCanvas:show()

    -- 오버레이가 열려 있는 동안의 키 입력 처리
    overlayKeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local flags = event:getFlags()
        local keyCode = event:getKeyCode()
        local char = (event:getCharacters(true) or ""):lower()

        -- [닫기] ESC 키
        if keyCode == hs.keycodes.map["escape"] then
            closeOverlay()
            return true
        -- [닫기] Enter 키 (일반 Return 및 숫자패드 Enter 모두 지원)
        elseif keyCode == hs.keycodes.map["return"] or keyCode == hs.keycodes.map["padenter"] then
            closeOverlay()
            return true
        -- [닫기] F12 키
        elseif keyCode == hs.keycodes.map["f12"] then
            closeOverlay()
            return true
        -- [닫기] Cmd + Ctrl + /
        elseif flags.cmd and flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["/"] then
            closeOverlay()
            return true
        -- [옵션 토글] F10 키 : useRootBaseDir 즉시 토글 후 오버레이 화면 갱신
        elseif not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["f10"] then
            toggleUseRootBaseDir()
            showDestinationOverlay(mode, files)
            return true
        -- [옵션 토글] F11 키 : useParentBaseDir 즉시 토글 후 오버레이 화면 갱신
        elseif not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["f11"] then
            toggleUseParentBaseDir()
            showDestinationOverlay(mode, files)
            return true
        -- [설정 편집] 단독 m 키 (모든 오버레이 모드에서 INI 설정 파일 열기)
        elseif not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["m"] then
            closeOverlay()
            M.openConfig()
            return true
        -- [파일 작업 실행] 이동/복사 모드에서 등록된 목적지 단축키 입력 시 실행
        elseif mode ~= "view" and not flags.cmd and not flags.ctrl and not flags.alt and destinations[char] then
            local targetRaw = destinations[char]
            closeOverlay()
            executeFileAction(mode, files, targetRaw)
            return true
        end

        -- 오버레이가 열려 있는 동안 그 외 키 입력은 하위 앱으로 전달되지 않도록 차단
        return true
    end)
    overlayKeyTap:start()
end

-- =========================================================================
-- 5. 트리거 및 유틸리티 함수
-- =========================================================================

-- 파일 작업 트리거
-- rawDestPath가 nil이고 mode가 "move"인 경우(목적 폴더 선택 화면 호출):
--   선택된 파일이 있으면 이동(move) 모드로, 선택된 파일이 없으면 조회(view) 모드로 오버레이 표시
function M.trigger(mode, rawDestPath)
    hs.timer.doAfter(0, function()
        M.loadConfig()
        local files = getSelectedFiles()

        if #files == 0 then
            -- 목적 폴더 선택 화면 호출 시 선택된 파일이 없더라도 조회/설정 편집이 가능하도록 view 모드로 표시
            if not rawDestPath and mode == "move" then
                showDestinationOverlay("view", {})
            else
                hs.alert.show("선택된 파일이 없습니다.", 1.0)
            end
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

-- 파일 관리 모드 진입/종료 내부 핸들러 (ModeManager가 호출)
local function enterFileManageMode()
    isFileManageMode = true
    if curStates then curStates.fileManageMode = true end
    closeOverlay()
    M.loadConfig()
end

local function exitFileManageMode()
    isFileManageMode = false
    if curStates then curStates.fileManageMode = false end
    closeOverlay()
end

-- 파일 관리 모드 전환 함수 (ModeManager에 위임)
function M.toggleMode()
    if ModeManager then
        ModeManager.toggle("filer")
    else
        -- ModeManager 미사용 환경 폴백
        if isFileManageMode then
            exitFileManageMode()
            disable_menubar_show()
        else
            enterFileManageMode()
            enable_menubar_show(BROWN)
        end
    end
end

-- 물리 keyCode를 소문자 단일 문자로 변환하는 헬퍼
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

-- =========================================================================
-- 6. 초기화: ModeManager 등록 및 OS 저수준 전역 단축키 바인딩
-- =========================================================================

function M.init()
    M.loadConfig()

    -- ModeManager에 "filer" 모드 등록
    if ModeManager then
        ModeManager.register("filer", {
            label = "File Manage 🇺🇸 ABC",
            color = BROWN,
            forceEnglish = true,
            alertMessage = "🟢 파일 관리 모드 ON\n[키]: 이동 | [Shift+키]: 복사 | [/]: 삭제 | [F12]: 목적 폴더 | [ESC]: 종료",
            alertDuration = 2.0,
            onEnter = enterFileManageMode,
            onExit = exitFileManageMode,
        })
    end

    -- 재초기화 시 기존 이벤트 탭 정리
    if globalHotkeyTap then
        globalHotkeyTap:stop()
    end

    globalHotkeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        -- 오버레이가 열려 있을 때는 overlayKeyTap이 키 입력을 전담하므로 통과시킴
        if overlayCanvas then return false end

        local flags = event:getFlags()
        local keyCode = event:getKeyCode()

        -- -----------------------------------------------------------------
        -- [A] 모드 전환 단축키 (일반모드 / 파일관리모드 공통)
        -- -----------------------------------------------------------------

        -- Cmd + Alt + F13 : 파일 관리 모드 <-> 영문 모드 토글
        if flags.cmd and not flags.ctrl and flags.alt and not flags.shift and keyCode == hs.keycodes.map["f13"] then
            hs.timer.doAfter(0, function() M.toggleMode() end)
            return true

        -- -----------------------------------------------------------------
        -- [B] 공통 조합 단축키 (일반모드 / 파일관리모드 동일 동작)
        -- -----------------------------------------------------------------

        -- Cmd + Ctrl + / : 목적 폴더 선택 화면 호출 (이동 모드, 선택 파일 없으면 조회 모드)
        elseif flags.cmd and flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["/"] then
            M.trigger("move", nil)
            return true

        -- Cmd + Ctrl + Shift + / : 목적 폴더 선택 화면 호출 (복사 모드)
        elseif flags.cmd and flags.ctrl and not flags.alt and flags.shift and keyCode == hs.keycodes.map["/"] then
            M.trigger("copy", nil)
            return true

        -- Cmd + Ctrl + Alt + / : 선택 파일 휴지통으로 삭제
        elseif flags.cmd and flags.ctrl and flags.alt and not flags.shift and keyCode == hs.keycodes.map["/"] then
            M.trigger("delete", nil)
            return true

        -- Cmd + Ctrl + O : 현재 선택/열람 중인 파일을 Finder에서 보기
        elseif flags.cmd and flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["o"] then
            M.revealInFinder()
            return true

        -- Cmd + Ctrl + Shift + Z : 마지막 파일 작업 실행 취소 (Undo)
        elseif flags.cmd and flags.ctrl and not flags.alt and flags.shift and keyCode == hs.keycodes.map["z"] then
            hs.timer.doAfter(0, function() M.undoLastAction() end)
            return true

        -- -----------------------------------------------------------------
        -- [C] "파일 관리 모드" 활성화 시 단독 키 처리
        -- -----------------------------------------------------------------

        -- ESC : 파일 관리 모드 종료 (오버레이가 닫혀 있을 때만 동작)
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["escape"] then
            hs.timer.doAfter(0, function() M.toggleMode() end)
            return true

        -- F12 : 목적 폴더 선택 화면 호출
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["f12"] then
            M.trigger("move", nil)
            return true

        -- o : 현재 선택/열람 중인 파일을 Finder에서 보기
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["o"] then
            M.revealInFinder()
            return true

        -- p : 마지막으로 작업한 폴더를 Finder에서 열기
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["p"] then
            M.openLastFolderInFinder()
            return true

        -- / : 선택 파일 휴지통으로 삭제
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and not flags.shift and keyCode == hs.keycodes.map["/"] then
            M.trigger("delete", nil)
            return true

        -- Delete (Backspace) : 마지막 파일 작업 실행 취소 (Undo)
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt and keyCode == hs.keycodes.map["delete"] then
            hs.timer.doAfter(0, function() M.undoLastAction() end)
            return true

        -- 등록된 목적지 단축키 (단독: 즉시 이동 / Shift+키: 즉시 복사)
        elseif isFileManageMode and not flags.cmd and not flags.ctrl and not flags.alt then
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
