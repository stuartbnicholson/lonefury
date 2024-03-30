import "utility"
import "Assets"

local gfx = playdate.graphics

Enemy = {}
Enemy.__index = Enemy

local enemyTable = Assets.getImagetable('images/enemy-table-15-15.png')

local POINTS <const> = 15
local SPEED <const> = 2.0

function Enemy.new()
    local self = gfx.sprite:new(enemyTable:getImage(1))
    self.imgTable = enemyTable  -- TODO: Enemies could have different appearance
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(15)
	self:setCollideRect(2, 2, 11, 10)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_OBSTACLE)

    -- Pool management
    function self:spawn(worldX, worldY)
        self.worldX = worldX
        self.worldY = worldY
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

    function self:doLOSChase()
        --[[ TODO:
            Vector u, v;
            bool left = false;
            bool right = false;
            u = VRotate2D(-Predator.fOrientation,
            (Prey.vPosition - Predator.vPosition));
            u.Normalize();
            if (u.x < -_TOL)
            left = true;
            else if (u.x > _TOL)
            right = true;
            Predator.SetThrusters(left, right);
        ]]
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
            self.angle = self:turnTowards(self.worldX, self.worldY, pWX, pWY, self.angle)
            SetTableImage(self.angle, self, self.imgTable)
        end

        self.worldX -= -math.sin(math.rad(self.angle)) * SPEED
        self.worldY -= math.cos(math.rad(self.angle)) * SPEED

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(self.worldX, self.worldY, self.width, self.height) then
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        self:moveTo(WorldToViewPort(self.worldX, self.worldY))

        local _,_,c,n = self:checkCollisions(self.x, self.y)
        for i=1,n do
            if self:alphaCollision(c[i].other) then
                self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                break
            end
        end
    end

    function self:collision(other, x, y)
        Explode(ExplosionSmall, self:getPosition())

        self:despawn()
    end

    function self:bulletHit(other, x, y)
        Explode(ExplosionSmall, self:getPosition())

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(POINTS)
        end

        self:despawn()
    end

    return self
end