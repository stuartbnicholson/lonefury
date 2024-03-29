import "Assets"
import "CoreLibs/sprites"

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

local asteroidImg = Assets.getImage('images/asteroid.png')

function Asteroid.new(worldX, worldY)
    local POINTS <const> = 5

    local self = gfx.sprite.new(asteroidImg)
    self:setTag(SPRITE_TAGS.asteroid)
    self.worldX = worldX
    self.worldY = worldY
    self:setVisible(false)
    self:setZIndex(10)
    self:setCollideRect(2, 2, 12, 12)
    self:setGroupMask(GROUP_ENEMY)
    self:setCollidesWithGroupsMask(GROUP_PLAYER|GROUP_BULLET)
    self:add()

    function self:update()
        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(self.worldX, self.worldY, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
		self:moveTo(WorldToViewPort(self.worldX, self.worldY))
    end

    function self:bulletHit(x, y)
        Explode(ExplosionSmall, self:getPosition())
        self:setVisible(false)
        self:remove()

        Player:scored(POINTS)
    end

    return self
end