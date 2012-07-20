Terrain = {}
local physicsData = nil
local useHD = nil

function Terrain:init( ) 
	local scale = .5
	-- Get the physics data table from the exported Physics Editor file
	physicsData = (require "platforms").physicsData(scale)

	--Other Initialization code here (such as loading of sprite sheets)
end

local function generateBurgers(data, grp, center)
	--loop through all of the physics objects until we find one with a category bit of 7 (2^7 = 128)
	for i = 1, #data do
		if data[i].filter.categoryBits == 128 then
			--get a random number between 1 and 10000 (inclusive)
			local rand = math.random(1,10000)
			--A 1 in 2 chance that a burger will be in this spot
			if rand <= 5000 then	
				--create our burger image			
				local obj = display.newImageRect("burger_1.png", 44, 44)
				obj:setReferencePoint(display.CenterReferencePoint)
				obj.x = center.x + data[i].shape[3] 
				obj.y = center.y + data[i].shape[4]
				
				local w = obj.width
				--Add a physics body to the burger.  By default, it will collide with everything
				--Make the bouding box a circle with radious of 1/2 width.	
				physics.addBody( obj, "static", {friction = 0, bounce = 0, density = 0, radius = w*.5})
				--This will be a sensor (meaning that box2d will let you pass right through it)
				obj.isSensor = true
				--Our custom property so that we can pick this up in the collision handler
				obj.isBurger = true
				
				--Insert it into the group
				grp:insert(obj)
				
			elseif rand <= 5050 then
				
				local obj = display.newImageRect("multiplier_2.png",42,42)
				obj:setReferencePoint(display.TopLeftReferencePoint)
				obj.x= center.x + data[i].shape[3]
				obj.y = center.y + data[i].shape[4]

				--Make the bouding box a circle with radious of 1/2 width.
				local w = obj.width
				physics.addBody( obj, "static", {friction = 0, bounce = 0, density = 0, radius = w*.5})
				--Again, this is a sensor
				obj.isSensor = true
				--We add properties for the type of "pickup" it is, as well as the pickup value
				obj.isMultiplier = true
				obj.multiNum = 2
				
				--Insert into the group
				grp:insert(obj)	
			end
		end
	end
end

-- Returns a random Platform
function Terrain:randomPlatformInGroup(grp)
	
	--Get a random platform.
	--In this tutorial, we don't need the random element, since there is only 1 platform		
	local obj = display.newImageRect("float-17.png", 555, 133)
	obj:setReferencePoint(display.CenterLeftReferencePoint)
	obj.myName = "float17" --This is the name of the PE object we created.
	--Just an arbitrary starting position for this example.
	obj.x = 10
	obj.y = 150 	
	--Retrieve the physics bodies from the platforms.lua file.
	physics.addBody( obj, "static", physicsData:get(obj.myName))
	grp:insert(obj)
	--Calls our method above in order to create our pickups.
	--We are passing in the center point of this object because the pickup polygons' coordinates are relative to this body.
	generateBurgers( physicsData.data[obj.myName] , grp, {x = obj.x + obj.width/2, y = obj.y} )

	return obj
end

--Given a name and index, returns back the shape data (fixtures) for the other object.
function Terrain:getPhysicsDataForPlatformWithNameAtIndex(name,idx)
	local shapeData = physicsData.data[name]
	if shapeData ~= nil then
		return shapeData[idx]
	end
	return nil
end

return Terrain
