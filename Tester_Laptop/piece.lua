local piece = {}
print("Piece created")

local image = display.newImageRect( "piece1.png", 16, 16)
piece:scale(2.0,2.0)
local pieceZ = 0
local pieceType = 1 -- 1 is red, 2 is blue, 3 is green
local bInFlight = false -- A boolean to soo if the piece is moving in mid-air

local function funcInit(posX, posY)
	piece.x = posX
	piece.y = posY
end