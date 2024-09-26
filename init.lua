------------------------------------------------------------------

------------------------------------------------------------------

require('lamune_common')        -- 공용기능 정의
require('lamune_keymapping')    -- 키보드에 없는 키 기능 구현
require('lamune_kor')           -- 한영 변환
require('lamune_window')        -- 프로그램 창 제어 기능

require('lamune_customFnc')     -- 실행하고자 하는 특수 기능들을 정의

require('lamune_AppHotKey')     -- App 실행 단축키
require('lamune_Macro')         -- Marco 입력
require('lamune_modifier')      -- 세부(왼/오 Modifier/ 다중클릭별) 기능 실행 구현

require('lamune_vim')           -- vim 키보드



-- 기본 시작은 영문
change_eng()

-- 완료 메세지 출력
print ('Hammerspoon Load Finished!')
hs.alert.show('Hammerspoon Load Finished!')