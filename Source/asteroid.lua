import "CoreLibs/sprites"

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

local asteroidImg, err = gfx.image.new("images/asteroid.png")
assert(asteroidImg, err)

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
        -- Should we add/remove sprites? This is harder book-keeping and we'd STILL need an update function to be called...?
        -- We'd still need an update function to be called for some entities that are active off-screen like bombers too...
        if NearViewport(self.worldX, self.worldY, self.width, self.height) then
            self:moveTo(WorldToViewPort(self.worldX, self.worldY))
            self:setVisible(true)
        else
            self:setVisible(false)
        end
    end

    function self:bulletHit(x, y)
        Explode(ExplosionSmall, self:getPosition())
        self:setVisible(false)
        self:remove()

        Player:scored(POINTS)
    end

    return self
end