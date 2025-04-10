------------------------------------------------------------f--------------------
-- 이동 , 삭제 편의 기능 

-- delete ⬅️
hs.hotkey.bind({"cmd","shift"},"[", 
  function() fastKeyStroke({}, "delete") end,
  nil,
  function() fastKeyStroke({}, "delete") end
)

-- delete ⬅️
hs.hotkey.bind({"cmd","shift"},"o", 
  function() fastKeyStroke({}, "delete") end,
  nil,
  function() fastKeyStroke({}, "delete") end
)

-- forwarddelete ➡️
hs.hotkey.bind({"cmd","shift"},"]",
  function() fastKeyStroke({}, "forwarddelete") end,
  nil,
  function() fastKeyStroke({}, "forwarddelete") end
)

-- forwarddelete ➡️
hs.hotkey.bind({"cmd","shift"},"p",
  function() fastKeyStroke({}, "forwarddelete") end,
  nil,
  function() fastKeyStroke({}, "forwarddelete") end
)


-- forwarddelete ➡️
hs.hotkey.bind({"shift"},"delete", 
  function() fastKeyStroke({}, "forwarddelete") end,
  nil,
  function() fastKeyStroke({}, "forwarddelete") end
)

------------------------------------------------------------f--------------------

-- pageUp
hs.hotkey.bind({"cmd","shift"},"i",
  function() fastKeyStroke({}, "pageup") end,
  nil,
  function() fastKeyStroke({}, "pageup") end
)

--  (shift키)
hs.hotkey.bind({"cmd","ctrl","shift"},"i",
  function() fastKeyStroke({"shift"}, "pageup") end,
  nil,
  function() fastKeyStroke({"shift"}, "pageup") end
)

-- pagedown 
hs.hotkey.bind({"cmd","shift"},"n",
  function() fastKeyStroke({}, "pagedown") end,
  nil,
  function() fastKeyStroke({}, "pagedown") end
)

--  (shift키)
hs.hotkey.bind({"cmd","ctrl","shift"},"n",
  function() fastKeyStroke({"shift"}, "pagedown") end,
  nil,
  function() fastKeyStroke({"shift"}, "pagedown") end
)


------------------------------------------------------------f--------------------

-- word backward
hs.hotkey.bind({"cmd","shift"},"h",
  function() fastKeyStroke({"alt"}, "left") end,
  nil,
  function() fastKeyStroke({"alt"}, "left") end
)

-- word backward (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"h",
  function() fastKeyStroke({"alt","shift"}, "left") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "left") end
)

-- word forward
hs.hotkey.bind({"cmd","shift"},"l",
  function() fastKeyStroke({"alt"}, "right") end,
  nil,
  function() fastKeyStroke({"alt"}, "right") end
)

-- word forward (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"l",
  function() fastKeyStroke({"alt","shift"}, "right") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "right") end
)

------------------------------------------------------------f--------------------

-- down 
hs.hotkey.bind({"cmd","shift"},"j",
  function() fastKeyStroke({}, "down") end,
  nil,
  function() fastKeyStroke({}, "down") end
)

-- down (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"j",
  function() fastKeyStroke({"shift"}, "down") end,
  nil,
  function() fastKeyStroke({"shift"}, "down") end
)


-- up
hs.hotkey.bind({"cmd","shift"},"k",
  function() fastKeyStroke({}, "up") end,
  nil,
  function() fastKeyStroke({}, "up") end
)

-- up (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"k",
  function() fastKeyStroke({"shift"}, "up") end,
  nil,
  function() fastKeyStroke({"shift"}, "up") end
)



