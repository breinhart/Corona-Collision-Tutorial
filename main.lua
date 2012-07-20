-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "storyboard" module
local storyboard = require "storyboard"

-- set the seed for math.random , this ensures that it is ACTUALLY random
math.randomseed(os.time())
math.random()
math.random()
-- load menu screen
storyboard.gotoScene( "gameloop" )
