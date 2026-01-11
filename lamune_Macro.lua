--------------------------------------------------------    
-- Macro

-- 날짜 입력
hs.hotkey.bind({"cmd","shift"}, 'd', function()
    hs.eventtap.keyStrokes(os.date("(%Y-%m-%d)"))
end)

-- T O D O 입력
hs.hotkey.bind({"cmd","shift"}, 't', function()
    hs.eventtap.keyStrokes( "#TO")
    hs.eventtap.keyStrokes( "DO: ")
end)


-- obsidian space 
hs.hotkey.bind({"cmd","shift"}, 'space', function()
    hs.eventtap.keyStrokes( "$\\quad$")
end)

--------------------------------------------------------  

-- 이모지 
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "k", function()
    hs.eventtap.keyStrokes( "⬆️")
  end)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "j", function()
    hs.eventtap.keyStrokes( "⬇️")
  end)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "h", function()
    hs.eventtap.keyStrokes( "⬅️")
  end)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "l", function()
    hs.eventtap.keyStrokes( "➡️")
  end)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, ".", function()
    hs.eventtap.keyStrokes( "∴")
  end)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, ",", function()
    hs.eventtap.keyStrokes( "∵")
  end)

  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "1", function()
    hs.eventtap.keyStrokes( "❗️")
  end)

  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "/", function()
    hs.eventtap.keyStrokes( "❓")
  end)

  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "=", function()
    hs.eventtap.keyStrokes( "≒")
  end)


---------------------------------------------------------  
-- 단축키 ( 커스텀 기능 호출 )
local keyMappings = {
    {t="fnc", from = {{"cmd", "ctrl", "alt"},"r"}, to = reloadHammerSpoon },
    {t="fnc", from = {{"cmd", "ctrl", "alt"},"i"}, to = runningAppInfo },

    {t="fnc", from = {{"cmd", "shift"},"p"}, to = obsidian_fn01 }, -- 웹 주소 입력

    {t="fnc", from = {{"cmd", "ctrl"},"/"}, to = download_image }, -- 웹 이미지 다운로드
    {t="fnc", from = {{"cmd", "ctrl"},"."}, to = obsidian_fn02 }, -- obsidian local 이미지 -> 웹이미지

    -- {t="fnc", from = {{"ctrl", },"z"}, to = obsdian_fn02 },
    -- {t="key", from = {{ },"a"}, to = {{"cmd"},"v"} },

    -- {t="fnc", from = {{"cmd", "ctrl"},"a"}, to = noAct },
}
loadKeyBinding( keyMappings )