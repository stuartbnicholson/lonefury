-- All enemy bases and other large enemies share these bullets. This is as way of
-- easily controlling the number of big bullets in flight at any one time during a game.
local pd = playdate
local gfx = pd.graphics
local anim = gfx.animation

EnemyBigBullet = {}
EnemyBigBullet.__index = EnemyBigBullet

local imgTable = Assets.getImagetable('images/bigBullet-table-4-4.png')
local loop = anim.loop.new(50, imgTable, true)

-- TODO: If velocity increases, bullets get a lot harder to dodge
local VELOCITY <const> = 2.0

function EnemyBigBullet:new()
	local self = gfx.sprite:new()
	self:setTag(SPRITE_TAGS.enemyBullet)
	self:setZIndex(5)
	self:setCollideRect(0, 0, 4, 4)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_PLAYER|GROUP_OBSTACLE|GROUP_ENEMY)
	self:setVisible(false)

	-- Spawning a bullet == firing a bullet
	function self:spawn(worldX, worldY, deltaX, deltaY)
		self.worldX = worldX
		self.worldY = worldY
		self.deltaX = deltaX * VELOCITY
		self.deltaY = deltaY * VELOCITY
		self.isSpawned = true

		self:moveTo(WorldToViewPort(self.worldX, self.worldY))
		self:setVisible(true)
		self:add()
	end

	function self:despawn()
		self:setVisible(false)
		self.isSpawned = false
		self:remove()
	end

	function self:collisionResponse(other)
		return gfx.sprite.kCollisionTypeOverlap
	end

	-- Update will only be called on sprites in the list, regardless of visibility. Bullets we can add and remove from sprite list easily
	function self:update()
		-- Travel the bullet...
		self.worldX += self.deltaX
		self.worldY += self.deltaY

		-- ...before all other checks
		local viewX, viewY = WorldToViewPort(self.worldX, self.worldY)
		if NearViewport(viewX, viewY, self.width, self.height) then
			-- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
			-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
			local toX, toY, c, n = self:moveWithCollisions(viewX, viewY)
			self:setImage(loop:image())
			self:setVisible(true)
			local hit = false
			for i = 1, n do
				if self:alphaCollision(c[i].other) == true then
					-- The first real collision is sufficient to stop the bullet
					c[i].other:bulletHit(self, c[i].touch.x, c[i].touch.y)
					hit = true
					break
				end
			end

			if hit then
				-- Bullet can be re-used
				self:despawn()
			end
		else
			-- Bullet can be re-used
			self:despawn()
		end
	end

	return self
end
