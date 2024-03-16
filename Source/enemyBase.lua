local gfx = playdate.graphics
local geom = playdate.geometry

EnemyBase = {}
EnemyBase.__index = EnemyBase

local err

-- EnemyBase sprites
-- TODO: Just a tilemap here?
local baseQuarterVert, baseGunVert
baseQuarterVert, err = gfx.image.new("images/baseQuarterVert.png")
assert(baseQuarterVert, err)
baseGunVert, err = gfx.image.new("images/baseGunVert.png")
assert(baseGunVert, err)

local baseQuarterHoriz, baseGunHoriz
baseQuarterHoriz, err = gfx.image.new("images/baseQuarterHoriz.png")
assert(baseQuarterHoriz, err)
baseGunHoriz, err = gfx.image.new("images/baseGunHoriz.png")
assert(baseGunHoriz, err)

local baseRuin1, baseRuin2, baseSphereMask
baseRuin1, err = gfx.image.new("images/baseRuin1.png")
assert(baseRuin1, err)
baseRuin2, err = gfx.image.new("images/baseRuin2.png")
assert(baseRuin2, err)
baseSphereMask, err = gfx.image.new("images/baseSphereMask.png")
assert(baseSphereMask, err)

local Sphere1 <const> = 0x01
local Sphere2 <const> = 0x02
local Sphere3 <const> = 0x04
local Sphere4 <const> = 0x08
local Sphere5 <const> = 0x10
local Sphere6 <const> = 0x20
local SpheresAlive <const> = Sphere1|Sphere2|Sphere3|Sphere4|Sphere5|Sphere6
local SpheresDead <const> = 0x00

--Horiz sphere mask/ruin positions for 18,18 sprite
local sphereHorizPos = {}
sphereHorizPos[Sphere1] = geom.point.new(27,-1)
sphereHorizPos[Sphere2] = geom.point.new(51,15)
sphereHorizPos[Sphere3] = geom.point.new(51,39)
sphereHorizPos[Sphere4] = geom.point.new(27,55)
sphereHorizPos[Sphere5] = geom.point.new(3,39)
sphereHorizPos[Sphere6] = geom.point.new(3,15)
local sphereHorizRuin1 = Sphere2|Sphere3|Sphere5|Sphere6
local sphereHorizRuinFlip = {}
sphereHorizRuinFlip[Sphere1] = gfx.kImageUnflipped
sphereHorizRuinFlip[Sphere2] = gfx.kImageFlippedX
sphereHorizRuinFlip[Sphere3] = gfx.kImageFlippedXY
sphereHorizRuinFlip[Sphere4] = gfx.kImageFlippedX
sphereHorizRuinFlip[Sphere5] = gfx.kImageFlippedY
sphereHorizRuinFlip[Sphere6] = gfx.kImageUnflipped

--Vert sphere mask/ruin positions for 18,18 sprite
-- TODO: Correct
local sphereVertPos = {}
sphereVertPos[Sphere1] = geom.point.new(15,3)
sphereVertPos[Sphere2] = geom.point.new(39,3)
sphereVertPos[Sphere3] = geom.point.new(55,27)
sphereVertPos[Sphere4] = geom.point.new(39,51)
sphereVertPos[Sphere5] = geom.point.new(15,51)
sphereVertPos[Sphere6] = geom.point.new(-1,27)
local sphereVertRuin1 = Sphere1|Sphere2|Sphere4|Sphere5
local sphereVertRuinFlip = {}
sphereVertRuinFlip[Sphere1] = gfx.kImageUnflipped
sphereVertRuinFlip[Sphere2] = gfx.kImageFlippedX
sphereVertRuinFlip[Sphere3] = gfx.kImageFlippedX
sphereVertRuinFlip[Sphere4] = gfx.kImageFlippedXY
sphereVertRuinFlip[Sphere5] = gfx.kImageFlippedY
sphereVertRuinFlip[Sphere6] = gfx.kImageUnflipped

function EnemyBase.new(x, y)
	-- A base is composed of several parts, 4 x 32x32 corners and a 8x16 gun
	local img = gfx.image.new(32 * 2 + 8, 32 * 2 + 8)
	local self = gfx.sprite.new(img)
	self.spheresAlive = SpheresAlive
 
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
			-- For drawing ruined spheres
			self.sphereRuin1 = sphereVertRuin1
			self.sphereRuinFlip = sphereVertRuinFlip

			baseQuarterVert:draw(0,4)
			baseQuarterVert:draw(0,4+32,gfx.kImageFlippedY)
			baseQuarterVert:draw(32+8,4,gfx.kImageFlippedX)
			baseQuarterVert:draw(32+8,4+32,gfx.kImageFlippedXY)
			baseGunVert:draw(32,4+32-8)

			self:setCollideRect(0, 4, 32 * 2 + 8, 32 * 2)
		else
			-- For drawing ruined spheres
			self.sphereRuin1 = sphereHorizRuin1
			self.sphereRuinFlip = sphereHorizRuinFlip

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
			if angle > 330 and angle < 354 then
				sphere = Sphere1
			elseif angle > 8 and angle < 30 then
				sphere = Sphere2
			elseif angle > 78 and angle < 104 then
				sphere = Sphere3
			elseif angle > 147 and angle < 170 then
				sphere = Sphere4
			elseif angle > 187 and angle < 210 then
				sphere = Sphere5
			elseif angle > 257 and angle < 280 then
				sphere = Sphere6
			end
		else
			-- Spheres at 0, 60, 120, 180, 240, 300 roughly
			if angle > 348 or angle < 13 then
				sphere = Sphere1
			elseif angle > 59 and angle < 84 then
				sphere = Sphere2
			elseif angle > 97 and angle < 122 then
				sphere = Sphere3
			elseif angle > 169 and angle < 191 then
				sphere = Sphere4
			elseif angle > 238 and angle < 262 then
				sphere = Sphere5
			elseif angle > 275 and angle < 300 then
				sphere = Sphere6
			end
		end

		print('sphereHit: ' .. sphere)

		if sphere > 0 then
			-- If a sphere has been hit AND it isn't already destroyed, destroy it.
			if self.spheresAlive & sphere > 0 then
				-- If this is the last sphere in the base, destroy the whole base
				self.spheresAlive = self.spheresAlive ~ sphere
							
				if self.spheresAlive == SpheresDead then
					self:baseExplodes()
				else
					self:sphereExplodes(sphere)
				end
			end
		end
	end

	function self:baseExplodes()
		-- TODO:
		print('Base explodes!')
	end

	function self:sphereExplodes(sphere)
		-- TODO: Sphere explosion

		-- TODO: Redraw correct sphere ruined
		local point
		if self.isVertical then
			point = sphereVertPos[sphere]
		else
			point = sphereHorizPos[sphere]
		end

		-- Select ruined sphere image
		local ruinImg = baseRuin1
		if self.sphereRuin1 & sphere == 0 then
			ruinImg = baseRuin2
		end

		-- Select ruined sphere reflect
		local flip = self.sphereRuinFlip[sphere]

		gfx.pushContext(self:getImage())
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		baseSphereMask:draw(point)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		ruinImg:draw(point, flip)
		gfx.popContext()
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