------------------------------------------------------------------

------------------------------------------------------------------

require('lamune_common')        -- 공용기능 정의
require('lamune_kor')           -- 한영 변환
require('lamune_window')        -- 프로그램 창 제어 기능

--require('lamune_shortcut_move_key')     -- 단축키 지정 : 키보드에 없는 이동 키 구현
require('lamune_shortcut_App')      -- 단축키 지정 : App 실행

require('lamune_func_macro')       -- 실행하고자 하는 특수 기능들을 정의
require('lamune_shortcut_macro')    -- 단축키 지정 : 매크로 기능  


require('lamune_modifier')          -- 세부(왼/오 Modifier/ 다중클릭별) 기능 실행 구현

require('lamune_vim_simple')           -- vim 키보드
--require('lamune_vim')           -- vim 키보드


-- 기본 시작은 영문
change_eng()

-- 완료 메세지 출력
print ('Hammerspoon Load Finished!')
hs.alert.show('Hammerspoon Load Finished!')