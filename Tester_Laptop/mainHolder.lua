-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar(display.HiddenStatusBar)
-- Your code here

local physics = require("physics")
--local transistion = require("transistion")
local kernelSetup = require("kernelSetup")

physics.start()
--physics.setDrawMode("hybrid")
physics.setGravity(0,10)

kernelSetup.funcInit()

local instructions = display.newImageRect("instructions.png", display.contentWidth, display.contentHeight)
instructions.x = display.contentCenterX
instructions.y = display.contentCenterY

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
	width = 32,
	height = 64,
	numFrames = 10,

	sheetContentHeight = 64,
	sheetContentWidth = 320
}

local sequenceData =
{
    name="walking",
    start=1,
    count=10,
    time=500,
    loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
}

local gfxBasketOptions = 
{
	width = 16,
	height = 24,
	numFrames = 5,

	sheetContentHeight = 24,
	sheetContentWidth = 80
}

local basketIdle =
{
    name="idle",
    start=1,
    count=1,
    time=1,
    loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
}

local basketChew = 
{
    name="chewing",
    start=2,
    count=4,
    time=500,
    loopCount = 2,   -- Optional ; default is 0 (loop indefinitely)
    loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
}

-- Add these images in
local imgBG = display.newImage("sbackground.png", 0,0, display.contentWidth, display.contentHeight)

local imgFade = display.newImage("fade.png", 0 , 0, display.contentWidth, display.contentHeight)

local gfxRoad =  graphics.newImageSheet("path_long.png", gfxRoadOptions)

local gfxRunner = graphics.newImageSheet("runnersheet.png",gfxRunnerOptions )

local gfxRedBasket = graphics.newImageSheet("chewsheet_r.png", gfxBasketOptions)
local gfxGreenBasket = graphics.newImageSheet("chewsheet_g.png", gfxBasketOptions)
local gfxBlueBasket = graphics.newImageSheet("chewsheet_b.png", gfxBasketOptions)


local imgGround = display.newImage(gfxRoad, 1)

local imgClouds = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)
local imgClouds2 = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)
local imgClouds3 = display.newImage("clouds_t.png", display.contentCenterX, display.contentCenterY - 64)


local scoreText = display.newText("SCORE: " .. score, display.contentCenterX, display.contentCenterY *1.75, native.systemFont, 32)
scoreText:setFillColor( 0.5, 0.6, 1, 0.75)

-- The basket is the senor on which you score points, they look like white heads
local basket = display.newSprite(gfxRedBasket, {basketIdle, basketChew})
basket.x = display.contentCenterX
basket.y = display.contentCenterY*.5
basket:play()
local basketType = 1
basket:scale(2.0,2.0)
local bBody = false
--physics.addBody(basket, "static")
--basket.myName = "basket"
--basket.isSensor = true


local rand = math.random(-35,35)

--Pickups become pieces and look like pieces too. They "spawn" in randomly one by one
local pickup
local pickupZ = 0.9
local pickupType = math.random(1,3)
pickup = display.newImageRect("piece".. pickupType .. ".png", 32,32)
pickup.x = display.contentCenterX + rand
pickup.y = display.contentCenterY *.75
--physics.addBody(pickup, "static")
pickup:scale(0.25,0.25)
--pickup.isSensor = true
--pickup.isBullet = true
pickup.myName = "pickup"
local pickupDirection -- if the pickup is going left or right or center
if(rand > 0) then
	pickupDirection = 0.25
elseif(rand < 0) then
	pickupDirection = -0.25
else
	pickupDirection = 0
end

-- spriteRunner will be known as the character that the player controls
local spriteRunner = display.newSprite(gfxRunner, sequenceData)
spriteRunner.x = display.contentCenterX
spriteRunner.y = display.contentCenterY	
spriteRunner:play()
-- Make the character interact with "physics" objects
physics.addBody(spriteRunner, "dynamic", {friction = 0.5, bounce = 0.0})
spriteRunner.isFixedRotation = true
spriteRunner.myName = "Runner"

--A piece is the item the player uses to throw along a vector towards the basket to score points
--They look like gems and come in 3 varieties
local piece = display.newImageRect( "piece1.png", 16, 16)
piece:scale(2.0,2.0)
piece.x = spriteRunner.x
piece.y = spriteRunner.y
local pieceZ = 0
local pieceType = 1 -- 1 is red, 2 is blue, 3 is green
local bInFlight = false -- A boolean to soo if the piece is moving in mid-air

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

-- This bReleased is a boolean that determines whether or not the player has released there swipe
-- bGround is a boolean that determines whether or not the player is on the ground
local bReleased = true
local bGrounded = false

-- This function resets the values and positions relating to the pickup
local function funcResetPickup()
	pickup:removeSelf()
	rand = math.random(-35,35)
	pickupType = math.random(1,3)
	pickup = display.newImageRect("piece".. pickupType .. ".png", 32,32)
	pickup.x = display.contentCenterX + rand
	pickup.y = display.contentCenterY *.75
	pickupZ = 0.9
	pickup:scale(0.25,0.25)
	if(rand > 0) then
		pickupDirection = 0.25
	elseif(rand < 0) then
		pickupDirection = -0.25
	else
		pickupDirection = 0
	end
	spriteRunner:toFront()
	piece:toFront()
end

-- this funciton handles touch events
function funcTouch(event)

	-- THIS ALGORITHM NORMALIZES THE VECTOR ON WHICH THE PLAYER PULLS DOWN
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
			xNorm = swipeLengthX/math.abs(swipeLengthY)
		else
			yNorm = 1.0
			xNorm = swipeLengthX/math.abs(swipeLengthY)
		end
	end

	if (math.abs(swipeLengthX) == math.abs(swipeLengthY)) then
		xNorm = 0.0
		yNorm = 0.0
	end

	--Surpisingly this works, but there are a few edge cases which mess with the throwing

	if (event.phase == "began") then
		return true
	elseif (event.phase == "moved") then

		--Check to see if a +vertical swipe is done so the player can jump 
		if(swipeLengthY > 0) then
			if (bReleased == true) then
				if (bGrounded == true) then
					
					spriteRunner:applyForce(0,-10,spriteRunner.x, spriteRunner.y)
					bReleased = false
				end
			end
		end
		return true
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		--Check to see if -vertical swipe is done to throw piece along the vector
		bReleased = true
		if(swipeLengthY < 10 and bInFlight == false and piece.isVisible == true) then
			
			bInFlight =  true
			piece.y = spriteRunner.y -84
			physics.addBody(piece, "dyanmic", {friction = 0.5, bounce = 0.0})
			piece.myName = "puzzle piece"
			piece.isSensor = true
			--physics.addBody(pieceColl, "dyanmic", {friction = 0.5, bounce = 0.5})
			piece:applyForce(1.25*xNorm, 1.25*yNorm, piece.x, piece.y)

		end
		return false
	end
end

local bResetPickup = false

local function funcCollision(self, event)
	if (event.phase == "began") then
		if(event.other.myName == "floor") then
			bGrounded = true
			--If the player is touching the floor then they are on the ground
		end

		if(self.myName == "basket" and event.other.myName == "puzzle piece" and  pieceZ >= .45)then
			--If the basket collides with the piece then add points to score
			basket:setSequence("chewing")
			basket:play()
			piece.isVisible = false			
		end

		--Check to see if the player changes pieces by colliding with a pickup
		if(self.myName == "Runner" and event.other.myName == "pickup" and bInFlight ~= true and pickupZ <= 0.05 ) then
			pieceType = pickupType
			piece:removeSelf()
			piece = display.newImageRect("piece".. pickupType .. ".png", 16,16)
			piece:scale(2.0,2.0)
			bResetPickup = true
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

	spriteRunner.isAwake = true -- Keep checking for collisions on the player

	if(bInFlight == false) then
		--Stop the piece from moving with the player
		piece.x = spriteRunner.x
		piece.y = spriteRunner.y
	elseif(bInFlight == true) then 
		--Make the piece "go farther into the distance"
		piece:scale(0.99,0.99)
		pieceZ = pieceZ + 0.01
	end

	if (pieceZ >= .9) then
		--Say goodbye once the piece has been alive for 1.5 sec
		if(physics.removeBody(basket) ~= nil) then
			physics.removeBody(basket)
			bBody = false
		end
		piece.isVisible = false
		physics.removeBody(piece)
		bInFlight = false
		pieceZ = 0.0
	end
	if (pieceZ >= .45 and bBody == false) then
		physics.addBody(basket, "static")
		basket.myName = "basket"
		basket.isSensor = true
		basket.collision = funcCollision
		basket:addEventListener("collision")
		bBody = true
	end

	if(basket.sequence == "chewing" and basket.isPlaying == false) then
		--If the basket head guy is chewing then make it reappear somewhere else as a rand color
		basket:removeSelf()
		--physics.removeBody(basket)
		if(basketType == pieceType) then
			-- Add 3X points for matching type
			score = score + 30
			scoreText.text = "SCORE: " .. score
		else
			score = score + 10
			scoreText.text = "SCORE: " .. score
		end

		print(score)

		local rand = math.random(1,3)
		if (rand == 1) then 
			basket = display.newSprite(gfxRedBasket, {basketIdle, basketChew})
			basketType = 0
		elseif (rand == 3) then 
			basket = display.newSprite(gfxGreenBasket, {basketIdle, basketChew})
			basketType = 3
		else
			basket = display.newSprite(gfxBlueBasket, {basketIdle, basketChew})
			basketType = 2
		end
		basket:setSequence("idle")
		basket:play()
		basket.x = 2* math.random() * display.contentCenterX
		basket.y = (display.contentCenterY *.5) - math.random(0,80)
		basket:scale(2.0,2.0)
		bBody = false
	end

	pickup:scale(1.01,1.01)
	pickup.y = pickup.y + 0.75
	pickup.x = pickup.x + pickupDirection
	pickupZ = pickupZ - 0.0105

	if(pickupZ <= -0.05) then -- Only add the body after the pickup has been traveling for some time
		pickup:scale(4,4) 
		physics.addBody(pickup, "static")
		pickup:scale(0.25,0.25)
		pickup.isSensor = true
		pickup.myName = "pickup"
	end
	if (pickupZ <= -0.5) or (bResetPickup == true) then
		--Reset the pickup
		funcResetPickup()
		bResetPickup = false
	end

	scoreText:setFillColor( 0.5, 0.6, 1, math.abs(math.sin(event.time/1000))) -- Looks cool

	instructions.alpha = instructions.alpha - 0.0025
	instructions:toFront()

	--ATTENTION!!!
	--ATTENTION!!!
	--ATTENTION!!!
	--ATTENTION!!!

	--spriteRunner.x = display.contentCenterX + (90 * math.sin(event.time/1000)) 

	--ATTENTION!!!
	--ATTENTION!!!
	--ATTENTION!!!

	--this statement is for debug purposes when on a COMPUTER!
	--IN funcAccelerate() IS WHERE THE STATEMENT FOR ACCELEROMETER MOVEMENT IS LOCATED!
	--IF THE PREVIOUS STATEMENT IS COMMENTED OUT YOU ARE READING CODE FOR A MOBILE DEVICE!
end


local function funcAccelerate( event )


    local accel = event.xGravity *2
    if(accel > 1.0 ) then
    	accel = 1.0
    elseif (accel < -1.0) then
    	accel = -1.0
    end

    --ATTENTION!!!
	--ATTENTION!!!
	--ATTENTION!!!

    spriteRunner.x = display.contentCenterX + (90 * accel)

    --ATTENTION!!!
	--ATTENTION!!!
	--ATTENTION!!!

	--This statement is for gameplay when on a MOBILE DEVICE!
	--IN funcTester() IS WHERE THE STATEMENT FOR CONSTRAINED MOVEMENT IS LOCATED!
	--IF THE PREVIOUS STATEMENT IS COMMENTED OUT YOU ARE READING CODE FOR THE COMPUTER!

end


funcInit()

spriteRunner.collision = funcCollision
spriteRunner:addEventListener("collision")
basket.collision = funcCollision
basket:addEventListener("collision")

Runtime:addEventListener("touch", funcTouch)
Runtime:addEventListener("enterFrame", funcTester)
Runtime:addEventListener( "accelerometer", funcAccelerate )local kernel = {category = "filter", name = "uv_scroll"}

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