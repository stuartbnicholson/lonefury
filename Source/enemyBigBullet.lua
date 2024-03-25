import 'CoreLibs/animation'

-- All enemy bases and other large enemies share these bullets. This is as way of
-- easily controlling the number of big bullets in flight at any one time during a game.
local gfx = playdate.graphics

EnemyBigBullet = {}
EnemyBigBullet.__index = EnemyBigBullet

local imgTable, err = gfx.imagetable.new('images/bigBullet-table-4-4.png')
assert(imgTable, err)

-- TODO: If velocity increases, bullets get a lot harder to dodge
local VELOCITY <const> = 2.0

function EnemyBigBullet:new()
	local self = gfx.sprite:new()
	self:setTag(SPRITE_TAGS.enemyBullet)
	self:setZIndex(5)
	self:setCollideRect(0, 0, 4, 4)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_PLAYER)
	self:setVisible(false)

	self.loop = gfx.animation.loop.new(50, imgTable, true)

	function self:fire(worldX, worldY, deltaX, deltaY)
		self.worldX = worldX
		self.worldY = worldY
		self.deltaX = deltaX * VELOCITY
		self.deltaY = deltaY * VELOCITY

		self:moveTo(WorldToViewPort(self.worldX, self.worldY))
		self:setVisible(true)
		self:add()
	end

	-- Update will only be called on sprites in the list, regardless of visibility. Bullets we can add and remove from sprite list easily
	function self:update()
		-- Travel the bullet...
		self.worldX += self.deltaX
		self.worldY += self.deltaY

		-- ...before all other checks
		if NearViewport(self.worldX, self.worldY, self.width, self.height) then
			self:moveTo(WorldToViewPort(self.worldX, self.worldY))
            self:setVisible(true)

			self:setImage(self.loop:image())

			local _,_,c,n = self:checkCollisions(self.x, self.y)
			for i=1,n do
				if self:alphaCollision(c[i].other) then
					-- The first real collision is sufficient to stop the bullet
					self:bulletHit(c[i].other, c[i].touch.x, c[i].touch.y)
					break
				end
			end
        else
			-- Bullet can be re-used
            self:setVisible(false)
			self:remove()
        end
	end

	function self:bulletHit(other, x, y)
		other:bulletHit(self, x, y)

		-- Bullet can be re-used
		self:setVisible(false)
		self:remove()
	end

	return self
end

-- Manage big bullets, we only cycle a limited set
-- TODO: Multiple enemy bases firing a set number of bullets each
local bigBullets = {}
bigBullets[1] = EnemyBigBullet:new()
bigBullets[2] = EnemyBigBullet:new()
bigBullets[3] = EnemyBigBullet:new()
bigBullets[4] = EnemyBigBullet:new()
bigBullets[5] = EnemyBigBullet:new()
bigBullets[6] = EnemyBigBullet:new()
bigBullets[7] = EnemyBigBullet:new()
bigBullets[8] = EnemyBigBullet:new()
bigBullets[9] = EnemyBigBullet:new()
bigBullets[10] = EnemyBigBullet:new()
bigBullets[11] = EnemyBigBullet:new()
bigBullets[12] = EnemyBigBullet:new()
bigBullets[13] = EnemyBigBullet:new()
bigBullets[14] = EnemyBigBullet:new()
bigBullets[15] = EnemyBigBullet:new()
bigBullets[16] = EnemyBigBullet:new()
bigBullets[17] = EnemyBigBullet:new()
bigBullets[18] = EnemyBigBullet:new()
bigBullets[19] = EnemyBigBullet:new()
bigBullets[20] = EnemyBigBullet:new()
bigBullets[21] = EnemyBigBullet:new()
bigBullets[22] = EnemyBigBullet:new()
bigBullets[23] = EnemyBigBullet:new()
bigBullets[24] = EnemyBigBullet:new()
bigBullets[25] = EnemyBigBullet:new()
bigBullets[26] = EnemyBigBullet:new()
bigBullets[27] = EnemyBigBullet:new()
bigBullets[28] = EnemyBigBullet:new()
bigBullets[29] = EnemyBigBullet:new()
bigBullets[30] = EnemyBigBullet:new()
bigBullets[31] = EnemyBigBullet:new()
bigBullets[32] = EnemyBigBullet:new()
bigBullets[33] = EnemyBigBullet:new()
bigBullets[34] = EnemyBigBullet:new()
bigBullets[35] = EnemyBigBullet:new()
bigBullets[36] = EnemyBigBullet:new()
bigBullets[37] = EnemyBigBullet:new()
bigBullets[38] = EnemyBigBullet:new()
bigBullets[39] = EnemyBigBullet:new()
bigBullets[40] = EnemyBigBullet:new()

local bigBulletIdx = 1

function FindFreeEnemyBigBullet()
	local idx = bigBulletIdx
	repeat
		if not bigBullets[bigBulletIdx]:isVisible() then
			-- Prep for next find
			idx = bigBulletIdx
			bigBulletIdx = IncWrap(bigBulletIdx, #bigBullets)

			-- Incoming!
			return bigBullets[idx]
		end

		bigBulletIdx = IncWrap(bigBulletIdx, #bigBullets)
	until bigBulletIdx == idx

	-- No free plomo
	return nil
end