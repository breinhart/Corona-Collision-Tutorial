-----------------------------------------------------------------------------------------
--
-- gameloop.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
--physics.setDrawMode("hybrid")
-- Start then immediately pause the physics engine
physics.start() 
physics.pause() 

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local terrain = require("terrainLoader")
local cat = nil

local gameGroup = nil

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

------------------------------------------------------
-- Runtime enterFrame Event handler
------------------------------------------------------
local function mainLoop()
	--We want to follow the cat if he starts to get off the screen.
	if cat.y<-gameGroup.y+1/5*display.contentHeight then 
		gameGroup.y=1/5*display.contentHeight-cat.y 		
	end
	if cat.y>-gameGroup.y+4/5*display.contentHeight then 
		gameGroup.y=4/5*display.contentHeight-cat.y 	
	end
	if cat.x<-gameGroup.x+1/5*display.contentWidth then 
		gameGroup.x=1/5*display.contentWidth-cat.x 
	end
	if cat.x>-gameGroup.x+4/5*display.contentWidth then 
		gameGroup.x=4/5*display.contentWidth-cat.x 
	end
end

------------------------------------------------------
-- Runtime Touch Event handler
------------------------------------------------------
local function onTouch(event)
	if event.phase == "ended" then
		cat:applyForce(0,-3, cat.x, cat.y);
	end
end	
------------------------------------------------------
-- Runtime Accelerometer Event handler
------------------------------------------------------
local function onAccelerate(event)
	local vx, vy = cat:getLinearVelocity()
	cat:setLinearVelocity(-300*event.yGravity, vy)
end


------------------------------------------------------
-- cat collision Event
------------------------------------------------------
local function catCollision(event)
	if event.phase == "began" then	
		--Get the shape that we collided into
		local oShape =  terrain:getPhysicsDataForPlatformWithNameAtIndex(event.other.myName, event.otherElement)
		--If oShape is not nil, we found a platform fixture
		if oShape ~= nil then
			--If it is a "death" block
			if oShape.filter.categoryBits == 1 then
				print("you hit the bottom!!")
				io.flush()
			elseif oShape.filter.categoryBits == 4 then
				print("you hit the top!!!")
				io.flush()
			end
		end
		--Otherwise, we found ourselves a pickup.
		if event.other.isBurger and event.other.isVisible == true then
			event.other.isVisible = false
			print("you ate a burger!!!")
			io.flush()
		end
		if event.other.isMultiplier and event.other.isVisible == true then
			event.other.isVisible = false
			print("you found a multiplier (x"..event.other.multiNum..")!!!")
			io.flush()
		end
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	gameGroup = display.newGroup()
	
	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 255, 255, 255 )
	
	
	--Add a simple Border, so that our cat doesn't go too far out of bounds
	borderCollisionFilter = { categoryBits = 4, maskBits = 2 } 
	borderBody = { friction=0.0, bounce=0.0, filter=borderCollisionFilter }
	 
	local borderTop = display.newRect( -100, -50, 830, 1 )
	borderTop:setFillColor(0)
	physics.addBody( borderTop, "static", borderBody )
	 
	local borderBottom = display.newRect( -100, 420, 830, 1 )
	borderBottom:setFillColor(0)
	physics.addBody( borderBottom, "static", borderBody )
	 
	local borderLeft = display.newRect( -100, -50, 1, 470 )
	borderLeft:setFillColor(0)
	physics.addBody( borderLeft, "static", borderBody )
	 
	local borderRight = display.newRect( 730, -50, 1, 470 )
	borderRight:setFillColor(0)
	physics.addBody( borderRight, "static", borderBody )
	
	--grab ourselves a platform.
	terrain:init()
	local platform = terrain:randomPlatformInGroup(gameGroup)
	
	cat = display.newImageRect("cat_frame1.png", 65, 45)
	cat:setReferencePoint(display.TopLeftReferencePoint)
	cat.x, cat.y = 10, 45
	
	--Lets add a physics body with a basic Square shape.
	physics.addBody( cat, "dynamic",	{
		friction = 0, 
		bounce = 0, 
		density = 0, 
		shape = { 
			-18,-10, --top left
			30,-10,  -- top right
			30,20,   -- bottom right
			-18,20   --bottom left
		},
		filter = { 
			categoryBits = 2, --2^1 = 2
			maskBits = 15 -- 2^0 + 2^1 + 2^2 + 2^3 = 15
		}
	})
	cat.isFixedRotation = true
	cat:addEventListener("collision", catCollision)
	
	
	
	-- all display objects must be inserted into group
	gameGroup:insert( cat )
	gameGroup:insert( borderTop )
	gameGroup:insert( borderBottom )
	gameGroup:insert( borderLeft )
	gameGroup:insert( borderRight )
	
	group:insert(background)
	group:insert(gameGroup)
	
	background:toBack()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	physics.setGravity(-10)
	Runtime:addEventListener("enterFrame", mainLoop)
	Runtime:addEventListener("touch", onTouch)
	Runtime:addEventListener("accelerometer", onAccelerate)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene