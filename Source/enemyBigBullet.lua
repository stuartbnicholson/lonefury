-- All enemy bases and other large enemies share these bullets. This is as way of
-- easily controlling the number of big bullets in flight at any one time during a game.
local gfx = playdate.graphics

EnemyBigBullet = {}
EnemyBigBullet.__index = EnemyBigBullet

local imgTable, err = gfx.imagetable.new('images/bigBullet-table-4-4.png')
assert(imgTable, err)

function EnemyBigBullet:new()
	local self = gfx.sprite:new()
	self:setTag(SPRITE_TAGS.enemyBullet)
	self:setZIndex(5)
	self:setCollideRect(0, 0, 4, 4)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_PLAYER)
	self:setVisible(false)

	self.loop = gfx.animation.loop.new(50, imgTable, true)

	function self:fire(x, y, deltaX, deltaY)
		self.deltaX = deltaX
		self.deltaY = deltaY

		self:moveTo(x, y)
		self:setVisible(true)
		self:add()
	end

	function self:update()
		self:setImage(self.loop:image())

		local x,y = self:getPosition()
		self:moveTo(x + self.deltaX, y + self.deltaY)

		local _,_,c,n = self:checkCollisions(self.x, self.y)
		for i=1,n do
			if self:alphaCollision(c[i].other) then
				-- The first real collision is sufficient to stop the bullet
				self:bulletHit(c[i].other, c[i].touch.x, c[i].touch.y)
				break
			end
		end

		if x < 0 or x > WORLD_WIDTH or y < 0 or y > WORLD_HEIGHT then
			self:setVisible(false)
			self:remove()
		end
	end

	function self:bulletHit(other, x, y)
		other:bulletHit(self, x, y)

		self:setVisible(false)
		self:remove()
	end

	return self
end

-- Manage big bullets, we only cycle a limited set
local bigBullets = {}
bigBullets[1] = EnemyBigBullet:new()
bigBullets[2] = EnemyBigBullet:new()
bigBullets[3] = EnemyBigBullet:new()
--[[ TODO: Multiple enemy bases firing a set number of bullets each
bigBullets[4] = EnemyBigBullet:new()
bigBullets[5] = EnemyBigBullet:new()
bigBullets[6] = EnemyBigBullet:new()
]]--
local bigBulletIdx = 1

function EnemyBigBulletsUpdate()
	local bullet
	for i = 1, #bigBullets do
		bullet = bigBullets[i]
		if bullet:isVisible() then
			bullet:update()
		end
	end
end

function EnemyBigBulletsWorldPosUpdate(deltaX, deltaY)
	local bullet, x, y
	for i = 1, #bigBullets do
		bullet = bigBullets[i]
		if bullet:isVisible() then
			x, y = bullet:getPosition()
			bullet:moveTo(x + deltaX, y + deltaY)
		end
	end
end

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
