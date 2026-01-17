--------------------------------------------------------------------------------
-- App 실행 단축키 정의

local appKeyBindings = {
    -- 기능별 할당
    {t="app", from = {{'cmd','alt'},"1"},       to = "Google Chrome" },     -- internet Browser
    {t="app", from = {{'cmd','alt'},"2"},       to = "Spark" },             -- Email postoffice 
    {t="app", from = {{'cmd','alt'},"3"},       to = "Microsoft To Do" },   -- TO DO 할일 
    {t="app", from = {{'cmd','alt'},"4"},       to = "Obsidian" },          -- info Manager
    
    {t="app", from = {{'cmd','alt'},"5"},       to = "qView" },             -- 이미지 뷰어

    {t="app", from = {{'cmd','alt'},"9"},       to = "iTerm" },             -- Terminer
    {t="app", from = {{'cmd','alt'},"0"},       to = "Finder" },            -- finder
    


    ---- space 조합
    {t="app", from = {{'cmd','alt'},"space"},   to = "Perplexity" },           -- AI
    {t="app", from = {{'cmd','alt','ctrl'},"space"},   to = "ChatGpt" },       -- AI Chat Gpt
    
    -- 이름 앞자리로 할당
 
    
    
    
    -- 키보드 위치로 할당
    
    {t="app", from = {{'cmd','alt'},"/"},       to = "ForkLift" },         -- File manage 
    
    
    
    --- 미정의 키
    {t="app", from = {{'cmd','alt'},"a"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"b"},       to = "None" },             -- None
        {t="app", from = {{'cmd','alt'},"c"},       to = "Code" },              -- Code editor 
        {t="app", from = {{'cmd','alt'},"d"},       to = "DeepL" },             -- 사전
    {t="app", from = {{'cmd','alt'},"e"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"f"},       to = "None" },             -- None  
    {t="app", from = {{'cmd','alt'},"g"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"h"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"i"},       to = "None" },             -- None
    -- {t="app", from = {{'cmd','alt'},"j"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"k"},       to = "None" },             -- None   vscode bookmark short key
    -- {t="app", from = {{'cmd','alt'},"l"},       to = "None" },             -- None   vscode bookmark short key
        {t="app", from = {{'cmd','alt'},"m"},       to = "SimpleMind" },        -- Mind map 
    {t="app", from = {{'cmd','alt'},"n"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"o"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"p"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"q"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"r"},       to = "None" },             -- None
        {t="app", from = {{'cmd','alt'},"s"},       to = "Sublime Text" },      -- Txt editor
    {t="app", from = {{'cmd','alt'},"t"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"u"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"v"},       to = "None" },             -- None   -- find 파일이동
    {t="app", from = {{'cmd','alt'},"w"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"x"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"y"},       to = "None" },             -- None
    {t="app", from = {{'cmd','alt'},"z"},       to = "None" },             -- None
    
    
}

-- 키 바인딩 수행
loadKeyBinding(appKeyBindings)
