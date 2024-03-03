local gfx = playdate.graphics

EnemyBase = {}
EnemyBase.__index = EnemyBase

function EnemyBase.new(x, y)
	-- A base is composed of several parts, 4 x 32x32 corners and a 8x16 gun
	local img = gfx.image.new(32 * 2 + 8, 32 * 2)
	local self = gfx.sprite.new(img)

	function self:loadImages()
		local img, err = gfx.image.new("images/baseQuarter.png")
		assert(img, err)
		self.baseQuarter = img
		
		img, err = gfx.image.new("images/baseGun.png")
		assert(img, err)
		self.baseGun = img
	end

	function self:update()
		-- TODO: Something here. Fire. Spawn bombers
	end

	function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()
        self:moveTo(x + deltaX, y + deltaY)
    end

	function self:buildBase()
		local w,h = self:getSize()

		-- Draw a shiny new base
		gfx.pushContext(self:getImage())

		gfx.setColor(gfx.kColorClear)
		gfx.fillRect(0, 0, w, h)

		self.baseQuarter:draw(0,0)
		self.baseQuarter:draw(0,32,gfx.kImageFlippedY)
		self.baseQuarter:draw(32+8,0,gfx.kImageFlippedX)
		self.baseQuarter:draw(32+8,32,gfx.kImageFlippedXY)
		self.baseGun:draw(32,32-8)

		gfx.popContext()
	end

	self:loadImages()
	self:buildBase()
	self:moveTo(x, y)
	self:setZIndex(20)
	-- self:setCollideRect(0, 0, 3, 3)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)
	self:add()

	return self
end