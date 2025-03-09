-- MineExplosions differ from Explosions, they render the same but are actually dangerous sprites. Colliding with them will kill the player and enemies.
local gfx = playdate.graphics

MineExplosion = {}
MineExplosion.__index = MineExplosion

local imgTable = Assets.getImagetable('images/explolarge-table-32-32.png')

function MineExplosion.new()
    local self = gfx.sprite.new(imgTable:getImage(1))
    self:setTag(SPRITE_TAGS.mineExplosion)
    self:setVisible(false)
    self:setZIndex(10)
    self:setCollideRect(0, 0, 32, 32)
    self:setGroupMask(GROUP_OBSTACLE)
    self:setCollidesWithGroupsMask(GROUP_PLAYER|GROUP_ENEMY)
    self:moveTo(-100, -100)

    self.loop = gfx.animation.loop.new(120, imgTable, false)
    self.worldX = -100 -- Start offscreen
    self.worldY = -100

    -- Pool management
    function self:spawn(worldX, worldY)
        self.worldX = worldX
        self.worldY = worldY
        self.loop.frame = 1
        self.loop.paused = false
        self.isSpawned = true

        self:add()
    end

    function self:despawn()
        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    function self:bulletHit(other, x, y)
        -- Bullets can hit the mineExplosion because it's treated as an obstacle, but they have no effect.
    end

    function self:update()
        local viewX, viewY = WorldToViewPort(self.worldX, self.worldY)

        if NearViewport(viewX, viewY, self.width, self.height) then
            self:setImage(self.loop:image())
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
        -- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        self:moveTo(viewX, viewY)

        if not self.loop:isValid() then
            self:despawn()
        end
    end

    return self
end
