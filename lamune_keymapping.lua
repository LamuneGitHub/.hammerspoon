

--------------------------------------------------------------------------------
--------- Key remapping 라이브러리 로딩
-- local FRemap = require('foundation_remapping')
-- local remapper = FRemap.new()
-- remapper:remap('capslock', 'f14') -- 작동하지 않아서 karabiner의 리맵핑 기능을 사용하였음
-- remapper:remap('fn', 'f') -- 작동하지 않아서 karabiner의 리맵핑 기능을 사용하였음
-- remapper:remap('Application', 'v')
-- remapper:register()
---------

------------------------------------------------------------f--------------------
-- 키보드에 없는 기능키 정의 

-- forwarddelete
hs.hotkey.bind({"shift"},"delete", 
              function() fastKeyStroke({}, "forwarddelete") end,
              nil,
              function() fastKeyStroke({}, "forwarddelete") end
            )

--------------------------------------------------------------------------------
-- 편의 기능

-- delete
hs.hotkey.bind({"cmd","ctrl"},"i", 
  function() fastKeyStroke({}, "delete") end,
  nil,
  function() fastKeyStroke({}, "delete") end
)

-- forwarddelete
hs.hotkey.bind({"cmd","ctrl"},"o",
  function() fastKeyStroke({}, "forwarddelete") end,
  nil,
  function() fastKeyStroke({}, "forwarddelete") end
)

-- pagedown 
hs.hotkey.bind({"cmd","ctrl"},"j",
  function() fastKeyStroke({}, "pagedown") end,
  nil,
  function() fastKeyStroke({}, "pagedown") end
)

-- pageUp
hs.hotkey.bind({"cmd","ctrl"},"k",
  function() fastKeyStroke({}, "pageup") end,
  nil,
  function() fastKeyStroke({}, "pageup") end
)

-- word backward
hs.hotkey.bind({"cmd","ctrl"},"h",
  function() fastKeyStroke({"alt"}, "left") end,
  nil,
  function() fastKeyStroke({"alt"}, "left") end
)
-- word forward
hs.hotkey.bind({"cmd","ctrl"},"l",
  function() fastKeyStroke({"alt"}, "right") end,
  nil,
  function() fastKeyStroke({"alt"}, "right") end
)

-- word backward (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"h",
  function() fastKeyStroke({"alt","shift"}, "left") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "left") end
)
-- word forward (shift키로 단어 선택 이동)
hs.hotkey.bind({"cmd","ctrl","shift"},"l",
  function() fastKeyStroke({"alt","shift"}, "right") end,
  nil,
  function() fastKeyStroke({"alt","shift"}, "right") end
)
