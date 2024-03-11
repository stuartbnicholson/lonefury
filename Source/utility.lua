import 'CoreLibs/sprites'

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
ROTATE_SPEED = 15
function SetTableImage(angle, sprite, imgTable)
	-- Flip image table images to save image table space
	if angle <= 90 then
		local i = 1 + (angle / ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i))
	elseif angle <= 180 then
		local i = 7 - ((angle - 90) / ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedY)
	elseif angle <= 270 then
		local i = 1 + (angle - 180) / ROTATE_SPEED
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedXY)
	else
		local i = 7 - (angle - 270) / ROTATE_SPEED
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedX)
	end
end

function PointsDistance(x1, y1, x2, y2)
	-- Good old pythagoras
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function PointsAngle(x1, y1, x2, y2)
	local angle = math.deg(math.atan(y2 - y1, x2 - x1))
	angle += 90 -- TODO: Why is this +90 req'd? Something in the way math.atan works? Remove it if you need a circular chaser :)

	if angle < 0 then
		angle += 360
	end

	return angle
end