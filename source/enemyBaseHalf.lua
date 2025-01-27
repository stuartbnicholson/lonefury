-- One half of an enemy base
import 'assets'

local pd = playdate
local gfx = pd.graphics

-- EnemyBase images
local baseHalfVert = Assets.getImage('images/baseHalfVert.png')
local baseHalfHoriz = Assets.getImage('images/baseHalfHoriz.png')
local baseRuin1 = Assets.getImage('images/baseRuin1.png')
local baseRuin2 = Assets.getImage('images/baseRuin2.png')
local baseSphereMask = Assets.getImage('images/baseSphereMask.png')
local crossImg = Assets.getImage('images/cross.png')

local COLLIDE_BOUNDARY <const> = 1

EnemyBaseHalf = {}
EnemyBaseHalf.__index = EnemyBaseHalf

function EnemyBaseHalf.new(enemyBase, worldX, worldY, isVertical, isFlipped, spheres)
    -- One half of an enemy base, may be flipped horiz or vertically
    local self = gfx.sprite.new()
    self.enemyBase = enemyBase
    self.isVertical = isVertical
    self.isFlipped = isFlipped
    self.spheres = spheres

    if self.isVertical then
        self.flip = (self.isFlipped and gfx.kImageFlippedX) or gfx.kImageUnflipped
        self:setImage(gfx.image.new(baseHalfVert:getSize()))
        self:setCollideRect((self.isFlipped and 0) or COLLIDE_BOUNDARY, COLLIDE_BOUNDARY, 32 - COLLIDE_BOUNDARY,
            64 - (COLLIDE_BOUNDARY << 1))
    else
        self.flip = (self.isFlipped and gfx.kImageFlippedY) or gfx.kImageUnflipped
        self:setImage(gfx.image.new(baseHalfHoriz:getSize()))
        self:setCollideRect(COLLIDE_BOUNDARY, (self.isFlipped and 0) or COLLIDE_BOUNDARY, 64 - (COLLIDE_BOUNDARY << 1),
            32 - COLLIDE_BOUNDARY)
    end

    self:setTag(SPRITE_TAGS.enemyBase)
    self:setZIndex(22) -- 20 is the base gun, 21 is the gun shield, 22 is the base sides, so we can hide the gunshield under the base sides...
    self:setGroupMask(GROUP_ENEMY_BASE)
    self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)

    function self:spawn()
        -- Reset base halves back to undamaged
        gfx.pushContext(self:getImage())
        local w, h = self:getImage():getSize()
        gfx.setColor(gfx.kColorClear)
        gfx.drawRect(0, 0, w, h)
        if self.isVertical then
            baseHalfVert:draw(0, 0, self.flip)
        else
            baseHalfHoriz:draw(0, 0, self.flip)
        end
        gfx.popContext()

        self:add()
    end

    function self:despawn()
        self:remove()
    end

    function self:bulletHit(bullet, cx, cy)
        -- Sprites are default positioned by centre
        local x, y = self:getPosition()
        local w, h = self:getImage():getSize()
        x = cx - x + (w >> 1)
        y = cy - y + (h >> 1)

        local v = (self.isVertical and y) or x
        if v < 14 then
            self.enemyBase:sphereHit(self.spheres[1])
        elseif v > 23 and v < 39 then
            self.enemyBase:sphereHit(self.spheres[2])
        elseif v > 50 then
            self.enemyBase:sphereHit(self.spheres[3])
        end
    end

    return self
end
