-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar(display.HiddenStatusBar)
-- Your code here

local physics = require("physics")
physics.start()
--physics.setDrawMode("hybrid")
physics.setGravity(0,10)

local kernel = {category = "filter", name = "uv_scroll"}

kernel.isTimeDependent = true

kernel.fragment =  [[
	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		uv.y -= (CoronaTotalTime/2.0);
		return texture2D(CoronaSampler0, uv);
	}

]]

graphics.defineEffect(kernel)


local kernel2 = {category = "filter", name = "uv_scroll2"}

kernel2.isTimeDependent = true

kernel2.fragment =  [[
	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		uv.y -= (CoronaTotalTime/2.25);
		return texture2D(CoronaSampler0, uv);
	}

]]

local kernel3 = {category = "filter", name = "uv_scroll3"}

kernel3.isTimeDependent = true

kernel3.fragment =  [[
	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		uv.y -= (CoronaTotalTime/4.0);
		uv.x -= sin(CoronaTotalTime*1.0)/4.0;
		P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv);
		texColor.a = 0.75;
		return CoronaColorScale( texColor );
	}

]]

graphics.defineEffect(kernel)
graphics.defineEffect(kernel2)
graphics.defineEffect(kernel3)

display.setDefault( "textureWrapX", "repeat" )
display.setDefault( "textureWrapY", "repeat" )


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

local function preCollisionEvent2( self, event )
 
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
-- fullscreenRect will be the rectangle that the player interacts with to make their character jump
--local fullscreenRect = display.newRect(0,0, display.contentWidth*2, display.contentHeight*2)
--fullscreenRect.isVisible = false

-- Setup for the fullscreen rectangle
--physics.addBody(fullscreenRect, "static", {friction = 0.5, bounce = 0.0})
--fullscreenRect.collType = "noCollide"
--fullscreenRect.preCollision = preCollisionEvent
--fullscreenRect:addEventListener("preCollision", fullscreenRect)
-- Setup for the floor rectangle
physics.addBody(floorRect, "static", {friction = 0.5, bounce = 0.0})
floorRect.myName = "floor"

-- Setup options for imgGround texture, player's spritesheet, and the sequence for the player's running animation
local gfxTestOptions =
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

local gfxTest =  graphics.newImageSheet("path_long.png", gfxTestOptions)

local gfxRunner = graphics.newImageSheet("spritesheet_run.png",gfxRunnerOptions )

local imgGround = display.newImage(gfxTest, 1)

local imgClouds = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)
--local imgFlub = display.newImage(gfxTest, 1)
--local imgFlerb = display.newImage(gfxTest, 1)

-- spriteRunner will be known as the character that the player controls
local spriteRunner = display.newSprite(gfxRunner, sequenceData)
spriteRunner.x = display.contentCenterX
spriteRunner.y = display.contentCenterY	
spriteRunner:play()

local puzPiece1 = display.newRect(spriteRunner.x, spriteRunner.y, 32, 32)
local bInFlight = false

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

end

-- This bReleased is a boolean that determines whether or not 
local bReleased = true
local bGrounded = false

-- this funciton handles touch events
function funcTouch(event)
	
	--local anchorY = event.y

	local swipeLengthY = event.yStart - event.y
	local swipeLengthX = event.xStart - event.x

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
		if(swipeLengthY < 0) then
			
			
			
			
			puzPiece1.y = puzPiece1.y -84
			physics.addBody(puzPiece1, "dyanmic", {friction = 0.5, bounce = 0.0})
			puzPiece1.myName = "puzzle piece"
			puzPiece1:applyForce(puzPiece1.x, puzPiece1.y)
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
	if(inFlight == false) then
		puzPiece1.x = spriteRunner.x
		puzPiece1.y = spriteRunner.y
	end

end




funcInit()

spriteRunner.collision = funcCollision
spriteRunner:addEventListener("collision")
Runtime:addEventListener("touch", funcTouch)
Runtime:addEventListener("enterFrame", funcTester)