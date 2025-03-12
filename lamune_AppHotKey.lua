--------------------------------------------------------------------------------
-- App 실행 단축키 정의

local appKeyBindings = {
    {t="app", from = {{'cmd','alt'},"c"},       to = "Code" },              -- Code editor
    {t="app", from = {{'cmd','alt'},"e"},       to = "Sublime Text" },      -- Txt editor
    {t="app", from = {{'cmd','alt'},"o"},       to = "Obsidian" },          -- info Manage
    {t="app", from = {{'cmd','alt'},"t"},       to = "Microsoft To Do" },   -- Schedule 관리 , To do 할일 
    {t="app", from = {{'cmd','alt'},"m"},       to = "SimpleMind" },        -- Mind map 
    

    {t="app", from = {{'cmd','alt'},"s"},       to = "Spark" },             -- Email postoffice 
    {t="app", from = {{'cmd','alt'},"b"},       to = "Google Chrome" },     -- internet Browser
    {t="app", from = {{'cmd','alt'},"/"},       to = "Finder" },       
    {t="app", from = {{'cmd','alt'},"."},       to = "ForkLift" },         -- File manage 
    {t="app", from = {{'cmd','alt'},","},       to = "iTerm" },             -- Terminer
    {t="app", from = {{'cmd','alt'},"space"},   to = "ChatGpt" },           -- AI Chat Gpt
    {t="app", from = {{'cmd','alt'},"d"},       to = "DeepL" },             -- 사전
    {t="app", from = {{'cmd','alt'},"p"},       to = "Hamana" },        -- 이미지 뷰어
    

    --- 미정의 키
    {t="app", from = {{'cmd','alt'},"a"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"g"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"h"},       to = "None" },             -- None
    -- {t="app", from = {{'cmd','alt'},"j"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"k"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"l"},       to = "None" },             -- None   vscode bookmark short key
    {t="app", from = {{'cmd','alt'},"n"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"r"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"u"},       to = "None" },             -- None
    -- {t="app", from = {{'cmd','alt'},"v"},       to = "None" },             -- None   -- find 파일이동
    {t="app", from = {{'cmd','alt'},"w"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"x"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"y"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"z"},       to = "None" },             -- None
    
}

-- 키 바인딩 수행
loadKeyBinding(appKeyBindings)
