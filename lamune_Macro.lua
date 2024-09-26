--------------------------------------------------------    
-- Macro

-- 날짜 입력
hs.hotkey.bind({"cmd","shift"}, 'd', function()
    hs.eventtap.keyStrokes(os.date("(%Y-%m-%d)"))
end)

-- T O D O 입력
hs.hotkey.bind({"cmd","shift"}, 't', function()
    hs.eventtap.keyStrokes( "#TODO: ")
end)


-------




-------

local keyMappings = {

    -- 미정의 키 ( ... )
    {t="fnc", from = {{"cmd", "ctrl", "alt"},"r"}, to = reloadHammerSpoon },
    {t="fnc", from = {{"cmd", "ctrl", "alt"},"i"}, to = runningAppInfo },

    {t="key", from = {{"cmd", "shift"},"i"}, to = {{},"delete"} },
    {t="key", from = {{"cmd", "shift"},"o"}, to = {{},"forwarddelete"} },


    {t="fnc", from = {{"cmd", "shift"},"p"}, to = obsidian_fn01 }, -- 
    {t="fnc", from = {{"cmd", "ctrl"},"/"}, to = download_image },

    -- {t="fnc", from = {{"ctrl", },"z"}, to = obsidian_fn02 },
    -- {t="key", from = {{ },"a"}, to = {{"cmd"},"v"} },


    -- {t="fnc", from = {{"cmd", "ctrl"},"a"}, to = noAct },


}
loadKeyBinding( keyMappings )