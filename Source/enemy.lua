import "utility"
import "Assets"

local gfx = playdate.graphics
local geom = playdate.geometry

Enemy = {}
Enemy.__index = Enemy

local enemyTable = Assets.getImagetable('images/enemy-table-15-15.png')

local POINTS <const> = 15
local SPEED <const> = 2.0
local TURN_ANGLE = 5

function Enemy.new()
    local self = gfx.sprite:new(enemyTable:getImage(1))
    self.imgTable = enemyTable  -- TODO: Enemies could have different appearance
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(15)
	self:setCollideRect(2, 2, 11, 10)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_OBSTACLE)
    self.worldV = geom.vector2D.new(0, 0)

    -- Pool management
    function self:spawn(worldX, worldY)
        self.worldV.dx = worldX
        self.worldV.dy = worldY
        self.angle = 0
        self:setImage(enemyTable:getImage(1))
        self.isSpawned = true

        self:add()
    end

    function self:despawn()
        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    function self:roundToNearestMultiple(number, multiple)
        local sign = number >= 0 and 1 or -1
        number = math.abs(number)
        local remainder = number % multiple
        if remainder >= multiple / 2 then
            number = number + multiple - remainder
        else
            number = number - remainder
        end
        return sign * number
    end

    -- See OReilly AI for Game Developers
    function self:Vrotate2d(angle, uV)
        local x, y

        x = uV.x * math.cos(math.rad(-angle)) + uV.y * math.sin(math.rad(-angle));
        y = -uV.x * math.sin(math.rad(-angle)) + uV.y * math.cos(math.rad(-angle));

        return geom.vector2D.new(x, y)
    end

    function self:doLOSChase()
        local TOL = 1e-10
        local u = self:Vrotate2d(-self.angle, (Player.worldV - self.worldV))
        u:normalize()
        local left = u.dx < -TOL
        local right = u.dx > TOL

        if left and not right then
            self.angle -= TURN_ANGLE
        elseif right and not left then
            self.angle += TURN_ANGLE
        end
        self.angle = (self.angle + 360) % 360
    end

    function self:turnTowards(x, y, targetX, targetY, currentAngle)
        local angle = PointsAngle(x, y, targetX, targetY)

        -- Turn angle has to be divisble by ROTATE_SPEED so we have the appropriate image
        angle = self:roundToNearestMultiple(math.floor(angle), ROTATE_SPEED)

        -- TODO: Actually it doesn't matter really, turnRate only explodes if enemy is on top of player
        -- local turnRate = math.abs(currentAngle - angle) / ROTATE_SPEED

        return angle
    end

    function self:update()
        -- As enemy bombers are always in flight, regardless if they're in the viewport or not, we always update them...
        if Player.isAlive then
            -- ...however they only ever chase live players
            local pWX, pWY = Player:getWorldPosition()
            -- TODO: Original hackery which has issues with turning on a dime etc.
            -- self.angle = self:turnTowards(self.worldV.dx, self.worldV.dy, pWX, pWY, self.angle)
            -- TODO: The turn logic derived from O'Reilly code
            self:doLOSChase()
            SetTableImage(self.angle, self, self.imgTable)
        end

        self.worldV.dx -= -math.sin(math.rad(self.angle)) * SPEED
        self.worldV.dy -= math.cos(math.rad(self.angle)) * SPEED

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(self.worldV.dx, self.worldV.dy, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        self:moveTo(WorldToViewPort(self.worldV.dx, self.worldV.dy))

        local _,_,c,n = self:checkCollisions(self.x, self.y)
        for i=1,n do
            if self:alphaCollision(c[i].other) then
                self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                break
            end
        end
    end

    function self:collision(other, x, y)
        if self:isVisible() then
            Explode(ExplosionSmall, self:getPosition())
            SoundManager:enemyDies()
        end

        self:despawn()
    end

    function self:bulletHit(other, x, y)
        if self:isVisible() then
            Explode(ExplosionSmall, self:getPosition())
            SoundManager:enemyDies()
        end

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(POINTS)
        end

        self:despawn()
    end

    return self
end