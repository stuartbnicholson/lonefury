import 'utility'
import 'assets'
import 'enemyAI'

-- An unkillable beast that will destroy the player should they wander too far out of the play area

local gfx = playdate.graphics
local geom = playdate.geometry

ENEMYMONSTER_SPEED = 2.8 * 3
ENEMYMONSTER_TURN_ANGLE = 5 * 3

EnemyMonster = {}
EnemyMonster.__index = EnemyMonster

function EnemyMonster.new()
    local imgTable = Assets.getImagetable('images/enemyMonster-table-45-45.png')
    local self = gfx.sprite:new(imgTable:getImage(1))
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(30)
    self:setCollideRect(2, 2, 41, 40)
    self:setGroupMask(GROUP_ENEMY)
    self:setCollidesWithGroupsMask(GROUP_OBSTACLE|GROUP_ENEMY)
    self.worldV = geom.vector2D.new(0, 0)
    self.velocity = geom.vector2D.new(0, 0)

    -- AI management
    self.tmpVector = geom.vector2D.new(0, 0)
    self.tmpVector2 = geom.vector2D.new(0, 0)
    self.brain = EnemyBrainChasePlayer
    self.angle = 0
    self.speed = ENEMYMONSTER_SPEED
    self.maxSpeed = ENEMYMONSTER_SPEED
    self.turnAngle = ENEMYMONSTER_TURN_ANGLE

    function self:setArt(imgTable)
        self.imgTable = imgTable
        SetTableImage(self.angle, self, self.imgTable)
    end

    function self:setAngle(angle)
        self.angle = angle
        SetTableImage(self.angle, self, self.imgTable)
    end

    -- Pool management
    function self:spawn(worldX, worldY)
        self.worldV.dx = worldX
        self.worldV.dy = worldY
        self.angle = 0
        self.velocity.dx = 0
        self.velocity.dy = 0
        self:setImage(self.imgTable:getImage(1))
        self.isSpawned = true

        self:add()

        -- Set initial position without collision
        local x, y = WorldToViewPort(worldX, worldY)
        self:moveTo(x, y)
    end

    function self:despawn()
        -- return to default player chase
        self.brain = EnemyBrainChasePlayer
        self.speed = ENEMYMONSTER_SPEED
        self.maxSpeed = ENEMYMONSTER_SPEED
        self.turnAngle = ENEMYMONSTER_TURN_ANGLE

        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    function self:update()
        -- Apply the enemy brain which will update position
        assert(self.brain, 'Enemy has no brain')
        self.brain(self)

        local viewX, viewY = WorldToViewPort(self.worldV.dx, self.worldV.dy)

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(viewX, viewY, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
        -- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        local c, n
        viewX, viewY, c, n = self:moveWithCollisions(viewX, viewY)
        for i = 1, n do
            if c[i].other:getGroupMask() ~= GROUP_ENEMY and self:alphaCollision(c[i].other) == true then
                self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                break
            end
        end

        self.worldV.dx, self.worldV.dy = ViewPortToWorld(viewX, viewY)
    end

    function self:collision(other, x, y)
        -- The monster cares not for your collisions
    end

    function self:bulletHit(other, x, y)
        -- The monster cares not for your bullets
    end

    return self
end
