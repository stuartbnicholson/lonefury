import 'CoreLibs/sprites'
import 'CoreLibs/geometry'

local gfx = playdate.graphics
local geom = playdate.geometry

-- See OReilly AI for Game Developers
function Vrotate2d(angle, uV)
    local x, y 

	x = uV.x * math.cos(math.rad(-angle)) + uV.y * math.sin(math.rad(-angle));
	y = -uV.x * math.sin(math.rad(-angle)) + uV.y * math.cos(math.rad(-angle));

	return geom.vector2d.new(x, y)
end

-- Assumes 15 degrees angle increments, and an imageTable that contains 7 images, rotated from 0 degrees to 90 in 15 degree steps
ROTATE_SPEED <const> = 15
function SetTableImage(angle, sprite, imgTable)
	-- Flip image table images to save image table space
	if angle <= 90 then
		local i = 1 + (angle / ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i))
	elseif angle <= 180 then
		local i = 7 - ((angle - 90) / ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedY)
	elseif self.angle <= 270 then
		local i = 1 + (angle - 180) / ROTATE_SPEED
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedXY)
	else
		local i = 7 - (angle - 270) / ROTATE_SPEED
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedX)
	end
end