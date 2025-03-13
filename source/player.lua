-- The one and only Player sprite, which is a special case because it's controlled by player input
-- and it's being 'alive' or not is separated from sprite functionality so it can be animated re-spawning etc.

local pd = playdate
local gfx = pd.graphics
local geom = pd.geometry

local PLAYER_WIDTH = 15
local PLAYER_HEIGHT = 15
local SPEED <const> = 3.5
local FWD_BULLET_SPEED <const> = 10.0
local REAR_BULLET_SPEED <const> = FWD_BULLET_SPEED - SPEED
local FIRE_MS = 330

local imgTable = Assets.getImagetable('images/player-table-15-15.png')

Player = {}
Player.__index = Player

function Player:new()
    local img, err = gfx.image.new(PLAYER_WIDTH, PLAYER_HEIGHT)
    assert(img, err)

    local self = gfx.sprite:new(img)
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.player)
    -- While the player's worldX, worldY change, the player sprite never deviates from the centre of the Viewport.
    -- The Viewport also chases the player's worldX, worldY too.
    self:moveTo(HALF_VIEWPORT_WIDTH, HALF_VIEWPORT_HEIGHT)
    self:setZIndex(100)
    self:setCollideRect(2, 2, 11, 11)
    self:setGroupMask(GROUP_PLAYER)
    self:setCollidesWithGroupsMask(GROUP_ENEMY|GROUP_ENEMY_BASE|GROUP_OBSTACLE)

    self.worldV = geom.vector2D.new(WORLD_PLAYER_STARTX, WORLD_PLAYER_STARTY)
    self.deltaX = 0
    self.deltaY = 0
    self.lastFiredMs = 0
    self.destroyed = {}

    function self:reset()
        self:resetAngle()
        self.lives = 3
        self.extraLives = 0
        self.score = 0
        self.shotsFired = 0
        self.shotsHit = 0
        self.isAlive = false

        self.destroyed[Asteroid] = 0
        self.destroyed[Egg] = 0
        self.destroyed[Enemy] = 0
        self.destroyed[EnemyBase] = 0
        self.destroyed[Mine] = 0
    end

    function self:getWorldV()
        return self.worldV
    end

    function self:getWorldDelta()
        return self.deltaX, self.deltaY
    end

    function self:resetAngle()
        self:crankAngle()
    end

    function self:getAngle()
        return self.angle
    end

    function self:spawn()
        assert(self.lives > 0)
        self.angle = 0
        SetTableImage(self.angle, self, self.imgTable)
        self:setVisible(true)

        self.worldV.dx = WORLD_PLAYER_STARTX
        self.worldV.dy = WORLD_PLAYER_STARTY

        -- TODO: add() is called multiple times. See StateRespawn. Is this an issue?
        self:add()
    end

    function self:alive()
        return self.isAlive
    end

    function self:setAlive(alive)
        self.isAlive = alive
        if alive then
            -- Spawning isn't the same as being alive!
            self:setVisible(true)
        else
            self.deltaX = 0
            self.deltaY = 0
        end
    end

    -- Only called if sprite is in sprite list
    function self:update()
        self.worldV.dx -= self.deltaX * SPEED
        self.worldV.dy -= self.deltaY * SPEED

        if self.isAlive then
            local _, _, c, n = self:checkCollisions(self.x, self.y)
            if n > 0 then
                for i = 1, #c do
                    if self:alphaCollision(c[i].other) == true then
                        -- The first real collision is sufficient to kill the player
                        self:collide(c[i].other)
                        break
                    end
                end
            end
        end
    end

    function self:getScore()
        return self.score
    end

    function self:getDestroyed()
        return self.destroyed
    end

    function self:scored(points, obj)
        self.score += points

        if obj ~= nil then
            self.destroyed[obj] += 1
        end

        -- Player has scored, ergo they've hit something
        self.shotsHit += 1

        -- Add an extra life every X points, have to track them separately so we don't add too many!
        local extraLives = math.floor(self.score / SCORE_EXTRALIFE)
        gfx.setScreenClipRect(400 - DASH_WIDTH, 0, DASH_WIDTH, VIEWPORT_HEIGHT)
        if self.extraLives < extraLives and self.lives < MAX_LIVES then
            self.extraLives += 1
            self.lives += 1
            SoundManager:playerExtraLife()
            Dashboard:drawLives()
        end

        Dashboard:drawPlayerScore()
        gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
    end

    function self:collide(other)
        self:remove()
        self.isAlive = false
        self.deltaX = 0
        self.deltaY = 0

        -- Special case: colliding with a mine detonates it
        if other:getTag() == SPRITE_TAGS.mine then
            other:explode()
        end

        SoundManager:playerDies()
        Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy, true)
    end

    function self:thrust()
        self.deltaX, self.deltaY = AngleToDeltaXY(self.angle)
    end

    function self:bulletHit(other, x, y)
        self:collide(other)
    end

    function self:fire()
        -- If we haven't fired recently we can fire
        local now = pd.getCurrentTimeMilliseconds()
        if now - self.lastFiredMs >= FIRE_MS then
            -- If we can find two free player bullets, we can fire
            local bullets = PoolManager:freeInPool(PlayerBullet, 2)
            if bullets and #bullets == 2 then
                SoundManager:playerShoots()
                local deltaX = -math.sin(math.rad(self.angle))
                local deltaY = math.cos(math.rad(self.angle))
                -- Forward
                bullets[1]:spawn(self.worldV.dx, self.worldV.dy, self.angle, -deltaX * FWD_BULLET_SPEED,
                    -deltaY * FWD_BULLET_SPEED)
                -- Rear
                bullets[2]:spawn(self.worldV.dx, self.worldV.dy, self.angle, deltaX * REAR_BULLET_SPEED,
                    deltaY * REAR_BULLET_SPEED)
                self.lastFiredMs = now
                self.shotsFired += 1
            end
        end
    end

    function self:left()
        if self.angle == 0 then
            self.angle = 360 - ROTATE_SPEED
        else
            self.angle -= ROTATE_SPEED
        end

        SetTableImage(self.angle, self, self.imgTable)
    end

    function self:right()
        if self.angle == 360 - ROTATE_SPEED then
            self.angle = 0
        else
            self.angle += ROTATE_SPEED
        end

        SetTableImage(self.angle, self, self.imgTable)
    end

    function self:crankAngle()
        local angle = pd.getCrankPosition()
        if angle ~= self.angle then
            -- Ensure the angle is within the 0-360 range
            angle = angle % 360
            -- Calculate the nearest multiple of 15
            local rounded = math.floor((angle + 7.5) / 15) * 15
            angle = rounded % 360

            self.angle = angle
            SetTableImage(self.angle, self, self.imgTable)
        end
    end

    self:reset()
    return self
end
