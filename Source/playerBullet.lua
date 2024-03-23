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
	self:setCollidesWithGroupsMask(GROUP_ENEMY)
	self:setVisible(false)
	
	function self:fire(x, y, deltaX, deltaY)
		self.deltaX = deltaX
		self.deltaY = deltaY

		self:moveTo(x, y)
		self:setVisible(true)
		self:add()
	end
	
	function self:update()
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
		
		if x < 0 or x > 400 or y < 0 or y > 240 then
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