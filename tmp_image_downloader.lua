
-- seconds: 기다릴 시간 (초 단위, 소수점 가능)
-- callback: 시간이 지난 후 실행할 함수
local function asyncDelay(seconds, callback)
    hs.timer.doAfter(seconds, function()
        if callback then callback() end
    end)
end

-- 로그 출력을 위한 로거 인스턴스 생성 (콘솔에서 'Macro' 태그로 검색 가능)
local logger = hs.logger.new("Macro", "info")
-- 매크로 상태 관리를 위한 전역/지역 변수
local macroTimer = nil
local startNum = 0
local endNum = 0
local currentNum = 0
local currentStep = 1
local timeElapsed = 0

local isPaused = false -- 일시정지 상태를 체크하는 변수

-- 타이머가 매초마다 실행하며 단계를 체크할 함수
local function macroTick()

    -- 일시정지 상태라면 아래 로직을 수행하지 않고 그냥 넘어감 (대기 시간 정지 효과)
    if isPaused then return end

    -- 현재 번호가 마지막 번호를 초과하면 타이머 종료
    if currentNum > endNum then
        logger.i("🔄 지정한 범위의 매크로 반복 완료!")
        playAlarmMusic()
        if macroTimer then
            macroTimer:stop()
            macroTimer = nil
        end
        return
    end

    -- [스텝 1] 5초 대기 , 포커스 이동
    if currentStep == 1 then
        timeElapsed = timeElapsed + 1
        if timeElapsed >= 3 then
            
            -- 알람
            hs.alert.show("매크로 Wake")
            -- hs.timer.usleep(2*100000)

            -- 현재 위치를 저장하고 매크로를 수행할 창으로 포커스 이동
            saveWindowStateAndMouse("Current")
            restoreWindowStateAndMouse("Macro1")

            -- 다음 스텝으로 전환 및 시간 초기화
            currentStep = currentStep + 1
            timeElapsed = 0
        end

    -- 이미지 다운로드 
    elseif currentStep == 2 then
        timeElapsed = timeElapsed + 1
        if timeElapsed >= 0 then

            -- 이미지 다운로드
            download_image()
            --runAfterDelay ( 1 , hs.eventtap.keyStroke({"cmd", "ctrl"}, "/") )
            -- hs.eventtap.keyStroke({"cmd", "ctrl"}, "/")

            -- 다음 스텝으로 전환 및 시간 초기화
            currentStep = currentStep + 1
            timeElapsed = 0

            -- -- 원래 창의 위치로 복귀
            -- restoreWindowStateAndMouse("Current")
        end

    -- 3초 대기
    elseif currentStep == 3 then
        timeElapsed = timeElapsed + 1
        if timeElapsed >= 3 then

            -- -- 현재 위치를 저장하고 매크로를 수행할 창으로 포커스 이동
            -- saveWindowStateAndMouse("Current")
            -- restoreWindowStateAndMouse("Macro1")
            
            -- 한 회차가 완전히 끝났으므로 다음 회차 준비
            currentStep = currentStep + 1
            timeElapsed = 0
        end

    -- 페이지 이동 
    elseif currentStep == 4 then
        timeElapsed = timeElapsed + 1
        if timeElapsed >= 0 then

            -- 오른쪽 키 입력
            hs.eventtap.keyStroke({}, "right")
            hs.eventtap.keyStroke({}, "right")
            
            -- 한 회차가 완전히 끝났으므로 다음 회차 준비
            currentNum = currentNum + 1
            currentStep = 1
            timeElapsed = 0

            -- 다음 번호가 범위 내에 있다면 로그 출력
            if currentNum <= endNum then
                logger.i(string.format("▶️ [%d번] 매크로 실행 중... (목표: %d번까지)", currentNum, endNum))
            end

            -- 알람
            hs.alert.show("매크로 Sleep")

            -- 원래 창의 위치로 복귀
            restoreWindowStateAndMouse("Current")
        end

    end    
end

-- 매크로 일시정지 / 재개 토글 함수
local function togglePause()
    -- 매크로가 실행 중이지 않을 때는 아무 동작도 하지 않음
    if not macroTimer then return end

    isPaused = not isPaused -- 상태 반전

    if isPaused then
        logger.i(string.format("⏸️ 매크로 일시정지 (현재 %d번 진행 중, 스텝 %d)", currentNum, currentStep))
        hs.alert.show("⏸️ 매크로 일시정지")
    else
        logger.i(string.format("▶️ 매크로 재개 (이어서 실행)", currentNum))
        hs.alert.show("▶️ 매크로 재개")
    end
end

-- 매크로 시작 함수 (시작 번호와 마지막 번호를 차례로 입력받음)
local function startMacro()
    if macroTimer then
        macroTimer:stop()
        macroTimer = nil
    end

    -- 일시정지 상태 초기화
    isPaused = false

    -- 현재 창과 마우스 커서 위치 저장
    saveWindowStateAndMouse("Macro1")

    -- 1. 시작 번호 입력 받기
    local btnStart, txtStart = hs.dialog.textPrompt(
        "매크로 범위 설정 (1/2)", 
        "시작할 번호를 입력하세요:", 
        "1", 
        "다음", 
        "취소"
    )
    if btnStart ~= "다음" then return end
    local numStart = tonumber(txtStart)

    -- 2. 마지막 번호 입력 받기
    local btnEnd, txtEnd = hs.dialog.textPrompt(
        "매크로 범위 설정 (2/2)", 
        "마지막 번호를 입력하세요:", 
        "100", 
        "시작", 
        "취소"
    )

    restoreWindowStateAndMouse("Macro1")

    if btnEnd ~= "시작" then return end
    local numEnd = tonumber(txtEnd)

    -- 입력값 유효성 검사 (숫자이고, 시작 번호가 마지막 번호보다 작거나 같아야 함)
    if numStart and numEnd and numStart > 0 and numEnd >= numStart then
        startNum = numStart
        endNum = numEnd
        currentNum = numStart
        currentStep = 1
        timeElapsed = 0
        
        logger.i(string.format("🚀 매크로 시작 (범위: %d번 ~ %d번)", startNum, endNum))
        logger.i(string.format("▶️ [%d번] 매크로 실행 중... (목표: %d번까지)", currentNum, endNum))
        
        -- 1초마다 상태를 체크하는 타이머 구동
        macroTimer = hs.timer.new(1, macroTick)
        macroTimer:start()
    else
        logger.e("❌ 올바른 숫자를 입력해주세요. (시작 번호는 마지막 번호보다 작거나 같아야 합니다)")
        hs.alert.show("❌ 입력 값이 올바르지 않습니다.")
    end
end

-- 핫키 지정 (예: option + shift + R 누르면 입력창이 뜸)
-- 원하시는 단축키 조합이 있다면 아래 {"alt", "shift"}, "r" 부분을 수정하세요.
hs.hotkey.bind({"cmd", "ctrl"}, "'", startMacro)
hs.hotkey.bind({"cmd", "ctrl"}, "p", togglePause)  -- 일시정지 / 재개 토글 (Cmd + Ctrl + P)




--------