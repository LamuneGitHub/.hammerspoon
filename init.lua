hs.dockicon.hide() -- Dock 아이콘은 숨기되 macOS WindowServer에 일반 앱 레벨 등록

------------------------------------------------------------------

------------------------------------------------------------------

require('lamune_common')        -- 공용기능 정의
require('lamune_kor')           -- 한영 변환
require('lamune_window')        -- 프로그램 창 제어 기능
require('lamune_function')      -- 실행하고자 하는 특수 기능들을 정의
require('lamune_modifier')      -- 세부(왼/오 Modifier/ 다중클릭) 기능 구현

-- vim 키 
--require('lamune_vim')           -- vim 키보드
require('lamune_vim_simple')           -- vim 키보드
require('lamune_vim_number_keypad')           -- 숫자 키패드 키보드

--- 키에 기능 할당
require('lamune_hotkey_mapping')    -- 단축키 지정 : App, 입력 매크로 기능 

-- 기본 시작은 영문
change_eng()

-- 완료 메세지 출력
print ('Hammerspoon Load Finished!')
hs.alert.show('Hammerspoon Load Finished!')require("ego_image_downloader")

-- require('tmp_image_downloader')           -- 이미지 다운로더 실행 hot key
require('ego_image_downloader')           -- ego browser 이미지 다운로더 실행 hot key

require('quick_filer')                    -- 파일 복사 , 이동 , 삭제 
local quickFiler = require("quick_filer")
quickFiler.init()



