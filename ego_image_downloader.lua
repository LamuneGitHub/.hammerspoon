-- ============================================================================
-- 파일명: ego_image_downloader.lua (v14)
-- 적용 방법:
--   ~/.hammerspoon/ego_image_downloader.lua 에 저장 후
--   ~/.hammerspoon/init.lua 에 require("ego_image_downloader") 추가
-- ============================================================================

local baseDir     = os.getenv("HOME") .. "/Documents/$shell/ego_image_downloader"
local managerPy   = baseDir .. "/ego_manager.py"
local listFile    = baseDir .. "/download_url_list.ini"
local historyFile = baseDir .. "/download_url_history.log"
local workingFile = baseDir .. "/download_working_list.log"
local pidFile     = "/tmp/ego_image_downloader_manager.pid"
local stopFlag    = "/tmp/ego_image_downloader.stop"
local delimiter   = "_:::_"

local pythonBin = os.getenv("HOME") .. "/venv_lamune/bin/python3"
if hs.fs.attributes(pythonBin) == nil then
    pythonBin = "/usr/bin/python3"
end

-- 줄 앞의 '(중지-요청) ', '(중지-에러) ', '(완료) ' 접두사를 제거하고 순수 URL 추출
local function extractPureUrl(line)
    local cleaned = line:gsub("^%s*%((.-)%)%s*", "")
    return cleaned:match("^(%S+)")
end

local function getChromeTabInfo()
    local script = [[
        tell application "Google Chrome"
            set tabURL to URL of active tab of front window
            set tabTitle to title of active tab of front window
        end tell
        return tabURL & "||SEP||" & tabTitle
    ]]
    local success, result = hs.osascript.applescript(script)
    if success and result then
        local url, title = result:match("^(.-)%|%|SEP%|%|(.*)$")
        if url then
            url = url:gsub("^%s*(.-)%s*$", "%1")
            title = (title or ""):gsub("%s*%-%s*E%-Hentai Galleries.*$", ""):gsub('"', "'"):gsub("^%s*(.-)%s*$", "%1")
            return url, title
        end
    end
    return nil, nil
end

local function formatEntry(url, title, restartTs)
    local base = url
    if title and title ~= "" then
        base = string.format('%s %s "%s"', url, delimiter, title)
    end
    if restartTs and restartTs ~= "" then
        return string.format("%s  # [중복 재시작: %s]", base, restartTs)
    end
    return base
end

local function urlExistsInFile(filePath, targetUrl)
    local f = io.open(filePath, "r")
    if not f then return false end
    for line in f:lines() do
        local pure = extractPureUrl(line)
        if pure == targetUrl then
            f:close()
            return true
        end
    end
    f:close()
    return false
end

local function hasQueuedItems(filePath)
    local f = io.open(filePath, "r")
    if not f then return false end
    for line in f:lines() do
        if line:match("%S") then
            f:close()
            return true
        end
    end
    f:close()
    return false
end

local function appendLineToFile(filePath, text)
    hs.execute(string.format('mkdir -p "%s"', baseDir))
    local f = io.open(filePath, "a")
    if f then
        f:write(text .. "\n")
        f:close()
    end
end

local function prependHistory(filePath, entryText, pureUrl)
    hs.execute(string.format('mkdir -p "%s"', baseDir))
    local lines = {}
    local f = io.open(filePath, "r")
    if f then
        for line in f:lines() do
            local existingPure = extractPureUrl(line)
            if existingPure and existingPure ~= pureUrl then
                table.insert(lines, line)
            end
        end
        f:close()
    end
    local out = io.open(filePath, "w")
    if out then
        out:write(entryText .. "\n")
        for _, l in ipairs(lines) do
            out:write(l .. "\n")
        end
        out:close()
    end
end

local function isManagerRunning()
    local f = io.open(pidFile, "r")
    if not f then return nil end
    local pid = f:read("*a"):match("(%d+)")
    f:close()
    if not pid then return nil end
    local _, status = hs.execute("kill -0 " .. pid .. " 2>/dev/null")
    if status then
        return pid
    else
        os.remove(pidFile)
        return nil
    end
end

-- [단축키 1] Cmd + Ctrl + ' : Chrome URL + 페이지 제목 대기열(download_url_list.ini) 추가 및 매니저 실행
hs.hotkey.bind({"cmd", "ctrl"}, "'", function()
    local targetUrl, targetTitle = getChromeTabInfo()
    if not targetUrl or not string.match(targetUrl, "^https?://") then
        hs.alert.show("Chrome에서 유효한 URL을 가져오지 못했습니다.")
        return
    end

    if urlExistsInFile(listFile, targetUrl) or urlExistsInFile(workingFile, targetUrl) then
        hs.alert.show("이미 대기열 또는 작업 목록에 등록된 URL입니다.")
        if not isManagerRunning() then
            hs.task.new(pythonBin, nil, {managerPy}):start()
        end
        return
    end

    local isDuplicateHistory = urlExistsInFile(historyFile, targetUrl)
    if isDuplicateHistory then
        local displayTitle = (targetTitle and targetTitle ~= "") and ("\n제목: " .. targetTitle) or ""
        local btn = hs.dialog.blockAlert(
            "중복 URL 경고",
            "이미 다운로드 히스토리(download_url_history.log)에 존재하는 URL입니다.\n그래도 다시 진행하시겠습니까?" .. displayTitle .. "\nURL: " .. targetUrl,
            "진행",
            "취소"
        )
        if btn ~= "진행" then
            hs.alert.show("대기열 추가가 취소되었습니다.")
            return
        end

        local nowStr = os.date("%Y-%m-%d %H:%M:%S")
        local restartEntry = formatEntry(targetUrl, targetTitle, nowStr)
        prependHistory(historyFile, restartEntry, targetUrl)
    end

    appendLineToFile(listFile, formatEntry(targetUrl, targetTitle, nil))
    hs.alert.show("대기열 추가: " .. (targetTitle ~= "" and targetTitle or targetUrl))

    if not isManagerRunning() then
        local args = {managerPy}
        if isDuplicateHistory then
            table.insert(args, "--restart-dup-url")
            table.insert(args, targetUrl)
        end
        hs.task.new(pythonBin, nil, args):start()
    end
end)

-- [단축키 2] Cmd + Ctrl + P : 진행 중이면 즉시 완전 중지 / 중지 상태면 대기열에서 실행
hs.hotkey.bind({"cmd", "ctrl"}, "P", function()
    local pid = isManagerRunning()
    if pid then
        hs.alert.show("모든 다운로드 작업 즉시 중지 중...")
        local f = io.open(stopFlag, "w")
        if f then
            f:write("stop")
            f:close()
        end
        hs.execute("kill -TERM " .. pid .. " 2>/dev/null")
    else
        if not hasQueuedItems(listFile) then
            hs.alert.show("대기열(download_url_list.ini)이 비어 있습니다.")
            return
        end
        os.remove(stopFlag)
        hs.alert.show("대기열에서 다운로드 시작...")
        hs.task.new(pythonBin, nil, {managerPy}):start()
    end
end)
