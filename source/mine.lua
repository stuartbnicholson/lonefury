local gfx = playdate.graphics

Mine = {}
Mine.__index = Mine

local mineImg = Assets.getImage('images/mine.png')

function Mine.new()
    local self = gfx.sprite.new(mineImg)
    self:setTag(SPRITE_TAGS.mine)
    self:setVisible(false)
    self:setZIndex(10)
    self:setCollideRect(0, 0, 15, 15)
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
        -- Mine explosions should are DANGEROUS, so they're a separate sprite
        self:explode()

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(SCORE_MINE, Mine)
        end
    end

    function self:explode()
        self:despawn()

        -- Find and spawn a MineExplosion
        local poolObj = PoolManager:freeInPool(MineExplosion)
        if poolObj then
            SoundManager:largeExplosion()
            poolObj:spawn(self.worldX, self.worldY)
        end
    end

    return self
end
