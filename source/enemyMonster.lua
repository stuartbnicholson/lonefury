-- An unkillable beast that will destroy the player should they wander too far out of the play area

local pd = playdate
local gfx = pd.graphics
local geom = pd.geometry

local ENEMYMONSTER_SPEED = 2.8 * 3
local ENEMYMONSTER_TURN_ANGLE = 5 * 3
local ROAR_DELAY_MS = 500

EnemyMonster = {}
EnemyMonster.__index = EnemyMonster

function EnemyMonster.new()
    local imgTable = Assets.getImagetable('images/enemyMonster-table-45-45.png')
    local self = gfx.sprite:new(imgTable:getImage(1))
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.enemyMonster)
    self:setZIndex(30)
    self:setCollideRect(2, 2, 41, 40)
    self:setGroupMask(GROUP_ENEMYMONSTER)
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
        self.visibleMS = nil
        self.roared = nil

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
        self.brain(self)

        local viewX, viewY = WorldToViewPort(self.worldV.dx, self.worldV.dy)

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(viewX, viewY, self.width, self.height) then
            self:setVisible(true)
            if not self.visibleMS then
                self.visibleMS = pd.getCurrentTimeMilliseconds()
            elseif pd.getCurrentTimeMilliseconds() - self.visibleMS > ROAR_DELAY_MS and not self.roared then
                SoundManager:roar()
                self.roared = true
                self.visibleMS = nil
            end

            -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
            local c, n
            viewX, viewY, c, n = self:moveWithCollisions(viewX, viewY)
            for i = 1, n do
                if self:alphaCollision(c[i].other) == true then
                    self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                    break
                end
            end
        else
            -- We cheat here. Enemies IGNORE off-screen collisions, or they will not make it to the Player areas.
            self:setVisible(false)
            self:moveTo(viewX, viewY)
        end

        self.worldV.dx, self.worldV.dy = ViewPortToWorld(viewX, viewY)
    end

    function self:collisionResponse(other)
        return gfx.sprite.kCollisionTypeOverlap
    end

    function self:collision(other, x, y)
        -- The monster destroys everything it hits so we treat it as a big bullet
        other:bulletHit(self, x, y)
    end

    function self:bulletHit(other, x, y)
        -- The monster cares not for your bullets
    end

    return self
end
