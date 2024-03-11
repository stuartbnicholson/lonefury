local gfx = playdate.graphics

EnemyBase = {}
EnemyBase.__index = EnemyBase

-- TODO: Just a tilemap here?
local err
local baseQuarterVert
local baseQuarterHoriz
local baseGunVert
local baseGunHoriz
baseQuarterVert, err = gfx.image.new("images/baseQuarterVert.png")
assert(baseQuarterVert, err)
baseQuarterHoriz, err = gfx.image.new("images/baseQuarterHoriz.png")
assert(baseQuarterHoriz, err)
baseGunVert, err = gfx.image.new("images/baseGunVert.png")
assert(baseGunVert, err)
baseGunHoriz, err = gfx.image.new("images/baseGunHoriz.png")
assert(baseGunHoriz, err)

-- 
local spheresHoriz = {}
local spheresVert = {}

function EnemyBase.new(x, y)
	-- A base is composed of several parts, 4 x 32x32 corners and a 8x16 gun
	local img = gfx.image.new(32 * 2 + 8, 32 * 2 + 8)
	local self = gfx.sprite.new(img)

	function self:update()
		-- TODO: Something here. Fire. Spawn bombers?
	end

	function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()
        self:moveTo(x + deltaX, y + deltaY)
    end

	function self:buildBase()
		local w,h = self:getSize()

		-- Draw a shiny new base
		gfx.pushContext(self:getImage())
		gfx.setColor(gfx.kColorClear)
		gfx.fillRect(0, 0, w, h)
		if self.isVertical then
			baseQuarterVert:draw(0,4)
			baseQuarterVert:draw(0,4+32,gfx.kImageFlippedY)
			baseQuarterVert:draw(32+8,4,gfx.kImageFlippedX)
			baseQuarterVert:draw(32+8,4+32,gfx.kImageFlippedXY)
			baseGunVert:draw(32,4+32-8)

			self:setCollideRect(0, 4, 32 * 2 + 8, 32 * 2)
		else
			baseQuarterHoriz:draw(4,0)
			baseQuarterHoriz:draw(4+32,0,gfx.kImageFlippedX)
			baseQuarterHoriz:draw(4,32+8,gfx.kImageFlippedY)
			baseQuarterHoriz:draw(4+32,32+8,gfx.kImageFlippedXY)
			baseGunHoriz:draw(4+32-8,32)

			self:setCollideRect(4, 0, 32 * 2, 32 * 2 + 8)
		end

		gfx.popContext()
	end

	function self:bulletHit(bullet, cx, cy)
		-- We know the bullet has hit a base pixel.
		-- We're trying to find out which sphere is most likely to have been hit
	
		-- Sprites are default positioned by centre
		local x, y = self:getPosition()
		hitDist = PointsDistance(x, y, cx, cy)
		hitAngle = PointsAngle(x, y, cx, cy)
		print("d:"..hitDist.." a:"..hitAngle)

		-- Convert angle and distance into a hit
		if hitDist < 33.6 then
			self:centreHit()
		else
			self:sphereHit(hitAngle, cx, cy)
		end
	end

	function self:centreHit()
		-- TODO: Centre hit is an instant kill unless shields are down
		print('center hit')
	end

	function self:sphereHit(angle, cx, cy)
		local sphere = 0

		print('sphere hit: ' .. angle)
		-- TODO: A little cheap. Cheaper than a bitmask?
		if self.isVertical then
			-- Spheres at 30, 90, 150, 210, 270, 300
		else
			-- Spheres at 0, 60, 120, 180, 240, 300 roughly
			if angle > 348 or angle < 13 then
				sphere = 1
			elseif angle > 59 and angle < 84 then
				sphere = 2
			elseif angle > 97 and angle < 122 then
				sphere = 3
			elseif angle > 169 and angle < 191 then
				sphere = 4
			elseif angle > 238 and angle < 262 then
				sphere = 5
			elseif angle > 275 and angle < 300 then
				sphere = 6
			end
		end

		print('sphereHit: ' .. sphere)

		if sphere > 0 then
			Explode(cx, cy)
		end
	end

	-- Setup
	self.isVertical = math.random(2) == 1
	self:setTag(SPRITE_TAGS.enemyBase)
	self:buildBase()
	self:moveTo(x, y)
	self:setZIndex(20)
	-- self:setCollideRect(0, 0, 3, 3)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)
	self:add()

	return self
end