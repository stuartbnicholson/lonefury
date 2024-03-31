-- From the Asheteroids example
local gfx = playdate.graphics

PlayerBullet = {}
PlayerBullet.__index = PlayerBullet

function PlayerBullet:new()
	local img = gfx.image.new(3,3)
	gfx.pushContext(img)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 3, 3)
	gfx.popContext(img)
	local self = gfx.sprite:new(img)
	self:setTag(SPRITE_TAGS.playerBullet)
	self:setZIndex(0)
	self:setCollideRect(0, 0, 3, 3)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_ENEMY|GROUP_OBSTACLE)
	self:setVisible(false)

	function self:spawn(worldX, worldY, deltaX, deltaY)
		self.worldX = worldX
		self.worldY = worldY
		self.deltaX = deltaX
		self.deltaY = deltaY
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

	function self:update()
		-- Travel the bullet...
		self.worldX += self.deltaX
		self.worldY += self.deltaY

		-- ...before all other checks
		if NearViewport(self.worldX, self.worldY, self.width, self.height) then
			-- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
			-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
			self:moveTo(WorldToViewPort(self.worldX, self.worldY))

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