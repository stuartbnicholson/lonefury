import 'utility'
import 'assets'
import 'enemyAI'

local gfx = playdate.graphics
local geom = playdate.geometry

local enemyTable = Assets.getImagetable('images/enemy-table-15-15.png')

local POINTS <const> = 15
local SPEED <const> = 2.0
local TURN_ANGLE = 5

Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    local self = gfx.sprite:new(enemyTable:getImage(1))
    self.imgTable = enemyTable  -- TODO: Enemies could have different appearance
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(30)
	self:setCollideRect(2, 2, 11, 10)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_OBSTACLE)
    self.worldV = geom.vector2D.new(0, 0)

    -- AI management
    self.tmpVector = geom.vector2D.new(0, 0)

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

    function self:update()
        -- As enemy bombers are always in flight, regardless if they're in the viewport or not, we always update them...
        if Player.isAlive then
            -- ...however they only ever chase live players
            local pWV = Player:getWorldV()

            -- TODO: Formation flying, evading, orbiting...more interesting options
            self.angle = DoLOSChase(self.angle, TURN_ANGLE, self.worldV, pWV, self.tmpVector)

            SetTableImage(self.angle, self, self.imgTable)
        end

        local r = math.rad(self.angle)
        self.worldV.dx -= -math.sin(r) * SPEED
        self.worldV.dy -= math.cos(r) * SPEED

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