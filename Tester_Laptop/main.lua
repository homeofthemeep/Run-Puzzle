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

graphics.defineEffect(kernel)
graphics.defineEffect(kernel2)

display.setDefault( "textureWrapX", "repeat" )
display.setDefault( "textureWrapY", "repeat" )


local function preCollisionEvent( self, event )
 
   local collideObject = event.other
   if (self ~= nil or event.other ~= nil) then
	   if ( self.collType == "noCollide" ) then
	      event.contact.isEnabled = false  -- Disable this specific collision
	   end
	end
end


local score = 0


--local strTester = "intVar = " .. intVar	.. "\nfloatVar = " .. floatVar

-- floorRect will be the collidable floor that the player interacts with
local floorRect = display.newRect(display.contentCenterX, display.contentCenterY + 35, 300, 1)
floorRect.isVisible = false
-- fullscreenRect will be the rectangle that the player interacts with to make their character jump
local fullscreenRect = display.newRect(0,0, display.contentWidth*2, display.contentHeight*2)
fullscreenRect.isVisible = false

-- Setup for the fullscreen rectangle
physics.addBody(fullscreenRect, "static", {friction = 0.5, bounce = 0.0})
fullscreenRect.collType = "noCollide"
fullscreenRect.preCollision = preCollisionEvent
fullscreenRect:addEventListener("preCollision", fullscreenRect)
-- Setup for the floor rectangle
physics.addBody(floorRect, "static", {friction = 0.5, bounce = 0.0})

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
--local imgFlub = display.newImage(gfxTest, 1)
--local imgFlerb = display.newImage(gfxTest, 1)

-- spriteRunner will be known as the character that the player controls
local spriteRunner = display.newSprite(gfxRunner, sequenceData)
spriteRunner.x = display.contentCenterX
spriteRunner.y = display.contentCenterY	
spriteRunner:play()


--local spriteBox = display.newRect(spriteRunner.x,spriteRunner.y,33,84)

-- Make the character interact with "physics" objects
physics.addBody(spriteRunner, "dynamic", {friction = 0.5, bounce = 0.0})

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

	--[[
	imgFlub.x = display.contentCenterX
	imgFlub.y = display.contentCenterY	- 64
	imgFlub:scale(0.5,0.5)

	imgFlub.path.x1 = imgFlub.path.x1 + 192
	imgFlub.path.x4 = imgFlub.path.x4 - 192
	imgFlub.path.y1 = imgFlub.path.y1 + 256
	imgFlub.path.y4 = imgFlub.path.y4 + 256 
	--]]
	--[[
	imgFlub.x = display.contentCenterX
	imgFlub.y = display.contentCenterY	- 64
	imgFlub:scale(0.5,0.5)

	imgFlub.path.x1 = imgFlub.path.x1 + 0
	imgFlub.path.x2 = imgFlub.path.x2 - 320
	imgFlub.path.x3 = imgFlub.path.x3 + 320
	--imgFlub.path.x4 = imgFlub.path.x4 - 320
	imgFlub.path.y1 = imgFlub.path.y1 + 256
	imgFlub.path.y4 = imgFlub.path.y4 + 256
	--]]
end

-- This bReleased is a boolean that determines whether or not 
local bReleased = true

-- this funciton handles touch events
function funcTouch(event)
	
	--local anchorY = event.y

	if (event.phase == "began") then
		--if the touch has just begun we create a joint where the user clicked (coordinates of our finger)
		fullscreenControl = physics.newJoint("touch", fullscreenRect, event.x, event.y)
		return true
	elseif (event.phase == "moved") then
		--if the touch is moving then we update the coordinates of our touch...
		--so the box follows our finger as it moves
		if (bReleased == true) then
			print("Reached ")
			spriteRunner:applyForce(0,-10,spriteRunner.x, spriteRunner.y)
			bReleased = false
		end
		return true
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		--If the touch joing has eneded or is cancelled then we remove the joint
		fullscreenControl:removeSelf()
		fullscreenControl = nil
		bReleased = true
		return false
	end
end


local function funcTester(event)

	
end




funcInit()
Runtime:addEventListener("touch", funcTouch)
Runtime:addEventListener("enterFrame", funcTester)