local gfx = playdate.graphics

Egg = {}
Egg.__index = Egg

local eggImg = Assets.getImage('images/egg.png')

function Egg.new()
    local self = gfx.sprite.new(eggImg)
    self:setTag(SPRITE_TAGS.egg)
    self:setVisible(false)
    self:setZIndex(10)
    self:setCollideRect(2, 2, 15, 15)
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
        local viewX, viewY = WorldToViewPort(self.worldX, self.worldY)
        -- TODO: visible only controls drawing, not being part of collisions. etc.
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
            Player:scored(SCORE_EGG, Egg)
        end

        self:hatch()
        self:despawn()
    end

    function self:hatch()
        -- Spawn an enemy if we can find one
        local enemy = PoolManager:freeInPool(Enemy)
        if enemy then
            -- Make it fly away from the player for a short period of time
            SetEnemyTimerBrain(enemy, EnemyBrainAvoidPlayer, 500, EnemyBrainChasePlayer)
            enemy:spawn(self.worldX, self.worldY, Player:getAngle())
        end
    end

    return self
end
