import 'assets'

local gfx = playdate.graphics

local imgTable = Assets.getImagetable('images/playerBullet-table-4-4.png')

PlayerBullet = {}
PlayerBullet.__index = PlayerBullet

function PlayerBullet:new()
	local self = gfx.sprite:new(imgTable:getImage(1))
	self:setTag(SPRITE_TAGS.playerBullet)
	self:setZIndex(0)
	self:setCollideRect(0, 0, 4, 4)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_ENEMY|GROUP_ENEMY_BASE|GROUP_OBSTACLE)
	self:setVisible(false)

	function self:spawn(worldX, worldY, angle, deltaX, deltaY)
		self.worldX = worldX
		self.worldY = worldY
		self.deltaX = deltaX
		self.deltaY = deltaY
		SetTableImage(angle, self, imgTable)
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

	function self:update()
		-- Travel the bullet...
		self.worldX += self.deltaX
		self.worldY += self.deltaY

		-- ...before all other checks
		if NearViewport(self.worldX, self.worldY, self.width, self.height) then
			-- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
			-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
			local toX,toY,c,n = self:moveWithCollisions(WorldToViewPort(self.worldX, self.worldY))
			for i=1,n do
				if self:alphaCollision(c[i].other) then
					-- The first real collision is sufficient to stop the bullet
					self:bulletHit(c[i].other, c[i].touch.x, c[i].touch.y)
					break
				end
			end
		else
			-- Bullet can be re-used
			self:despawn()
		end
	end

	function self:bulletHit(other, x, y)
		other:bulletHit(self, x, y)

		-- Bullet can be re-used
		self:despawn()
	end

	return self
end