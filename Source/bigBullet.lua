local gfx = playdate.graphics

BigBullet = {}
BigBullet.__index = BigBullet

local imgTable, err = gfx.imagetable.new('images/bigBullet-table-4-4.png')
assert(imgTable, err)

function BigBullet:new()
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