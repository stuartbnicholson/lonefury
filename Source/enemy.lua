import 'utility'
import 'assets'
import 'enemyAI'

local gfx = playdate.graphics
local geom = playdate.geometry

local enemyTable = Assets.getImagetable('images/enemy-table-15-15.png')

local POINTS <const> = 15
local SPEED <const> = 2.5
ENEMY_TURN_ANGLE = 5

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
    self.brain = EnemyBrainChasePlayer
    self.speed = SPEED
    self.maxSpeed = SPEED
    self.turnAngle = ENEMY_TURN_ANGLE

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
        -- Formation cleanup
        if self.formationWingmen then
            -- Leader needs to tell all surviving wingmen they're not longer in formation
            self:formationLeaderDied()
        elseif self.formationLeader then
            -- Wingman needs to tell leader they're out of formation if they are dead
            self.formationLeader:formationWingmanDead(self.formationPos)
        end
        -- Make doubly sure all formation info clear
        self.formationWingmen = nil
        self.formationLeader = nil
        self.formationPos = nil
        self.formation = nil

        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    function self:update()
        -- As enemy bombers are always in flight, regardless if they're in the viewport or not, we always update them...

        -- Apply the enemy brain
        assert(self.brain, 'Enemy has no brain')
        self.brain(self)

        local r = math.rad(self.angle)
        self.worldV.dx -= -math.sin(r) * self.speed
        self.worldV.dy -= math.cos(r) * self.speed

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
            Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy)
            SoundManager:enemyDies()
        end

        self:despawn()
    end

    function self:bulletHit(other, x, y)
        if self:isVisible() then
            Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy)
            SoundManager:enemyDies()
        end

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(POINTS)
        end

        self:despawn()
    end

    ----------------------------------------
    -- Formation management
    ----------------------------------------

    function self:makeFormationLeader(wingmen)
        -- leader doesn't care about the formation, the wingmen have to fly formation around leader
        self.formationWingmen = wingmen
    end

    -- The leader of this formation is dead, tell all the wingmen
    function self:formationLeaderDied()
        for i = 1, #self.formationWingmen do
            if self.formationWingmen[i] then
                self.formationWingmen[i]:formationLeaderDead()
            end
        end
        self.formationWingmen = nil
    end

    -- Individual wingman handler
    function self:formationLeaderDead()
        -- Brain will change on next update
        self.formationLeader = nil
        self.formationPos = nil
        self.formation = nil
    end

    function self:makeFormationWingman(leader, formation, formationPos)
        self.formationLeader = leader
        self.formation = formation
        self.formationPos = formationPos
        self.brain = EnemyBrainFlyFormation
        self.turnAngle *= 3
    end

    -- A wingman in this leader's formation is dead
    function self:formationWingmanDead(formationPos)
        print('My wingman died ', formationPos)
        self.formationWingmen[formationPos] = nil
    end

    return self
end