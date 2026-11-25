
curStates.cursorMode = false
local activeBindings = {}

-- 외부 INI 파일 경로 (필요에 따라 경로 수정)
local iniPath = hs.configdir .. "/lamune_cursor_mode.ini"

-- 오버레이 상태 변수
local overlayCanvas = nil
local overlayKeyTap = nil

-------------------------------------------------------------------------
-- 기능(Action) 정의 테이블 (INI의 [FunctionMappings]와 매칭)
local actions = {
    copy = function() -- cmd + c
        fastKeyStroke(mod.cmd, "c")
    end,
    copy_right = function() -- 뒤쪽 복사
        fastKeyStroke({"cmd", "shift"}, "right")
        fastKeyStroke(mod.cmd, "c")
    end,
    copy_left = function() -- 앞쪽 복사
        fastKeyStroke({"cmd", "shift"}, "left")
        fastKeyStroke(mod.cmd, "c")
    end,
    copy_line = function() -- 한줄 복사
        fastKeyStroke(mod.cmd, "right")
        fastKeyStroke(mod.cmd_and_shift, "left")
        fastKeyStroke(mod.cmd, "c")
    end,

    ------------------------------------------------------------------------
    paste = function() -- cmd + v
        fastKeyStroke(mod.cmd, "v")
    end,
    paste_line = pasteLine, -- 현재 줄에 클립보드 내용 삽입

    ------------------------------------------------------------------------
    new_line = function() -- 새로운 라인
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end,
    new_line_up = function() -- 새로운 라인 (위쪽)
        fastKeyStroke({}, "up")
        fastKeyStroke({}, "end")
        fastKeyStroke({}, "return")
    end,
    duplicate_line = duplicateLine, -- 줄 복제

    ------------------------------------------------------------------------
    delete_line = deleteLine, -- 한줄 삭제
    cut_line = cutLine,       -- 한줄 잘라내기

    -- comment_line = function() -- 한줄 주석
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "-")
    --     fastKeyStroke({}, "-")
    --     fastKeyStroke({}, "end")
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "down")
    -- end,
    -- uncomment_line = function() -- 한줄 주석 해제
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "home")
    --     fastKeyStroke({}, "forwarddelete")
    --     fastKeyStroke({}, "forwarddelete")
    --     fastKeyStroke({}, "down")
    -- end,
}

-------------------------------------------------------------------------
-- INI 파싱 및 조합키 자동 생성 유틸리티

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- "cmd+alt+n" -> {{"cmd", "alt"}, "n"} 형태로 변환
local function parseKeyCombo(str)
    local parts = {}
    for part in string.gmatch(str, "[^+]+") do
        table.insert(parts, trim(part))
    end
    local key = table.remove(parts) -- 마지막 항목이 실제 키
    return { parts, key }
end

-- [NavMappings]에 자동 적용할 조합키 목록
local navModifierCombos = {
    {},
    { "shift" },
    { "cmd" },
    { "alt" },
    { "cmd", "shift" },
    { "alt", "shift" },
    { "cmd", "alt" },
    { "cmd", "alt", "shift" },
}

-- 두 조합키 테이블을 중복 없이 합치는 헬퍼
-- (참고: alt+left = h 처럼 이미 alt가 포함된 키는 중복을 제거하므로
--  shift+h -> shift+alt+left 등으로 정상 매핑됨)
local function mergeMods(baseMods, extraMods)
    local result = {}
    local seen = {}
    for _, m in ipairs(baseMods) do
        if not seen[m] then
            table.insert(result, m)
            seen[m] = true
        end
    end
    for _, m in ipairs(extraMods) do
        if not seen[m] then
            table.insert(result, m)
            seen[m] = true
        end
    end
    return result
end

-- 두 조합키 테이블 간에 겹치는 조합키가 있는지 확인
-- (참고: forwarddelete = cmd+' 처럼 from에 이미 cmd가 포함된 경우,
--  cmd가 포함된 추가 조합 생성을 건너뛰어 cmd+' -> forwarddelete 가 유지되도록 함)
local function hasOverlappingMod(baseMods, extraMods)
    for _, b in ipairs(baseMods) do
        for _, e in ipairs(extraMods) do
            if b == e then
                return true
            end
        end
    end
    return false
end

-- 조합키 시그니처 생성 (동일 단축키 중복 등록 방지 및 덮어쓰기용)
local function getComboSignature(combo)
    local mods = {}
    for _, m in ipairs(combo[1]) do
        table.insert(mods, m)
    end
    table.sort(mods)
    return table.concat(mods, "+") .. "+" .. combo[2]
end

-- INI 파일 로드 및 keyMappings 생성
local function loadCursorConfig(path)
    local mappings = {}
    local indexByFrom = {} -- 동일한 단축키(from) 중복 등록 방지 및 덮어쓰기용
    local toggleCombo = { {}, "f13" } -- 기본값

    -- 동일한 단축키(from)가 이미 등록되어 있으면 나중 설정으로 덮어씀
    -- (참고: delete = ' 에서 생성된 alt+'(단어 삭제) 등은 그대로 유지되면서,
    --  cmd+' 및 cmd+alt+' 등은 아래에 정의된 forwarddelete = cmd+' 가 덮어씀)
    local function addMapping(item)
        local sig = getComboSignature(item.from)
        if indexByFrom[sig] then
            mappings[indexByFrom[sig]] = item
        else
            table.insert(mappings, item)
            indexByFrom[sig] = #mappings
        end
    end

    local file = io.open(path, "r")
    if not file then
        hs.alert.show("Cursor Mode INI 파일을 찾을 수 없습니다:\n" .. path)
        return mappings, toggleCombo
    end

    local section = nil
    for line in file:lines() do
        -- # 이후의 주석 제거 및 앞뒤 공백 정리
        line = trim(line:gsub("#.*$", ""))

        if line ~= "" then
            local sec = line:match("^%[(.-)%]$")
            if sec then
                section = sec
            else
                local k, v = line:match("^(.-)=(.*)$")
                if k and v then
                    k, v = trim(k), trim(v)

                    -- 값이 비어 있으면 바인딩 생략
                    if v ~= "" then
                        if section == "Settings" and k == "toggle_key" then
                            toggleCombo = parseKeyCombo(v)

                        elseif section == "NavMappings" then
                            -- 이동/삭제 키: 기본 키 + 모든 조합키 자동 생성
                            local fromBase = parseKeyCombo(v)
                            local toBase = parseKeyCombo(k)

                            for _, mods in ipairs(navModifierCombos) do
                                if not hasOverlappingMod(fromBase[1], mods) then
                                    addMapping({
                                        t = "key",
                                        from = { mergeMods(fromBase[1], mods), fromBase[2] },
                                        to   = { mergeMods(toBase[1], mods),   toBase[2] }
                                    })
                                end
                            end

                        elseif section == "KeyMappings" then
                            -- 기능(to) = 단축키(from)
                            addMapping({
                                t = "key",
                                from = parseKeyCombo(v),
                                to = parseKeyCombo(k)
                            })

                        elseif section == "FunctionMappings" then
                            -- 액션명(to) = 단축키(from)
                            if actions[k] then
                                addMapping({
                                    t = "fnc",
                                    from = parseKeyCombo(v),
                                    to = actions[k]
                                })
                            else
                                print("[CursorMode] 알 수 없는 액션: " .. k)
                            end
                        end
                    end
                end
            end
        end
    end

    file:close()
    return mappings, toggleCombo
end

-------------------------------------------------------------------------
-- 설정 파일 열기 및 오버레이 화면 (F12)

-- INI 설정 파일 편집기로 열기
local function openCursorConfig()
    if not hs.fs.attributes(iniPath) then
        hs.alert.show("Cursor Mode INI 파일을 찾을 수 없습니다:\n" .. iniPath)
        return
    end
    hs.execute(string.format('open %q', iniPath))
end

-- 오버레이 표시용 INI 파싱 (섹션별 항목 + 인라인 주석 추출)
local function parseIniForOverlay(path)
    local sections = {
        Settings = {},
        NavMappings = {},
        KeyMappings = {},
        FunctionMappings = {},
    }

    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local currentSection = nil
    for rawLine in file:lines() do
        local body, comment = rawLine:match("^(.-)#(.*)$")
        if not body then
            body = rawLine
            comment = ""
        end
        body = trim(body)
        comment = trim(comment)

        if body ~= "" then
            local sec = body:match("^%[(.-)%]$")
            if sec then
                currentSection = sec
                if not sections[currentSection] then
                    sections[currentSection] = {}
                end
            elseif currentSection then
                local k, v = body:match("^(.-)=(.*)$")
                if k and v then
                    k, v = trim(k), trim(v)
                    if v ~= "" then
                        table.insert(sections[currentSection], {
                            action = k,
                            shortcut = v,
                            comment = comment,
                        })
                    end
                end
            end
        end
    end

    file:close()
    return sections
end

-- 오버레이 닫기
local function closeCursorOverlay()
    if overlayKeyTap then
        overlayKeyTap:stop()
        overlayKeyTap = nil
    end
    if overlayCanvas then
        overlayCanvas:delete()
        overlayCanvas = nil
    end

    -- 커서 모드가 여전히 활성화 상태라면 일시 정지했던 핫키 복구
    if curStates.cursorMode then
        for _, bind in ipairs(activeBindings) do
            bind:enable()
        end
    end
end

-- 커서 모드 설정 내용 오버레이 표시 (F12)
local function showCursorOverlay()
    -- 이미 열려 있다면 닫기 (토글 동작)
    if overlayCanvas then
        closeCursorOverlay()
        return
    end

    local sections = parseIniForOverlay(iniPath)
    if not sections then
        hs.alert.show("Cursor Mode INI 파일을 찾을 수 없습니다:\n" .. iniPath)
        return
    end

    -- 오버레이가 열려 있는 동안 m, f12 등 커서 모드 핫키와 충돌하지 않도록 일시 비활성화
    for _, bind in ipairs(activeBindings) do
        bind:disable()
    end

    -- 좌/우 2단 컬럼으로 표시할 행 구성
    local leftRows = {}
    local rightRows = {}

    local function appendSection(target, title, items)
        if not items or #items == 0 then return end
        if #target > 0 then
            table.insert(target, { isSpacer = true })
        end
        table.insert(target, { isHeader = true, title = title })
        for _, item in ipairs(items) do
            table.insert(target, item)
        end
    end

    -- 좌측 컬럼: 이동/삭제 키 + 개별 키
    appendSection(leftRows, "[NavMappings] 이동/삭제 (조합키 자동 생성)", sections.NavMappings)
    appendSection(leftRows, "[KeyMappings] 단일 키", sections.KeyMappings)

    -- 우측 컬럼: 기본 설정 + 기능 매핑
    appendSection(rightRows, "[Settings] 기본 설정", sections.Settings)
    appendSection(rightRows, "[FunctionMappings] 기능 단축키", sections.FunctionMappings)

    local screen = hs.screen.mainScreen():frame()
    local rowHeight = 25
    local headerHeight = 56
    local footerHeight = 38
    local width = 840
    local colWidth = 390
    local leftX = 24
    local rightX = 434

    local maxRows = math.max(#leftRows, #rightRows, 1)
    local height = headerHeight + (maxRows * rowHeight) + footerHeight

    overlayCanvas = hs.canvas.new({
        x = screen.x + (screen.w - width) / 2,
        y = screen.y + (screen.h - height) / 2,
        w = width,
        h = height
    })

    -- 배경
    overlayCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.12, green = 0.13, blue = 0.15, alpha = 0.94 },
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    -- 테두리 (Cursor Mode 테마에 맞춘 레드/코랄 강조색)
    overlayCanvas[2] = {
        type = "rectangle",
        action = "stroke",
        strokeColor = { red = 0.92, green = 0.36, blue = 0.36, alpha = 0.85 },
        strokeWidth = 2,
        roundedRectRadii = { xRadius = 12, yRadius = 12 }
    }

    -- 타이틀
    overlayCanvas[3] = {
        type = "text",
        text = "Cursor Mode 단축키 설정 (lamune_cursor_mode.ini)",
        textSize = 15,
        textColor = { white = 1.0, alpha = 1.0 },
        frame = { x = 24, y = 16, w = width - 48, h = 25 }
    }

    -- 중앙 세로 구분선
    overlayCanvas[4] = {
        type = "rectangle",
        action = "fill",
        fillColor = { white = 1.0, alpha = 0.12 },
        frame = { x = width / 2, y = headerHeight, w = 1, h = maxRows * rowHeight }
    }

    local idx = 5

    local function renderColumn(rows, baseX)
        for i, row in ipairs(rows) do
            local yPos = headerHeight + (i - 1) * rowHeight
            if row.isHeader then
                overlayCanvas[idx] = {
                    type = "text",
                    text = row.title,
                    textSize = 12,
                    textFont = "Menlo-Bold",
                    textColor = { red = 0.45, green = 0.78, blue = 1.0, alpha = 0.95 },
                    frame = { x = baseX, y = yPos + 2, w = colWidth, h = 22 }
                }
                idx = idx + 1
            elseif not row.isSpacer then
                -- 단축키 표시 (노란색 강조)
                overlayCanvas[idx] = {
                    type = "text",
                    text = string.format("[%s]", row.shortcut),
                    textSize = 13,
                    textFont = "Menlo-Bold",
                    textColor = { red = 1.0, green = 0.8, blue = 0.2, alpha = 1.0 },
                    frame = { x = baseX, y = yPos, w = 115, h = 22 }
                }
                idx = idx + 1

                -- 기능명 + 인라인 주석 표시
                local desc = row.action
                if row.comment and row.comment ~= "" then
                    desc = desc .. "  (" .. row.comment .. ")"
                end

                overlayCanvas[idx] = {
                    type = "text",
                    text = desc,
                    textSize = 13,
                    textFont = "Menlo",
                    textColor = { white = 0.92, alpha = 0.95 },
                    frame = { x = baseX + 120, y = yPos, w = colWidth - 120, h = 22 }
                }
                idx = idx + 1
            end
        end
    end

    renderColumn(leftRows, leftX)
    renderColumn(rightRows, rightX)

    -- 하단 안내 문구
    overlayCanvas[idx] = {
        type = "text",
        text = "ESC / F12 / Enter: 닫기   |   [m]: 설정 파일(INI) 편집",
        textSize = 11,
        textColor = { white = 0.65, alpha = 0.9 },
        frame = { x = 24, y = height - 26, w = width - 48, h = 20 }
    }

    overlayCanvas:behavior({"canJoinAllSpaces", "fullScreenAuxiliary"})
    overlayCanvas:level(hs.canvas.windowLevels.screenSaver)
    overlayCanvas:show()

    -- 오버레이 전용 키 이벤트 가로채기
    overlayKeyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()
        local char = (event:getCharacters(true) or ""):lower()

        -- ESC(53), F12(111), Enter(36), Keypad Enter(76) -> 오버레이 닫기
        if keyCode == hs.keycodes.map["escape"]
            or keyCode == hs.keycodes.map["f12"]
            or keyCode == hs.keycodes.map["return"]
            or keyCode == hs.keycodes.map["padenter"]
        then
            closeCursorOverlay()
            return true
        end

        -- 단독 'm' 키 -> 설정 파일(INI) 편집기로 열기
        if char == "m" and not flags.cmd and not flags.ctrl and not flags.alt then
            closeCursorOverlay()
            openCursorConfig()
            return true
        end

        -- 오버레이가 열려 있는 동안 다른 키 입력은 차단
        return true
    end)
    overlayKeyTap:start()
end

-------------------------------------------------------------------------
-- 단일 키 맵핑 설정 (Cursor Mode) - INI에서 로드
local keyMappings, toggleKeyCombo = loadCursorConfig(iniPath)

------------------------------------------------------------------------
-- 내부 키 바인딩 활성화 / 비활성화 (다른 모드에 대한 의존성 제거)

local function loadMode()
    -- 로딩 시 불필요한 등록/해제 방지를 위해 비활성 상태로 생성
    loadKeyBinding(keyMappings, activeBindings, false)

    -- 커서 모드 전용 F12 설정 오버레이 단축키 추가 (커서 모드일 때만 활성화)
    local overlayHotkey = hs.hotkey.new({}, "f12", showCursorOverlay)
    table.insert(activeBindings, overlayHotkey)
end

local function enterCursorMode()
    curStates.cursorMode = true
    closeCursorOverlay()
    for _, bind in ipairs(activeBindings) do
        bind:enable()
    end
end

local function exitCursorMode()
    curStates.cursorMode = false
    closeCursorOverlay()
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
hs.hotkey.bind(toggleKeyCombo[1], toggleKeyCombo[2], toggleCursorMode)

loadMode()
curStates.cursorMode = false
