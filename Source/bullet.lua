-- From the Asheteroids example 
local gfx = playdate.graphics

Bullet = {}
Bullet.__index = Bullet

function Bullet:new()
	local self = gfx.sprite:new()
	
	self:setSize(3, 3)
	self:setCollideRect(0, 0, 3, 3)
	self:setGroupMask(GROUP_BULLET)
	self:setCollidesWithGroupsMask(GROUP_ENEMY)
	self:setVisible(false)
	
	function self:fire(x, y, deltaX, deltaY, angle)
		self.deltaX = deltaX
		self.deltaY = deltaY

		self:moveTo(x, y)
		self:setRotation(angle)
		self:setVisible(true)
		self:add()
	end
	
	function self:update()
		local x,y,c,n = self:moveWithCollisions(self.x + self.deltaX, self.y + self.deltaY)
		
		for i=1,n do
			self:bulletHit(c[i].other)
		end
		
		if self.x < 0 or self.x > 400 or self.y < 0 or self.y > 240 then
			self:setVisible(false)
			self:remove()
		end
	end

	function self:bulletHit(other)
		other:bulletHit()

		self:setVisible(false)
		self:remove()
	end

	function self:draw()
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 3, 3)
	end
	
	function self:collisionResponse(other)
		return "overlap"
	end

	return self
end