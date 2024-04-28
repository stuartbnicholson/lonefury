import 'utility'
import 'assets'
import 'enemyAI'

local gfx = playdate.graphics
local geom = playdate.geometry

ENEMY_SPEED = 2.8
ENEMY_TURN_ANGLE = 5

ENEMY_ART = {
    jelly = 1,
    boomerang = 2
}
local enemyArt = {}
enemyArt[ENEMY_ART.jelly] = Assets.getImagetable('images/enemy-table-15-15.png')
enemyArt[ENEMY_ART.boomerang] = Assets.getImagetable('images/enemy2-table-15-15.png')

Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    local imgTable = enemyArt[ENEMY_ART.boomerang]
    local self = gfx.sprite:new(imgTable:getImage(1))
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(30)
	self:setCollideRect(2, 2, 11, 10)
	self:setGroupMask(GROUP_ENEMY)
	-- self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_OBSTACLE|GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_OBSTACLE|GROUP_ENEMY)
    self.worldV = geom.vector2D.new(0, 0)
    self.velocity = geom.vector2D.new(0, 0)

    -- AI management
    self.tmpVector = geom.vector2D.new(0, 0)
    self.tmpVector2 = geom.vector2D.new(0, 0)
    self.brain = EnemyBrainChasePlayer
    self.angle = 0
    self.speed = ENEMY_SPEED
    self.maxSpeed = ENEMY_SPEED
    self.turnAngle = ENEMY_TURN_ANGLE
    self.orbitDist = 0
    self.orbitV = nil

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

        -- return to default player chase
        self.brain = EnemyBrainChasePlayer
        self.speed = ENEMY_SPEED
        self.maxSpeed = ENEMY_SPEED
        self.turnAngle = ENEMY_TURN_ANGLE

        self:setVisible(false)
        self.isSpawned = false

        self:remove()
    end

    -- See sprite:moveWithCollisions
    function self:collisionResponse(other)
        if other:getGroupMask() == GROUP_ENEMY then
            -- Enemies bounce off each other
            return gfx.sprite.kCollisionTypeSlide
        else
            return gfx.sprite.kCollisionTypeOverlap
        end
    end

    function self:update()
        -- As enemy bombers are always in flight, regardless if they're in the viewport or not, we always update them...
        ACTIVE_ENEMY += 1
        if self.formationWingmen then
            ACTIVE_ENEMY_FORMATIONS += 1
        end

        -- Apply the enemy brain which will update position
        assert(self.brain, 'Enemy has no brain')
        self.brain(self)

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(self.worldV.dx, self.worldV.dy, self.width, self.height) then
            ACTIVE_VISIBLE_ENEMY += 1
            self:setVisible(true)
        else
            self:setVisible(false)
        end

        -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
		-- TODO: Other options include sprite:remove() and sprite:add(), but then we'd need to track this ourselves because update() won't be called
        local toX, toY = WorldToViewPort(self.worldV.dx, self.worldV.dy)
        local c, n
        -- self:moveTo(toX, toY)
        toX, toY, c, n = self:moveWithCollisions(toX, toY)
        for i=1,n do
            if c[i].other:getGroupMask() ~= GROUP_ENEMY and self:alphaCollision(c[i].other) == true then
                self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                break
            end
        end
        self.worldV.dx, self.worldV.dy = ViewPortToWorld(toX, toY)
    end

    function self:collision(other, x, y)
        -- We cheat here. Enemies IGNORE off-screen collisions, otherwise they'd never make it to the Player area.
        if self:isVisible() then
            Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy)
            SoundManager:enemyDies()

            self:despawn()
        end
    end

    function self:bulletHit(other, x, y)
        if self:isVisible() then
            Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy)
            SoundManager:enemyDies()
        end

        if other:getTag() == SPRITE_TAGS.playerBullet then
            Player:scored(SCORE_ENEMY)
        end

        self:despawn()
    end

    ----------------------------------------
    -- Formation management
    ----------------------------------------
    function self:makeFormationLeader(wingmen)
        -- leader doesn't care about the formation, the wingmen have to fly formation around leader
        self.formationWingmen = wingmen

        -- Random art for the leader, and random art for the wingmen, so sometimes they'll be different
        local leaderArt = lume.randomchoice(enemyArt)
        local wingmenArt = lume.randomchoice(enemyArt)

        self:setArt(leaderArt)
        for _, wingman in ipairs(wingmen) do
            wingman:setArt(wingmenArt)
        end
    end

    -- The leader of this formation is dead, tell all the wingmen
    function self:formationLeaderDied()
        for _, wingman in pairs(self.formationWingmen) do
            wingman:formationLeaderDead()
        end
        self.formationWingmen = nil

        -- Inform LevelManager formation has ended
        LevelManager:formationLeaderDied(self)
    end

    -- Individual wingman handler
    function self:formationLeaderDead()
        -- Brain will change on next update
        self.formationLeader = nil
        self.formationPos = nil
        self.formation = nil

        -- Return to normal speeds now we're out of formation
        self.speed = ENEMY_SPEED
        self.maxSpeed = ENEMY_SPEED
        self.turnAngle = ENEMY_TURN_ANGLE
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

    ----------------------------------------
    -- Orbit management
    ----------------------------------------
    function self:orbit(orbitV, orbitDist)
        self.orbitV = orbitV
        self.orbitDist = orbitDist
    end

    return self
end