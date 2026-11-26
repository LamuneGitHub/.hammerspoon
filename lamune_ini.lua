--[[
[프로그램 목적 및 핵심 기능 요약]
Hammerspoon 환경에서 여러 Lua 모듈(lamune_cursor_mode, quick_filer 등)이 공통으로 사용할 수 있는
외부 INI 설정 파일 파싱·조회·수정 유틸리티 모듈입니다.
주석 스타일(#, //, ;)과 인라인 주석 추출, 항목 순서 보존, 대소문자 무시 조회,
기존 주석과 서식을 유지한 채 특정 설정값만 갱신하는 기능을 제공합니다.

---
# lamune_ini.lua 상세 설명

## 1. 제공 함수
* `M.trim(s)`: 문자열 앞뒤 공백 제거
* `M.parse(path, opts)`: INI 파일을 읽어 섹션별 항목 목록(순서 보존)과 키-값 맵을 반환
  * `opts.commentPrefixes`: 주석 기호 배열 (기본값: `{"#"}`, 예: `{"//"}`, `{"#", ";"}`)
  * `opts.inlineComments`: 줄 중간 주석 분리 여부 (기본값: `true`)
  * `opts.skipEmptyValues`: 값이 비어 있는 항목 무시 여부 (기본값: `true`)
  * 반환값: `result, err`
    * `result.sections[섹션명]`: `{ { key = ..., value = ..., comment = ... }, ... }` (파일 순서 유지)
    * `result.map[섹션명][소문자키]`: 마지막으로 등장한 값 (빠른 조회용)
* `M.updateKey(path, sectionName, keyName, newValue, opts)`:
  * 기존 파일의 주석과 줄 순서를 유지하면서 지정한 섹션의 특정 키 값을 수정(없으면 섹션 끝에 추가)

## 2. 사용 예시
```lua
local IniUtil = require("lamune_ini")

-- '#' 인라인 주석을 사용하는 INI 읽기
local data, err = IniUtil.parse(hs.configdir .. "/lamune_cursor_mode.ini", {
    commentPrefixes = { "#" },
    inlineComments = true,
})

-- '//' 줄 주석을 사용하는 INI 읽기
local qfData, qfErr = IniUtil.parse(hs.configdir .. "/quick_filer.ini", {
    commentPrefixes = { "//" },
    inlineComments = false,
})

-- 특정 섹션의 설정값 갱신
IniUtil.updateKey(hs.configdir .. "/quick_filer.ini", "Settings", "useParentBaseDir", "true", {
    commentPrefixes = { "//" },
})
```
---
]]

local M = {}

-- 문자열 앞뒤 공백 제거 유틸리티
function M.trim(s)
    if type(s) ~= "string" then
        return ""
    end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- 주어진 줄에서 설정된 주석 기호에 따라 본문(body)과 주석(comment)을 분리하는 내부 헬퍼
local function splitBodyAndComment(rawLine, commentPrefixes, inlineComments)
    local trimmed = M.trim(rawLine)
    if trimmed == "" then
        return "", ""
    end

    -- 1. 줄 전체가 주석으로 시작하는 경우
    for _, prefix in ipairs(commentPrefixes) do
        if trimmed:sub(1, #prefix) == prefix then
            return "", M.trim(trimmed:sub(#prefix + 1))
        end
    end

    -- 2. 인라인 주석(줄 중간 주석) 처리
    if inlineComments then
        local earliestPos = nil
        local matchedPrefixLen = 0

        for _, prefix in ipairs(commentPrefixes) do
            -- plain=true 로 정규표현식 특수문자 이스케이프 없이 안전하게 탐색
            local pos = rawLine:find(prefix, 1, true)
            if pos and (not earliestPos or pos < earliestPos) then
                earliestPos = pos
                matchedPrefixLen = #prefix
            end
        end

        if earliestPos then
            local body = M.trim(rawLine:sub(1, earliestPos - 1))
            local comment = M.trim(rawLine:sub(earliestPos + matchedPrefixLen))
            return body, comment
        end
    end

    return trimmed, ""
end

-- =========================================================================
-- 1. INI 파일 공통 파싱 함수
-- =========================================================================
-- path: INI 파일 경로
-- opts: 선택 옵션 테이블
--   - commentPrefixes (table): 주석 기호 목록 (기본값: { "#" })
--   - inlineComments (boolean): 줄 중간 주석 분리 여부 (기본값: true)
--   - skipEmptyValues (boolean): 값이 비어 있는 항목 제외 여부 (기본값: true)
-- 반환값:
--   성공 시: { sections = { [sec] = { {key, value, comment}, ... } }, map = { [sec] = { [lowerKey] = value } } }, nil
--   실패 시: nil, 에러 메시지
function M.parse(path, opts)
    opts = opts or {}
    local commentPrefixes = opts.commentPrefixes or { "#" }
    local inlineComments = (opts.inlineComments ~= false)
    local skipEmptyValues = (opts.skipEmptyValues ~= false)

    local file, openErr = io.open(path, "r")
    if not file then
        return nil, openErr or ("INI 파일을 열 수 없습니다: " .. tostring(path))
    end

    local result = {
        sections = {},
        map = {},
    }

    local currentSection = nil

    for rawLine in file:lines() do
        local body, comment = splitBodyAndComment(rawLine, commentPrefixes, inlineComments)

        if body ~= "" then
            local sec = body:match("^%[(.-)%]$")
            if sec then
                currentSection = M.trim(sec)
                if not result.sections[currentSection] then
                    result.sections[currentSection] = {}
                    result.map[currentSection] = {}
                end
            elseif currentSection then
                local k, v = body:match("^(.-)=(.*)$")
                if k and v then
                    k = M.trim(k)
                    v = M.trim(v)

                    if k ~= "" and (not skipEmptyValues or v ~= "") then
                        table.insert(result.sections[currentSection], {
                            key = k,
                            value = v,
                            comment = comment,
                        })
                        -- 대소문자 구분 없이 빠르게 조회할 수 있도록 소문자 키로도 저장
                        result.map[currentSection][k:lower()] = v
                    end
                end
            end
        end
    end

    file:close()
    return result, nil
end

-- =========================================================================
-- 2. INI 파일 내 특정 섹션의 키-값 갱신 함수 (기존 주석 및 서식 유지)
-- =========================================================================
-- path: INI 파일 경로
-- sectionName: 대상 섹션 이름 (예: "Settings")
-- keyName: 갱신할 키 이름 (예: "useParentBaseDir")
-- newValue: 저장할 값 (boolean, number, string 모두 문자열로 변환)
-- opts: 선택 옵션 테이블 (commentPrefixes 등)
function M.updateKey(path, sectionName, keyName, newValue, opts)
    opts = opts or {}
    local commentPrefixes = opts.commentPrefixes or { "#" }

    local valueStr
    if type(newValue) == "boolean" then
        valueStr = newValue and "true" or "false"
    else
        valueStr = tostring(newValue)
    end

    local keyLowerTarget = keyName:lower()

    local file = io.open(path, "r")
    if not file then
        return false
    end

    local lines = {}
    local inTargetSection = false
    local sectionExists = false
    local insertIndex = nil
    local updated = false

    for line in file:lines() do
        local trimmed = M.trim(line)
        local section = trimmed:match("^%[(.-)%]$")

        if section then
            -- 대상 섹션이 끝나기 직전 위치를 기록해 두어 키가 없을 때 삽입 위치로 활용
            if inTargetSection and not updated then
                insertIndex = #lines + 1
            end
            inTargetSection = (M.trim(section) == sectionName)
            if inTargetSection then
                sectionExists = true
            end
            table.insert(lines, line)
        elseif inTargetSection then
            local isComment = false
            for _, prefix in ipairs(commentPrefixes) do
                if trimmed:sub(1, #prefix) == prefix then
                    isComment = true
                    break
                end
            end

            if not isComment then
                local k = trimmed:match("^(.-)%s*=")
                if k and M.trim(k):lower() == keyLowerTarget then
                    table.insert(lines, keyName .. " = " .. valueStr)
                    updated = true
                else
                    table.insert(lines, line)
                end
            else
                table.insert(lines, line)
            end
        else
            table.insert(lines, line)
        end
    end
    file:close()

    -- 기존 INI에 해당 항목이 없었다면 대상 섹션 하단에 추가
    if not updated then
        if sectionExists then
            if insertIndex then
                table.insert(lines, insertIndex, keyName .. " = " .. valueStr)
            else
                table.insert(lines, keyName .. " = " .. valueStr)
            end
        else
            table.insert(lines, "")
            table.insert(lines, "[" .. sectionName .. "]")
            table.insert(lines, keyName .. " = " .. valueStr)
        end
    end

    local out = io.open(path, "w")
    if out then
        out:write(table.concat(lines, "\n") .. "\n")
        out:close()
        return true
    end
    return false
end

return M
