--------------------------------------------------------    
-- App 실행 단축키 정의
-- cmd + alt + 단축키 

-- 입력에 관한 단축키 
-- cmd + shift + 단축키
-- cmd + ctrl + shift + 단축키
-- cmd + alt + shift + 단축키

-- macro 기능 호출
-- cmd + ctrl +  단축키

--------------------------------------------------------------------------------

-- app관련 편의 기능 ( 특정 앱 에서만 동작 ) 단축키 맵핑
bindForApps({ "chrome", "ego" }, {"cmd", "ctrl"}, "/", download_image)    -- 웹 이미지 다운로드
bindForApps({ "Obsidian" }, {"cmd", "shift"}, "/", obsidian_fn01)    -- 웹 주소 입력
bindForApps({ "Obsidian" }, {"cmd", "shift"}, ".", obsidian_fn02)    -- bsidian local 이미지 -> 웹이미지



-- 단축키 ( 커스텀 기능 호출 )
local keyMappings = {
    
    -- hammerspoon 기능 
    {t="fnc", from = {{"cmd","ctrl","alt"},"r"}, to = reloadHammerSpoon },
    {t="fnc", from = {{"cmd","ctrl","alt"},"i"}, to = runningAppInfo },
    {t="fnc", from = {{"cmd","ctrl","alt"},"F11"}, to = copyMousePosition }, -- 현재 마우스 커서 위치를 클립보드에 복사
    
    -- 키 입력 매크로
    {t="fnc", from = {{"cmd","ctrl","shift"},"y"}, to = keyInput_Todo },
    {t="fnc", from = {{"cmd","ctrl","shift"},"d"}, to = keyInput_date },
    {t="fnc", from = {{"cmd","ctrl","shift"},"t"}, to = keyInput_dateTime },

    -- space 키 기능 할당
    -- {t="app", from = {{'cmd'},"space"},   to = "Gemini" },               -- Spotlight 
    -- {t="fnc", from = {{"cmd","ctrl",},"space"}, to = md_HardSpace },     -- 이모지 선택 창
    {t="app", from = {{'cmd','alt'},"space"},   to = "Gemini" },            -- Gemini 자체 단축키
    {t="app", from = {{'alt'},"space"},   to = "Lokii" },                   -- Enverthing 비슷
    {t="fnc", from = {{"cmd","ctrl","shift"},"space"}, to = md_HardSpace },     -- md 에서 강제 스페이스


    -- 특수키 할당
    {t="app", from = {{'cmd','alt'},"/"},       to = "ForkLift" },          -- File manage 
    {t="app", from = {{'cmd','alt'},"."},       to = "Finder" },            -- 
    {t="app", from = {{'cmd','alt'},","},       to = "qView" },      -- 
    --{t="app", from = {{'cmd','alt'},"esc"},       to = "None" },          -- 프로그램 강제 종료
    -- {t="app", from = {{'cmd','alt'},"a"},       to = "Activity Monitor" },  -- 활성상태 모니터
    -- {t="app", from = {{'cmd','alt'},"a"},       to = "활성 상태 보기" },  -- 활성상태 모니터
    {t="fnc", from = {{'cmd','alt'},"F12"},       to = toggleSystemMute },  -- 소리 묵음 toggle 

    -- 숫자키 할당
    {t="app", from = {{'cmd','alt'},"1"},       to = "Microsoft To Do" },   -- TO DO 할일 
    {t="app", from = {{'cmd','alt'},"2"},       to = "Obsidian" },          -- info Manager
    {t="app", from = {{'cmd','alt'},"3"},       to = "Spark" },             -- Email postoffice 
    {t="app", from = {{'cmd','alt'},"9"},       to = "Terminal" },          -- Terminer
    {t="app", from = {{'cmd','alt'},"0"},       to = "iTerm" },             -- Terminer
    
    --- 영문 키
    {t="app", from = {{'cmd','alt'},"a"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"b"},       to = "None" },             -- None
        {t="app", from = {{'cmd','alt'},"c"},       to = "Code" },              -- Code editor 
    {t="app", from = {{'cmd','alt'},"d"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"e"},       to = "None" },             -- None
    --{t="app", from = {{'cmd','alt'},"f"},       to = "None" },             -- None    vscode bookmark short key
    {t="app", from = {{'cmd','alt'},"g"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"h"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"i"},       to = "None" },             -- None
    -- {t="app", from = {{'cmd','alt'},"j"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"k"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"l"},       to = "None" },             -- None   vscode bookmark short key
    {t="app", from = {{'cmd','alt'},"m"},       to = "Sublime Text" },             -- Sublime Text
    {t="app", from = {{'cmd','alt'},"n"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"o"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"p"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"q"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"r"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"s"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"t"},       to = "None" },              -- None
    {t="app", from = {{'cmd','alt'},"u"},       to = "None" },             -- None
    --{t="app", from = {{'cmd','alt'},"v"},       to = "None" },             -- None   -- vscode 목소리 인식
    {t="app", from = {{'cmd','alt'},"w"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"x"},       to = "ego lite" },             -- internet Browser
    {t="app", from = {{'cmd','alt'},"y"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"z"},       to = "Google Chrome" },             -- internet Browser
    

}

-- 키 바인딩 수행
loadKeyBinding(keyMappings)
 

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- -- 이모지 
--- 함수화 시킬 수 없음 
hs.hotkey.bind({"cmd","ctrl","shift"}, "k", function()
    hs.eventtap.keyStrokes( "⬆️")
  end)
  
  hs.hotkey.bind({"cmd","ctrl","shift"}, "j", function()
    hs.eventtap.keyStrokes( "⬇️")
  end)
  
  hs.hotkey.bind({"cmd","ctrl","shift"}, "h", function()
    hs.eventtap.keyStrokes( "⬅️")
  end)
  
  hs.hotkey.bind({"cmd","ctrl","shift"}, "l", function()
    hs.eventtap.keyStrokes( "➡️")
  end)
  
  hs.hotkey.bind({"cmd","ctrl","shift"}, ".", function()
    hs.eventtap.keyStrokes( "∴")
  end)
  
  hs.hotkey.bind({"cmd","ctrl","shift"}, ",", function()
    hs.eventtap.keyStrokes( "∵")
  end)

  hs.hotkey.bind({"cmd","ctrl","shift"}, "1", function()
    hs.eventtap.keyStrokes( "❗️")
  end)

  hs.hotkey.bind({"cmd","ctrl","shift"}, "/", function()
    hs.eventtap.keyStrokes( "❓")
  end)

  hs.hotkey.bind({"cmd","ctrl","shift"}, "=", function()
    hs.eventtap.keyStrokes( "≒")
  end)


--------------------------------------------------------------------------------