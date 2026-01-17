------------------------------------------------------------f--------------------
-- 이동 , 삭제 편의 기능 

-- delete ⬅️
hs.hotkey.bind({"cmd","alt"},"p", 
  function() fastKeyStroke({}, "delete") end,
  nil,
  function() fastKeyStroke({}, "delete") end
)

-- forward delete ➡️
hs.hotkey.bind({"cmd","alt"},"[",
  function() fastKeyStroke({}, "forwarddelete") end,
  nil,
  function() fastKeyStroke({}, "forwarddelete") end
)


------------------------------------------------------------f--------------------

-- pageUp
hs.hotkey.bind({"cmd","alt"},"u",
  function() fastKeyStroke({}, "pageup") end,
  nil,
  function() fastKeyStroke({}, "pageup") end
)
--  (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"u",
  function() fastKeyStroke({"shift"}, "pageup") end,
  nil,
  function() fastKeyStroke({"shift"}, "pageup") end
)

-- pagedown 
hs.hotkey.bind({"cmd","alt"},"o",
  function() fastKeyStroke({}, "pagedown") end,
  nil,
  function() fastKeyStroke({}, "pagedown") end
)
-- (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"o",
  function() fastKeyStroke({"shift"}, "pagedown") end,
  nil,
  function() fastKeyStroke({"shift"}, "pagedown") end
)


--------------------------------------------------------------------------------

-- word backward
hs.hotkey.bind({"cmd","alt"},"n",
  function() fastKeyStroke({"alt"}, "left") end,
  nil,
  function() fastKeyStroke({"alt"}, "left") end
)
-- (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","alt","shift"},"n",
  function() fastKeyStroke({"alt","shift"}, "left") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "left") end
)

-- word forward
hs.hotkey.bind({"cmd","alt"},"m",
  function() fastKeyStroke({"alt"}, "right") end,
  nil,
  function() fastKeyStroke({"alt"}, "right") end
)
-- (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"m",
  function() fastKeyStroke({"alt","shift"}, "right") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "right") end
)

------------------------------------------------------------f--------------------

-- down 
hs.hotkey.bind({"cmd","alt"},"k",
  function() fastKeyStroke({}, "down") end,
  nil,
  function() fastKeyStroke({}, "down") end
)
-- (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"k",
  function() fastKeyStroke({"shift"}, "down") end,
  nil,
  function() fastKeyStroke({"shift"}, "down") end
)

-- up
hs.hotkey.bind({"cmd","alt"},"i",
  function() fastKeyStroke({}, "up") end,
  nil,
  function() fastKeyStroke({}, "up") end
)
-- (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"i",
  function() fastKeyStroke({"shift"}, "up") end,
  nil,
  function() fastKeyStroke({"shift"}, "up") end
)


-- left 
hs.hotkey.bind({"cmd","alt"},"j",
  function() fastKeyStroke({}, "down") end,
  nil,
  function() fastKeyStroke({}, "down") end
)
-- (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"j",
  function() fastKeyStroke({"shift"}, "down") end,
  nil,
  function() fastKeyStroke({"shift"}, "down") end
)

-- right
hs.hotkey.bind({"cmd","alt"},"l",
  function() fastKeyStroke({}, "up") end,
  nil,
  function() fastKeyStroke({}, "up") end
)
-- (shift키)
hs.hotkey.bind({"cmd","alt","shift"},"l",
  function() fastKeyStroke({"shift"}, "up") end,
  nil,
  function() fastKeyStroke({"shift"}, "up") end
)

