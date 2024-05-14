-- A refactor of enemyBase that splits the base into three sub-sprites
import 'assets'
import 'enemyBaseHalf'

local pd = playdate
local gfx = pd.graphics
local geom = pd.geometry

local Sphere1 <const> = 0x01
local Sphere2 <const> = 0x02
local Sphere3 <const> = 0x04
local Sphere4 <const> = 0x08
local Sphere5 <const> = 0x10
local Sphere6 <const> = 0x20
local SpheresAlive <const> = Sphere1|Sphere2|Sphere3|Sphere4|Sphere5|Sphere6
local SpheresDead <const> = 0x00

-- EnemyBase images
local baseGunVert = Assets.getImage('images/baseGunVert.png')
local baseGunHoriz = Assets.getImage('images/baseGunHoriz.png')
local baseGunShieldVert = Assets.getImage('images/baseGunShieldVert.png')
local baseGunShieldHoriz = Assets.getImage('images/baseGunShieldHoriz.png')
local baseRuin1 = Assets.getImage('images/baseRuin1.png')
local baseRuin2 = Assets.getImage('images/baseRuin2.png')
local baseSphereMask = Assets.getImage('images/baseSphereMask.png')

-- Horiz sphere mask/ruin positions for 18,18 sprite
local sphereHorizPos = {}
sphereHorizPos[Sphere1] = geom.point.new(-1,15)
sphereHorizPos[Sphere2] = geom.point.new(23,-1)
sphereHorizPos[Sphere3] = geom.point.new(47,15)
sphereHorizPos[Sphere4] = geom.point.new(-1,-1)
sphereHorizPos[Sphere5] = geom.point.new(23,15)
sphereHorizPos[Sphere6] = geom.point.new(47,-1)
local sphereHorizRuin1 = Sphere2|Sphere5
local sphereHorizRuinFlip = {}
sphereHorizRuinFlip[Sphere1] = gfx.kImageUnflipped
sphereHorizRuinFlip[Sphere2] = gfx.kImageFlippedX
sphereHorizRuinFlip[Sphere3] = gfx.kImageFlippedX
sphereHorizRuinFlip[Sphere4] = gfx.kImageFlippedY
sphereHorizRuinFlip[Sphere5] = gfx.kImageFlippedXY
sphereHorizRuinFlip[Sphere6] = gfx.kImageFlippedXY

-- Vert sphere mask/ruin positions for 18,18 sprite
local sphereVertPos = {}
sphereVertPos[Sphere1] = geom.point.new(15,-1)
sphereVertPos[Sphere2] = geom.point.new(-1,23)
sphereVertPos[Sphere3] = geom.point.new(15,47)
sphereVertPos[Sphere4] = geom.point.new(-1,-1)
sphereVertPos[Sphere5] = geom.point.new(15,23)
sphereVertPos[Sphere6] = geom.point.new(-1,47)
local sphereVertRuin1 = Sphere1|Sphere3|Sphere4|Sphere6
local sphereVertRuinFlip = {}
sphereVertRuinFlip[Sphere1] = gfx.kImageUnflipped
sphereVertRuinFlip[Sphere2] = gfx.kImageUnflipped
sphereVertRuinFlip[Sphere3] = gfx.kImageFlippedY
sphereVertRuinFlip[Sphere4] = gfx.kImageFlippedX
sphereVertRuinFlip[Sphere5] = gfx.kImageFlippedXY
sphereVertRuinFlip[Sphere6] = gfx.kImageFlippedXY

local fireSpheres = { Sphere1, Sphere5, Sphere3, Sphere4, Sphere6, Sphere2 }

EnemyBase = {}
EnemyBase.__index = EnemyBase

function EnemyBase.new(isVertical)
    -- A base is composed of three sprite parts. The two base halves containing three spheres each,
    -- and the central base gun. The central base gun is represented directly by this object.
    isVertical = isVertical or math.random() > 0.5
	local self = gfx.sprite.new((isVertical and baseGunVert) or baseGunHoriz)
	self:setTag(SPRITE_TAGS.enemyBase)
	self:setZIndex(20)
	self:setGroupMask(GROUP_ENEMY_BASE)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)
    if isVertical then
        self:setCollideRect(0, 0, 7, 16)
        self.spherePos = sphereVertPos
        self.sphereRuinFlip = sphereVertRuinFlip
        self.sphereRuin1 = sphereVertRuin1
    else
        self:setCollideRect(0, 0, 16, 7)
        self.spherePos = sphereHorizPos
        self.sphereRuinFlip = sphereHorizRuinFlip
        self.sphereRuin1 = sphereHorizRuin1
    end

    -- Base members
    self.isVertical = isVertical
	self.lastFiredMs = 0

    -- The base halves
    -- Each base half is 32x64 horiz, or 64x32 vert
    -- The central gun is 16x7 horiz or 7x16 vert
    -- We're assuming base gun is at 0,0
    if self.isVertical then
        self.xHalf = -(32 + 7) / 2
        self.yHalf = 0
    else
        self.xHalf = 0
        self.yHalf = -(32 + 7) / 2
    end

    self.halves = {
        EnemyBaseHalf.new(self, self.xHalf, self.yHalf, self.isVertical, false, {Sphere1, Sphere2, Sphere3}), -- Top, or left
        EnemyBaseHalf.new(self, -self.xHalf, -self.yHalf, self.isVertical, true, {Sphere4, Sphere5, Sphere6})   -- Bottom, or right
    }

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
		self.isSpawned = true

		self:add()
        self.halves[1]:spawn()
        self.halves[2]:spawn()
	end

    function self:despawn()
		Dashboard:removeEnemyBase(self.worldX, self.worldY)

		self:setVisible(false)
		-- self.isAlive = SpheresDead
        self.isSpawned = false

        self:remove()
        self.halves[1]:despawn()
        self.halves[2]:despawn()
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
					firingSpheres = Sphere1|Sphere4|Sphere5
				elseif angleToPlayer < 120 then
					firingSpheres = Sphere4|Sphere5|Sphere6
				elseif angleToPlayer < 180 then
					firingSpheres = Sphere3|Sphere6|Sphere5
				elseif angleToPlayer < 240 then
					firingSpheres = Sphere2|Sphere3|Sphere6
				elseif angleToPlayer < 300 then
					firingSpheres = Sphere1|Sphere2|Sphere3
				else
					firingSpheres = Sphere4|Sphere1|Sphere2
				end
			else
				if angleToPlayer < 45 then
					firingSpheres = Sphere1|Sphere2|Sphere3
				elseif angleToPlayer < 90 then
					firingSpheres = Sphere2|Sphere3|Sphere6
				elseif angleToPlayer < 135 then
					firingSpheres = Sphere5|Sphere6|Sphere3
				elseif angleToPlayer < 225 then
					firingSpheres = Sphere4|Sphere5|Sphere6
				elseif angleToPlayer < 270 then
					firingSpheres = Sphere1|Sphere4|Sphere5
				else
					firingSpheres = Sphere2|Sphere1|Sphere4
				end
			end

			-- Mask out the dead spheres, and the remaining spheres (if any) can fire
			local shots = 0
			firingSpheres = self.spheresAlive & firingSpheres
			while firingSpheres > 0 and shots < self.multiShot do
				local bullet = PoolManager:freeInPool(EnemyBigBullet)
				if bullet then
					SoundManager:enemyBaseShoots()

					-- Determine where bullet fires from
					-- TODO: This could be pre-calculated per base!
					local sphere = self:sphereFire(firingSpheres)
					local bulletX, bulletY = self.spherePos[sphere]:unpack()
					bulletX += self.worldX - 36 + 9
					bulletY += self.worldY - 36 + 9
					if self.isVertical then
						if sphere > Sphere3 then
							bulletX += 39
						end
					else
						if sphere > Sphere3 then
							bulletY += 39
						end
					end
					bullet:spawn(bulletX, bulletY, dx, dy)

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
        local visible = NearViewport(self.worldX, self.worldY, 72, 72) or false
        self:setVisible(visible)
        self.halves[1]:setVisible(visible)
        self.halves[2]:setVisible(visible)

		ActiveEnemyBases += 1
		if visible then
			ActiveVisibleEnemyBases += 1
		end

		-- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        local wx, wy = WorldToViewPort(self.worldX, self.worldY)
		self:moveTo(wx, wy)
        self.halves[1]:moveTo(self.xHalf + wx, self.yHalf + wy)
        self.halves[2]:moveTo(-self.xHalf + wx, -self.yHalf + wy)

        if visible then
			if Player.isAlive then
				-- Fire some new bullets
				self:fire()
			end
		end
    end

    function self:bulletHit(bullet, cx, cy)
		-- TODO: Centre hit is an instant kill unless shields are down
		self:baseExplodes()
    end

    function self:sphereHit(sphere)
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

	function self:sphereExplodes(sphere)
		Player:scored(SCORE_ENEMYBASE_SPHERE)

		local point = self.spherePos[sphere]
		-- Explode sphere
        if self.isVertical then
            if sphere < Sphere4 then
    		    Explode(ExplosionMed, self.worldX + point.x - 36 + 10, self.worldY + point.y - 36 + 10)
            else
    		    Explode(ExplosionMed, self.worldX + point.x - 36 + 10 + 39, self.worldY + point.y - 36 + 10)
            end
        else
            if sphere < Sphere4 then
    		    Explode(ExplosionMed, self.worldX + point.x - 36 + 10, self.worldY + point.y - 36 + 10)
            else
    		    Explode(ExplosionMed, self.worldX + point.x - 36 + 10, self.worldY + point.y - 36 + 10 + 39)
            end
        end

		-- Select ruined sphere image
		local ruinImg = baseRuin1
		if self.sphereRuin1 & sphere == 0 then
			ruinImg = baseRuin2
		end

		-- Select ruined sphere reflect
		local flip = self.sphereRuinFlip[sphere]

        -- Select half image
        local halfImg
        if sphere < Sphere4 then
            halfImg = self.halves[1]:getImage()
        else
            halfImg = self.halves[2]:getImage()
        end

		gfx.pushContext(halfImg)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		baseSphereMask:draw(point)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		ruinImg:draw(point, flip)
		gfx.popContext()
	end

    function self:baseExplodes()
		if self.spheresAlive == SpheresAlive then
			Player:scored(SCORE_ENEMYBASE_ONESHOT)
		end

		ScreenShake(1, 2)
		Explode(ExplosionLarge, self.worldX, self.worldY)
		LevelManager:baseDestroyed()

		self:despawn()
	end

    return self
end