local gfx = playdate.graphics
local geom = playdate.geometry

local ENEMY_SPEED = 2.8
ENEMY_TURN_ANGLE = 5

local ENEMY_ART = {
    jelly = 1,
    boomerang = 2,
    dragonfly = 3
}
local enemyArt = {}
enemyArt[ENEMY_ART.jelly] = Assets.getImagetable('images/enemy-table-15-15.png')
enemyArt[ENEMY_ART.boomerang] = Assets.getImagetable('images/enemy2-table-15-15.png')
enemyArt[ENEMY_ART.dragonfly] = Assets.getImagetable('images/enemy3-table-15-15.png')

Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    -- TODO: This is almost a bug. Every enemy starts as boomerang when the game is launched. Over time they get converted
    -- to other enemy types as they're included in formations (see makeFormationLeader). This means when you launch the game you'll
    -- see boomerangs, and as you play the other types will start to appear. To be honest this kinda works for me, so I've left it this way.
    local imgTable = enemyArt[ENEMY_ART.boomerang]
    local self = gfx.sprite:new(imgTable:getImage(1))
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.enemy)
    self:setZIndex(30)
    self:setCollideRect(2, 2, 11, 10)
    self:setGroupMask(GROUP_ENEMY)
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
    function self:spawn(worldX, worldY, angle)
        self.worldV.dx = worldX
        self.worldV.dy = worldY
        if angle then
            self.angle = angle
        else
            self.angle = 0
        end
        SetTableImage(self.angle, self, self.imgTable)
        self.velocity.dx = 0
        self.velocity.dy = 0
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
            return gfx.sprite.kCollisionTypeSlide
        else
            return gfx.sprite.kCollisionTypeOverlap
        end
    end

    function self:update()
        -- As enemy bombers are always in flight, regardless if they're in the viewport or not, we always update them...

        -- Apply the enemy brain which will update position
        self.brain(self)

        local viewX, viewY = WorldToViewPort(self.worldV.dx, self.worldV.dy)

        -- TODO: visible only controls drawing, not being part of collisions. etc.
        if NearViewport(viewX, viewY, self.width, self.height) then
            LevelManager.activeEnemy += 1
            self:setVisible(true)

            -- Regardless we still have to move sprites relative to viewport, otherwise collisions occur incorrectly
            local c, n
            viewX, viewY, c, n = self:moveWithCollisions(viewX, viewY)
            for i = 1, n do
                if c[i].other:getGroupMask() == GROUP_ENEMY then
                    -- If two enemies visibly collide, if it's a head on or t-bone, this enemy is destroyed
                    local dAngle = math.abs(self.angle - c[i].other.angle)
                    if dAngle > 180 then dAngle -= 180 end
                    if dAngle > 140 and dAngle < 220 then
                        self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                        break;
                    end
                else
                    if self:alphaCollision(c[i].other) == true then
                        self:collision(c[i].other, c[i].touch.x, c[i].touch.y)
                        break
                    end
                end
            end
        else
            -- We cheat here. Enemies IGNORE off-screen collisions, or they will not make it to the Player areas.
            self:setVisible(false)
            self:moveTo(viewX, viewY)
        end

        self.worldV.dx, self.worldV.dy = ViewPortToWorld(viewX, viewY)
    end

    function self:collision(other, x, y)
        -- We cheat here too just in case. Enemies IGNORE off-screen collisions, or they will not make it to the Player area.
        if self:isVisible() then
            -- Special case: colliding with a mine detonates it
            if other:getTag() == SPRITE_TAGS.mine then
                other:explode()
            end

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
            Player:scored(SCORE_ENEMY, Enemy)
        end

        self:despawn()
    end

    ----------------------------------------
    -- Formation management
    ----------------------------------------
    function self:makeFormationLeader(wingmen)
        -- leader doesn't care about the formation, the wingmen have to fly formation around leader
        self.brain = EnemyBrainChasePlayer
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
