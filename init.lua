hs.dockicon.hide() -- Dock 아이콘은 숨기되 macOS WindowServer에 일반 앱 레벨 등록

------------------------------------------------------------------
-- 1. 공용 유틸 및 중앙 모드 관리자 로드 (반드시 다른 모드들보다 먼저 로드)
------------------------------------------------------------------
require('lamune_common')                 -- 공용기능 정의
ModeManager = require('mode_manager')    -- 중앙 모드 관리자

------------------------------------------------------------------
-- 2. 기능 및 입력/특수 모드 모듈 로드 (각 모듈이 ModeManager에 자동 등록됨)
------------------------------------------------------------------
require('lamune_kor')                    -- 한영 입력 모드 ("eng", "kor")
require('lamune_window')                 -- 프로그램 창 제어 기능
require('lamune_function')               -- 실행하고자 하는 특수 기능들을 정의
require('lamune_modifier')               -- 세부(왼/오 Modifier/ 다중클릭) 기능 구현

-- vim 키 / 숫자 키패드 모드
require('lamune_vim_simple')             -- 커서 이동 모드 ("cursor")
require('lamune_vim_number_keypad')      -- 숫자 키패드 모드 ("keypad")

-- 파일 관리 모드
local quickFiler = require('quick_filer') -- 파일 복사, 이동, 삭제 ("filer")
quickFiler.init()

-- 외부 유틸리티
require('ego_image_downloader')          -- ego browser 이미지 다운로더 실행 hot key

------------------------------------------------------------------
-- 3. 단축키 지정
------------------------------------------------------------------
require('lamune_hotkey_mapping')         -- 단축키 지정 : App, 입력 매크로 기능

-- [선택] 비상 초기화 단축키 (모든 모드 강제 종료 후 영문 복귀)
-- 필요 시 주석을 해제하고 원하는 단축키로 변경해 사용하세요.
-- hs.hotkey.bind({"cmd", "ctrl", "alt"}, "escape", function()
--     ModeManager.reset()
-- end)

------------------------------------------------------------------
-- 4. 초기 모드 설정 (기본 시작은 영문)
------------------------------------------------------------------
ModeManager.switch("eng", { force = true, silent = true })

-- 완료 메세지 출력
print('Hammerspoon Load Finished!')
hs.alert.show('Hammerspoon Load Finished!')
