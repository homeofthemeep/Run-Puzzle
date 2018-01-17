-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar(display.HiddenStatusBar)
-- Your code here

local physics = require("physics")
local kernelSetup = require("kernelSetup")

physics.start()
--physics.setDrawMode("hybrid")
physics.setGravity(0,10)

kernelSetup.funcInit()


local function preCollisionEvent( self, event )
 
   local collideObject = event.other
   if (self ~= nil or event.other ~= nil) then
	   if ( self.collType == "noCollide" ) then
	   		if (event.contact ~= nil) then
	      		event.contact.isEnabled = false  -- Disable this specific collision
	      	end
	   end
	end
end

local score = 0


--local strTester = "intVar = " .. intVar	.. "\nfloatVar = " .. floatVar

-- floorRect will be the collidable floor that the player interacts with
local floorRect = display.newRect(display.contentCenterX, display.contentCenterY + 35, 300, 1)
floorRect.isVisible = false

-- Setup for the floor rectangle
physics.addBody(floorRect, "static", {friction = 0.5, bounce = 0.0})
floorRect.myName = "floor"

-- Setup options for imgGround texture, player's spritesheet, and the sequence for the player's running animation
local gfxRoadOptions =
{
    --required parameters
    width = 512,
    height = 512,
    numFrames = 1,
     
    --optional parameters; used for scaled content support
    sheetContentWidth = 512,  -- width of original 1x size of entire sheet
    sheetContentHeight = 512   -- height of original 1x size of entire sheet
}

local gfxRunnerOptions = 
{
	width = 33,
	height = 83,
	numFrames = 10,

	sheetContentHeight = 83,
	sheetContentWidth = 330
}

local sequenceData =
{
    name="walking",
    start=1,
    count=10,
    time=400,
    loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
}



-- Add these images in
local imgBG = display.newImage("sbackground.png", 0,0, display.contentWidth, display.contentHeight)

local imgFade = display.newImage("fade.png", 0 , 0, display.contentWidth, display.contentHeight)

local gfxRoad =  graphics.newImageSheet("path_long.png", gfxRoadOptions)

local gfxRunner = graphics.newImageSheet("spritesheet_run.png",gfxRunnerOptions )

local imgGround = display.newImage(gfxRoad, 1)

local imgClouds = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)
local imgClouds2 = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)
local imgClouds3 = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)







-- spriteRunner will be known as the character that the player controls
local spriteRunner = display.newSprite(gfxRunner, sequenceData)
spriteRunner.x = display.contentCenterX
spriteRunner.y = display.contentCenterY	
spriteRunner:play()





local puzPiece1 = display.newRect(spriteRunner.x, spriteRunner.y, 32, 32)
local puzPiece1Coll = display.newRect(puzPiece1.x, puzPiece1.y, 32, 32)
local puzPiece1z = 0
puzPiece1Coll.isVisible = false
local bInFlight = false
--physics.addBody(puzPiece1Coll, "dyanmic", {friction = 0.5, bounce = 0.5})
--puzPiece1Coll.myName = "puzzle piece"




local basket = display.newRect(display.contentCenterX, display.contentCenterY*.5, 16,16)
physics.addBody(basket, "static")
basket.myName = "basket"



-- Make the character interact with "physics" objects
physics.addBody(spriteRunner, "dynamic", {friction = 0.5, bounce = 0.0})

spriteRunner.myName = "Runner"

--physics.addBody(puzPiece1, "dyanmic", {friction = 0.5, bounce = 0.0})
--puzPiece1.myName = "puzzle piece"

-- The purpose of funcInit() is to initialize a lot of variable and set them up to my desired effect with the
-- ability to hide some of it away, so it does not clutter up the code
function funcInit()
	-- Mostly this sets up the ground texture to look angled and ready to for shader processing 
	imgBG.fill.effect = "filter.custom.uv_scroll2"

	imgGround.x = display.contentCenterX
	imgGround.y = display.contentCenterY	- 64
	imgGround:scale(0.5,0.5)

	imgGround.path.x1 = imgGround.path.x1 + 192
	imgGround.path.x4 = imgGround.path.x4 - 192
	imgGround.path.y1 = imgGround.path.y1 + 256
	imgGround.path.y4 = imgGround.path.y4 + 256

	imgGround.fill.effect = "filter.custom.uv_scroll"

	imgClouds:scale(0.5,0.5)

	imgClouds.path.x1 = imgClouds.path.x1 + 192
	imgClouds.path.x4 = imgClouds.path.x4 - 192
	imgClouds.path.y1 = imgClouds.path.y1 + 256
	imgClouds.path.y4 = imgClouds.path.y4 + 256

	--imgClouds.alpha = 0.25
	imgClouds.fill.effect = "filter.custom.uv_scroll3"
	

	imgClouds2:scale(0.5,0.5)

	imgClouds2.path.x1 = imgClouds.path.x1 + 192
	imgClouds2.path.x4 = imgClouds.path.x4 - 192
	imgClouds2.path.y1 = imgClouds.path.y1 + 256
	imgClouds2.path.y4 = imgClouds.path.y4 + 256

	--imgClouds.alpha = 0.25
	

	imgClouds3.fill.effect = "filter.custom.uv_scroll4"

	imgClouds3:scale(0.5,0.5)

	imgClouds3.path.x1 = imgClouds.path.x1 + 192
	imgClouds3.path.x4 = imgClouds.path.x4 - 192
	imgClouds3.path.y1 = imgClouds.path.y1 + 256
	imgClouds3.path.y4 = imgClouds.path.y4 + 256

	--imgClouds.alpha = 0.25
	

	imgClouds3.fill.effect = "filter.custom.uv_scroll5"

end




-- This bReleased is a boolean that determines whether or not 
local bReleased = true
local bGrounded = false


-- this funciton handles touch events
function funcTouch(event)
	
	--local anchorY = event.y

	local swipeLengthY = event.yStart - event.y
	local swipeLengthX = event.xStart - event.x

	local xNorm = 0.0
	local yNorm = 0.0

	if (math.abs(swipeLengthX) > math.abs(swipeLengthY)) then
		if(swipeLengthX < 0) then
			xNorm = -1.0
			yNorm = swipeLengthY/math.abs(swipeLengthX)
		else
			xNorm = 1.0
			yNorm = swipeLengthY/math.abs(swipeLengthX)
		end
	else
		if(swipeLengthY < 0) then
			yNorm = -1.0
			xorm = swipeLengthX/math.abs(swipeLengthY)
		else
			yNorm = 1.0
			xNorm = swipeLengthX/math.abs(swipeLengthY)
		end
	end



	if (event.phase == "began") then
		--if the touch has just begun we create a joint where the user clicked (coordinates of our finger)
		--fullscreenControl = physics.newJoint("touch", fullscreenRect, event.x, event.y)
		return true
	elseif (event.phase == "moved") then
		--if the touch is moving then we update the coordinates of our touch...
		--so the box follows our finger as it moves
		if(swipeLengthY > 0) then
			if (bReleased == true) then
				if (bGrounded == true) then
					
					spriteRunner:applyForce(0,-15,spriteRunner.x, spriteRunner.y)
					bReleased = false
				end
			end
		end
		return true
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		--If the touch joing has eneded or is cancelled then we remove the joint
		--fullscreenControl:removeSelf()
		--fullscreenControl = nil
		bReleased = true
		if(swipeLengthY < 10) then
			
			
			
			bInFlight =  true
			puzPiece1.y = spriteRunner.y -84
			physics.addBody(puzPiece1, "dyanmic", {friction = 0.5, bounce = 0.0})
			puzPiece1.myName = "puzzle piece"

			--physics.addBody(puzPiece1Coll, "dyanmic", {friction = 0.5, bounce = 0.5})
			puzPiece1:applyForce(5*xNorm, 5*yNorm, puzPiece1.x, puzPiece1.y)
		end
		return false
	end
end


local function funcCollision(self, event)

	if (event.phase == "began") then
		if(event.other.myName == "floor") then
			bGrounded = true
		end
		if((self.myName == "puzzle piece" and event.other.myName == "Runner") or (self.myName == "Runner" and event.other.myName == "puzzle piece")) then
			event.contact.isEnabled = false
		end
		print(self.myName .. " and " .. event.other.myName .. " has collidded and depth of piece is: " .. puzPiece1z)
		if(self.myName == "puzzle piece" and event.other.myName == "basket") or (self.myName == "basket" and event.other.myName == "puzzle piece")then
			event.contact.isEnabled = false
		elseif(self.myName == "puzzle piece" and event.other.myName == "basket" and  puzPiece1z >= .6) or (self.myName == "basket" and event.other.myName == "puzzle piece" and  puzPiece1z >= .6)then
			physics.removeBody(puzPiece1)
			puzPiece1.isVisible = false
			score = score + 10
		end

	end
	if (event.phase == "ended") then
		if(event.other ~= nil) then
			if(event.other.myName == "floor") then
				bGrounded = false
			end
		end
	end
end

local function funcTester(event)
	--print(bGrounded)
	if(bInFlight == false) then
		puzPiece1.x = spriteRunner.x
		puzPiece1.y = spriteRunner.y
	elseif(bInFlight == true) then 
		puzPiece1:scale(0.99,0.99)
		puzPiece1z = puzPiece1z + 0.01
	end

	puzPiece1Coll.x = puzPiece1.x
	puzPiece1Coll.y = puzPiece1.y

end


local function funcAccelerate( event )
    print( event.xGravity)
    spriteRunner.x = display.contentCenterX + (270 * event.xGravity)

end



funcInit()

spriteRunner.collision = funcCollision
spriteRunner:addEventListener("collision")
basket.collision = funcCollision
basket:addEventListener("collision")
Runtime:addEventListener("touch", funcTouch)
Runtime:addEventListener("enterFrame", funcTester)
Runtime:addEventListener( "accelerometer", funcAccelerate )