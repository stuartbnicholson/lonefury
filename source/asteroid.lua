import 'CoreLibs/sprites'

import 'assets'

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

local asteroidImg = Assets.getImage('images/asteroid.png')

function Asteroid.new()
    local self = gfx.sprite.new(asteroidImg)
    self:setTag(SPRITE_TAGS.asteroid)
    self:setVisible(false)
    self:setZIndex(10)
    self:setCollideRect(2, 2, 12, 12)
    self:setGroupMask(GROUP_OBSTACLE)
    self:setCollidesWithGroupsMask(GROUP_PLAYER|GROUP_BULLET|GROUP_ENEMY|GROUP_ENEMY_BASE)

    -- Pool management
    function self:spawn(worldX, worldY)
        self.worldX = worldX
        self.worldY = worldY
        self.isSpawned = true

        self:add()
    end

    function self:despawn()
        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    function self:update()
        -- TODO: visible only controls drawing, not being part of collisions. etc.
        local viewX, viewY = WorldToViewPort(self.worldX, self.worldY)

        if NearViewport(viewX, viewY, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
        -- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        self:moveTo(viewX, viewY)
    end

    function self:bulletHit(other, x, y)
        Explode(ExplosionSmall, self.worldX, self.worldY)

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(SCORE_ASTEROID, Asteroid)
        end

        self:despawn()
    end

    return self
end
