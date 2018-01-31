local piece = {}
print("Piece created")

local image = display.newImageRect( "piece1.png", 16, 16)
image:scale(2.0,2.0)
local pieceZ = 0
local pieceType = 1 -- 1 is red, 2 is blue, 3 is green
local bInFlight = false -- A boolean to soo if the piece is moving in mid-air

local function funcInit(pPosX, pPosY)
	piece.x = pPosX
	piece.y = pPosY

	
end

local function funcMod(pPosX, pPosY, pDepth, pType, pBInFlight)

	local bBasketFlag = false


	if (pBInFlight == false) then
		if(pPosX ~= nil) then
			piece.x = pPosX
		end
		if(pPosY ~= nil) then
			piece.y = pPosY
		end
	else
		image:scale(0.99,0.99)
		pieceZ =  pieceZ + 0.01
	end

	if(pBInFlight ~= nil) then
		bInFlight = pBInFlight
	end

	if(pDepth ~= nil) then
		pieceZ = pDepth
	end

	

	if(pType ~= nil) then
		pieceType = pType
	end

	if(bBasketFlag == true) then
		return "basket"
	else 
		return nil
	end

end

local function funcUpdate()
	if (pieceZ >= .9) then
		bBasketFlag = true
		--Say goodbye once the piece has been alive for 1.5 sec
		if(physics.removeBody(basket) ~= nil) then
			physics.removeBody(basket)
			bBody = false
		end
		image.isVisible = false
		physics.removeBody(image)
		bInFlight = false
		pieceZ = 0.0
	end
end

local function funcAddForce(pXNormal, pYNormal)
	physics.addBody(image, "dyanmic", {friction = 0.5, bounce = 0.0})
	image.myName = "gem"
	image.isSensor = true
	image:applyForce(1.25*pXNormal, 1.25*pYNormal, piece.x, piece.y)
end

piece.funcMod = funcMod
piece.funcInit = funcInit
piece.funcUpdate = funcUpdate

return piece