import 'CoreLibs/sprites'

local gfx = playdate.graphics

-- Assumes 15 degrees angle increments, and an imageTable that contains 7 images, rotated from 0 degrees to 90 in 15 degree steps
ROTATE_SPEED = 15
function SetTableImage(angle, sprite, imgTable)
	local i
	local flip = gfx.kImageUnflipped

	-- Flip image table images to save image table space
	if angle <= 90 then
		i = 1 + (angle // ROTATE_SPEED)
	elseif angle <= 180 then
		i = 7 - ((angle - 90) // ROTATE_SPEED)
		flip = gfx.kImageFlippedY
	elseif angle <= 270 then
		i = 1 + (angle - 180) // ROTATE_SPEED
		flip = gfx.kImageFlippedXY
	else
		i = 7 - (angle - 270) // ROTATE_SPEED
		flip = gfx.kImageFlippedX
	end

	sprite:setImage(imgTable:getImage(i), flip)
	return i, flip
end

function PointsDistance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function VectorDistance(v1, v2)
	return math.sqrt((v2.dx - v1.dx) ^ 2 + (v2.dy - v1.dy) ^ 2)
end

function PointsAngle(x1, y1, x2, y2)
	local angle = math.deg(math.atan(y2 - y1, x2 - x1))
	angle += 90 -- TODO: Why is this +90 req'd? Something in the way math.atan works? Remove it if you need a circular chaser :)

	if angle < 0 then
		angle += 360
	end

	return angle
end

function VectorAngle(vector)
	local angle = math.deg(math.atan(vector.dy, vector.dx))
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
function NearViewport(viewX, viewY, width, height)
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

function ViewPortToWorld(x, y)
	return x + ViewPortWorldX - (HALF_VIEWPORT_WIDTH), y + ViewPortWorldY - (HALF_VIEWPORT_HEIGHT)
end

--[[
-- Borrowed from: https://devforum.play.date/t/tracking-memory-usage-throughout-your-game/1132
local MemoryInit = collectgarbage("count") * 1024
local MemoryUsed = MemoryInit
function MemoryCheck()
	local new <const> = collectgarbage("count") * 1024
	local diff <const> = new - MemoryUsed

	-- still making large numbers of allocations
	if diff > MemoryInit then
		MemoryUsed = new
		return
	end

	-- fine grained memory changes
	if diff > 0 then
		print(string.format("Memory use\t+%dKB (%d bytes)", diff//1024, new - MemoryInit))
	elseif diff < 0 then
		print(string.format("Memory free\t%dKB (%d bytes)", diff//1024, new - MemoryInit))
	end

	MemoryUsed = new
end
]]

function RoundToNearestMultiple(number, multiple)
	local sign = number >= 0 and 1 or -1
	number = math.abs(number)
	local remainder = number % multiple
	if remainder >= multiple / 2 then
		number = number + multiple - remainder
	else
		number = number - remainder
	end
	return sign * number
end
