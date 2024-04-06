import 'assets'
import 'enemyBigBullet'

local pd = playdate
local gfx = pd.graphics
local geom = pd.geometry

EnemyBase = {}
EnemyBase.__index = EnemyBase

-- EnemyBase images
local baseQuarterVert = Assets.getImage('images/baseQuarterVert.png')
local baseGunVert = Assets.getImage('images/baseGunVert.png')
local baseQuarterHoriz = Assets.getImage('images/baseQuarterHoriz.png')
local baseGunHoriz = Assets.getImage('images/baseGunHoriz.png')
local baseRuin1 = Assets.getImage('images/baseRuin1.png')
local baseRuin2 = Assets.getImage('images/baseRuin2.png')
local baseSphereMask = Assets.getImage('images/baseSphereMask.png')

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

local fireSpheres = { Sphere1, Sphere5, Sphere3, Sphere4, Sphere6, Sphere2 }

local SphereScore <const> = 25 -- * 6 = 150
local BaseOneShotScore <const> = 200

function EnemyBase.new()
	-- A base is composed of several parts, 4 x 32x32 corners and a 8x16 gun
	local self = gfx.sprite.new(gfx.image.new(32 * 2 + 8, 32 * 2 + 8))
	self:setTag(SPRITE_TAGS.enemyBase)
	self:setZIndex(20)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)

	self.lastFiredMs = 0

	-- Pool management
	function self:spawn(worldX, worldY, multiShot, fireMs)
		self.worldX = worldX
		self.worldY = worldY
		Dashboard:addEnemyBase(self.worldX, self.worldY)

		-- Game level dictates the bases's rage.
		self.multiShot = multiShot
		self.fireMs = fireMs

		self:setVisible(false)
		self.spheresAlive = SpheresAlive
		self.lastFiredIdx = 1
		self.isVertical = math.random(2) == 1
		self:buildBase()
		self.isSpawned = true

		self:add()
	end

    function self:despawn()
		Dashboard:removeEnemyBase(self.worldX, self.worldY)

		self:setVisible(false)
		self.isAlive = SpheresDead
        self.isSpawned = false

        self:remove()
    end

	function self:sphereFire(firingSpheres)
		assert(firingSpheres > 0, 'No spheres to fire')

		-- Alternate which sphere fires next
		local i = self.lastFiredIdx
		repeat
			i = IncWrap(i, 6)

			if firingSpheres & fireSpheres[i] > 0 then
				self.lastFiredIdx = i
				return fireSpheres[i]
			end
		until i == self.lastFiredIdx
		assert(true, 'No firing sphere?')
	end

	function self:fire()
		-- Check if enough time has elapsed since base last fired
		local now = pd.getCurrentTimeMilliseconds()
		if now - self.lastFiredMs >= self.fireMs then
			local pWx, pWy = Player:getWorldV():unpack()
			local angleToPlayer = PointsAngle(self.worldX, self.worldY, pWx, pWy)
			local dx, dy = AngleToDeltaXY(angleToPlayer)
			dx = -dx
			dy = -dy
			local firingSpheres = 0

			if self.isVertical then
				if angleToPlayer < 60 then
					firingSpheres = Sphere1|Sphere2|Sphere3
				elseif angleToPlayer < 120 then
					firingSpheres = Sphere2|Sphere3|Sphere4
				elseif angleToPlayer < 180 then
					firingSpheres = Sphere3|Sphere4|Sphere5
				elseif angleToPlayer < 240 then
					firingSpheres = Sphere4|Sphere5|Sphere6
				elseif angleToPlayer < 300 then
					firingSpheres = Sphere5|Sphere6|Sphere1
				else
					firingSpheres = Sphere6|Sphere1|Sphere2
				end
			else
				if angleToPlayer < 45 then
					firingSpheres = Sphere6|Sphere1|Sphere2
				elseif angleToPlayer < 90 then
					firingSpheres = Sphere1|Sphere2|Sphere3
				elseif angleToPlayer < 135 then
					firingSpheres = Sphere2|Sphere3|Sphere4
				elseif angleToPlayer < 225 then
					firingSpheres = Sphere3|Sphere4|Sphere5
				elseif angleToPlayer < 270 then
					firingSpheres = Sphere4|Sphere5|Sphere6
				else
					firingSpheres = Sphere5|Sphere6|Sphere1
				end
			end

			-- Mask out the dead spheres, and the remaining spheres (if any) can fire
			local shots = 0
			firingSpheres = self.spheresAlive & firingSpheres
			while firingSpheres > 0 and shots < self.multiShot do
				local bullet = PoolManager:freeInPool(EnemyBigBullet)
				if bullet then
					SoundManager:enemyBaseShoots()
					local sphere = self:sphereFire(firingSpheres)
					local spherePos = self.spherePos[sphere]
					bullet:spawn(self.worldX + spherePos.x - 36 + 9, self.worldY + spherePos.y - 36 + 9, dx, dy)

					-- Spheres and firing time tracking
					shots += 1
					firingSpheres = firingSpheres ~ sphere
					self.lastFiredMs = now

					-- TODO: This will break the ripple fire effect. Ripple fire as many spheres up to a certain number of shots.
				else
					-- Nothing to fire
					break
				end
			end
		end
	end

	function self:update()
        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(self.worldX, self.worldY, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
		end

		-- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
		self:moveTo(WorldToViewPort(self.worldX, self.worldY))

		if self:isVisible() then
			if Player.isAlive then
				-- Fire some new bullets
				self:fire()
			end

			-- TODO:
			-- self:spawnEnemy()
		end
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
			self.spherePos = sphereVertPos

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
			self.spherePos = sphereHorizPos

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
		self:baseExplodes()
	end

	function self:sphereHit(angle, cx, cy)
		local sphere = 0

		-- print('sphere hit: ' .. angle)
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

		-- print('sphereHit: ' .. sphere)

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
		if self.spheresAlive == SpheresAlive then
			Player:scored(BaseOneShotScore)
		end

		ScreenShake(1, 2)
		Explode(ExplosionLarge, self.worldX, self.worldY)
		LevelManager:baseDestroyed()

		self:despawn()
	end

	function self:sphereExplodes(sphere)
		Player:scored(SphereScore)

		-- Redraw correct sphere ruined
		local point = self.spherePos[sphere]

		-- Start sphere explosion
		Explode(ExplosionMed, self.worldX + point.x - 36 + 10 - 1, self.worldY + point.y - 36 + 10 - 1) -- TODO: Annoying conversion back to World x,y

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

	return self
end