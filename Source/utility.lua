import 'CoreLibs/sprites'

local gfx = playdate.graphics

-- Assumes 15 degrees angle increments, and an imageTable that contains 7 images, rotated from 0 degrees to 90 in 15 degree steps
ROTATE_SPEED = 15
function SetTableImage(angle, sprite, imgTable)
	-- Flip image table images to save image table space
	if angle <= 90 then
		local i = 1 + (angle // ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i))
	elseif angle <= 180 then
		local i = 7 - ((angle - 90) // ROTATE_SPEED)
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedY)
	elseif angle <= 270 then
		local i = 1 + (angle - 180) // ROTATE_SPEED
		sprite:setImage(imgTable:getImage(i), gfx.kImageFlippedXY)
	else
		local i = 7 - (angle - 270) // ROTATE_SPEED
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

function AngleToDeltaXY(angle)
	return -math.sin(math.rad(angle)), math.cos(math.rad(angle))
end

-- Increments i, wrapping around 1 .. n
function IncWrap(i, n)
	if i >= n then
		i = 1
	else
		i += 1
	end

	return i
end

-- Returns true if the rectangle in world coordinates is near enough to the Viewport to be an active sprite
-- Assumed worldX, worldY is centred on the entities bounding box
function NearViewport(worldX, worldY, width, height)
	local viewX, viewY = WorldToViewPort(worldX, worldY)
	local halfWidth = width >> 1
	local halfHeight = height >> 1

	if viewX >= 0 - halfWidth and viewX <= VIEWPORT_WIDTH + halfWidth then
		if viewY >= 0 - halfHeight and viewY <= VIEWPORT_HEIGHT + halfHeight then
			return true
		end
	end

	return false
end

function WorldToViewPort(worldX, worldY)
	return worldX - ViewPortWorldX + (HALF_VIEWPORT_WIDTH), worldY - ViewPortWorldY + (HALF_VIEWPORT_HEIGHT)
end