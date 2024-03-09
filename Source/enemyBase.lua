local gfx = playdate.graphics

EnemyBase = {}
EnemyBase.__index = EnemyBase

function EnemyBase.new(x, y)
	-- A base is composed of several parts, 4 x 32x32 corners and a 8x16 gun
	local img = gfx.image.new(32 * 2 + 8, 32 * 2 + 8)
	local self = gfx.sprite.new(img)

	function self:loadImages()
		-- TODO: Just a tilemap here
		local img, err = gfx.image.new("images/baseQuarterVert.png")
		assert(img, err)
		self.baseQuarterVert = img

		img, err = gfx.image.new("images/baseQuarterHoriz.png")
		assert(img, err)
		self.baseQuarterHoriz = img

		img, err = gfx.image.new("images/baseGunVert.png")
		assert(img, err)
		self.baseGunVert = img

		img, err = gfx.image.new("images/baseGunHoriz.png")
		assert(img, err)
		self.baseGunHoriz = img
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

		if self.isVertical then
			self.baseQuarterVert:draw(0,0)
			self.baseQuarterVert:draw(0,32,gfx.kImageFlippedY)
			self.baseQuarterVert:draw(32+8,0,gfx.kImageFlippedX)
			self.baseQuarterVert:draw(32+8,32,gfx.kImageFlippedXY)
			self.baseGunVert:draw(32,32-8)

			self:setCollideRect(0, 0, 32 * 2 + 8, 32 * 2)
		else
			self.baseQuarterHoriz:draw(0,0)
			self.baseQuarterHoriz:draw(32,0,gfx.kImageFlippedX)
			self.baseQuarterHoriz:draw(0,32+8,gfx.kImageFlippedY)
			self.baseQuarterHoriz:draw(32,32+8,gfx.kImageFlippedXY)
			self.baseGunHoriz:draw(32-8,32)

			self:setCollideRect(0, 0, 32 * 2, 32 * 2 + 8)
		end

		gfx.popContext()
	end

	function self:bulletHit(x, y)
		if self.isVertical then
			-- TODO: Figure how which dome or gun was hit
		else
			-- TODO: Figure how which dome or gun was hit
		end
	end

	-- Setup
	self:loadImages()
	self.isVertical = math.random(2) == 1
	self:setTag(SPRITE_TAGS.enemyBase)
	self:buildBase()
	self:moveTo(x, y)
	self:setZIndex(20)
	-- self:setCollideRect(0, 0, 3, 3)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)
	self:add()

	return self
end