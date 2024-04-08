-- Enemy AI helper functions
local pd = playdate
local geom = pd.geometry

local crossImg = Assets.getImage('images/cross.png')

-- A formation is one or more enemies, attempting to fly in a pattern. There is a lead enemy that is performing the loiter, chase or avoid
-- and other enemy in the formation are chasing world points derived from a combination of lead world coordinates, heading and offset in formation
-- All formations are relative to the lead enemy at 0,0.
-- Enemies in formation can be killed. If the lead enemy is killed, the formation breaks into individual enemies, at least in original Bosconian.
-- This implies that LeadEnemy is in control of the formation.
-- A formation also assumes the lead exists at geom.point.new(0, 0) and so isn't included in each formation list.
FormationV = {
    geom.point.new(-15, 15),
    geom.point.new(15, 15),
    geom.point.new(-30, 30),
    geom.point.new(30, 30)
}

FormationFlatV = {
    geom.point.new(-18, 9),
    geom.point.new(18, 9),
    geom.point.new(-36, 18),
    geom.point.new(33, 19),
}

--[[ Particularly long formations don't work that well, they tend to make the cheating more visible
FormationT = {
    geom.point.new(-15, 15),
    geom.point.new(15, 15),
    geom.point.new(0, 30),
    geom.point.new(0, 45)
}

FormationL = {
    geom.point.new(-15, 15),
    geom.point.new(-30, 30),
    geom.point.new(-45, 45),
    geom.point.new(-60, 60)
}

FormationR = {
    geom.point.new(15, 15),
    geom.point.new(30, 30),
    geom.point.new(45, 45),
    geom.point.new(60, 60)
}
]]--

Formations = {
    FormationV,
    FormationFlatV
}

-- See OReilly AI for Game Developers
local TOL = 1e-10

function Vrotate2d(angle, uV, tmpV)
    local r = math.rad(-angle)
    tmpV.dx = uV.x * math.cos(r) + uV.y * math.sin(r)
    tmpV.dy = -uV.x * math.sin(r) + uV.y * math.cos(r)

    return tmpV
end

-- Chase the targetV
function DoLOSChase(angle, turnAngle, enemyV, targetV, tmpV)
    tmpV = Vrotate2d(-angle, (targetV - enemyV), tmpV)
    tmpV:normalize()

    local left = tmpV.dx < -TOL
    local right = tmpV.dx > TOL
    if left and not right then
        angle -= turnAngle
    elseif right and not left then
        angle += turnAngle
    end

    return (angle + 360) % 360
end

-- Avoid the targetV
function DoLOSAvoid(angle, turnAngle, enemyV, targetV, tmpV)
    tmpV = Vrotate2d(-angle, (targetV - enemyV), tmpV)
    tmpV:normalize()

    local left = tmpV.dx > -TOL
    local right = tmpV.dx < TOL
    if left and not right then
        angle -= turnAngle
    elseif right and not left then
        angle += turnAngle
    end

    return (angle + 360) % 360
end

-- Avoid targetV until targetDistance, and then orbit targetV
function DoOrbit(angle, turnAngle, enemyV, targetDistance, targetV, tmpV)
    -- TODO:
end

-- Translate a formation position around 0,0 and 0 degrees to the angle and world position
function CalcFormation(formation, formationPos, angle, worldPosV)
    assert(formationPos > 0 and formationPos <= #formation, 'Invalid formation position')
    local r = math.rad(angle)
    local x, y
    local wx, wy
    x = formation[formationPos].x
    y = formation[formationPos].y

    -- Rotate each formation point by radian(angle) ...
    wx = x * math.cos(r) - y * math.sin(r)
    wy = y * math.cos(r) + x * math.sin(r)

    -- ... and translate to world coordinates
    return wx + worldPosV.dx, wy + worldPosV.dy
end

-- Enemy brain to chase the player
function EnemyBrainChasePlayer(self)
    if Player.isAlive then
        -- ...however they only ever chase live players
        local pWV = Player:getWorldV()

        self.angle = DoLOSChase(self.angle, self.turnAngle, self.worldV, pWV, self.tmpVector)
        SetTableImage(self.angle, self, self.imgTable)
    end

    local r = math.rad(self.angle)

    self.velocity.dx = math.sin(r) * self.speed
    self.velocity.dy = -math.cos(r) * self.speed

    self.worldV = self.worldV + self.velocity
end

-- Enemy brain to avoid the player
function EnemyBrainAvoidPlayer(self)
    if Player.isAlive then
        -- ...however they only ever avoid live players
        local pWV = Player:getWorldV()

        self.angle = DoLOSAvoid(self.angle, self.turnAngle, self.worldV, pWV, self.tmpVector)
        SetTableImage(self.angle, self, self.imgTable)
    end

    local r = math.rad(self.angle)
    self.worldV.dx -= -math.sin(r) * self.speed
    self.worldV.dy -= math.cos(r) * self.speed
end

-- Brain until time has elapsed then revert to another brain
function EnemyTimerBrain(self)
    local now = pd.getCurrentTimeMilliseconds()
    if now > self.brainTimer then
        self.brain = self.brainAfter

        self.brainTimer = nil
        self.brainAfter = nil
    else
        self.brainBefore(self)
    end
end

function SetEnemyTimerBrain(self, brainBefore, msTime, brainAfter)
    self.brainBefore = brainBefore
    self.brainTimer = pd.getCurrentTimeMilliseconds() + msTime
    self.brainAfter = brainAfter
    self.brain = EnemyTimerBrain
end

-- Enemy brain to follow in formation.
-- A more organic feel, but more math per enemy update!
function EnemyBrainFlyFormation(self)
    if self.formationLeader then
        local chaseX, chaseY = CalcFormation(self.formation, self.formationPos, self.formationLeader.angle, self.formationLeader.worldV)
        local chaseV = geom.vector2D.new(chaseX, chaseY) -- TODO: GC!

        --[[ TODO: Remove
        local vx, vy = WorldToViewPort(chaseV.dx, chaseV.dy)
        crossImg:draw(vx, vy)
        ]]--

        local d = PointsDistance(self.worldV.dx, self.worldV.dy, chaseX, chaseY)
        -- TODO: Distance seems to vary from 5 to 10 when moving
        self.speed = lume.clamp(d / self.maxSpeed, 0.1, self.maxSpeed * 2)

        self.angle = DoLOSChase(self.angle, self.turnAngle, self.worldV, chaseV, self.tmpVector)
        SetTableImage(self.angle, self, self.imgTable)
    else
        -- Used to have a formation leader and they've gone? Flee!
        -- TODO: Can revert to non-fleeing after some time
        self.turnAngle = ENEMY_TURN_ANGLE
        SetEnemyTimerBrain(self, EnemyBrainAvoidPlayer, 1500, EnemyBrainChasePlayer)
    end

    local r = math.rad(self.angle)
    self.worldV.dx -= -math.sin(r) * self.speed
    self.worldV.dy -= math.cos(r) * self.speed
end

-- Enemy brain, rigid formation based on the leader's position.
-- A less organic feel, but also less math per enemy update!
function EnemyBrainFlyFormationRigid(self, turnAngle)
    local formX, formY = CalcFormation(self.formation, self.formationPos, self.formationLeader.angle, self.formationLeader.worldV)
    self.worldV.dx = formX
    self.worldV.dy = formY

    self.angle = self.formationLeader.angle
    SetTableImage(self.angle, self, self.imgTable)
end

-- Enemy brain based on the Boids algorithm
local BOID_ALIGNMENT_MULT <const> = 0.5
local BOID_COHESION_MULT <const> = 0.2
local BOID_SEPARATION_MULT <const> = 1

local BOID_MAX_SPEED <const> = 2.6
local BOID_SEPARATION_DISTANCE <const> = 25

function EnemyBrainBoid(self)
    self.angle = RoundToNearestMultiple(VectorAngle(self.velocity), 15)
    SetTableImage(self.angle, self, self.imgTable)
    self.worldV += self.velocity

    local avgVelocity = self.avgVelocity
    avgVelocity.dx = 0
    avgVelocity.dy = 0

    local avgPosition = self.avgPosition
    avgPosition.dx = 0
    avgPosition.dy = 0

    local avgSeparation = self.avgSeparation
    avgSeparation.dx = 0
    avgSeparation.dy = 0

    local numOthers = 0
    local dist
    local diff = self.diff

    for _, other in pairs(self.flock) do
        if other ~= self then
            dist = VectorDistance(self.worldV, other.worldV)

            --[[ If it's a flock member, we always include it regardless
            if dist < BOID_PERCEPTION_RADIUS then
            ]] --
                avgVelocity = avgVelocity + other.velocity
                avgPosition = avgPosition + other.worldV
            -- end

            if dist < BOID_SEPARATION_DISTANCE then
                diff = self.worldV - other.worldV
                diff:scale(1 / dist)
                avgSeparation = avgSeparation + diff
            end

            numOthers += 1
        end
    end

    if numOthers > 0 then
        avgVelocity = avgVelocity / numOthers
        avgPosition = avgPosition / numOthers
        avgSeparation = avgSeparation / numOthers
    end

    self.velocity = self.velocity + (avgVelocity * BOID_ALIGNMENT_MULT)
    self.velocity = self.velocity + ((avgPosition - self.worldV) * BOID_COHESION_MULT)
    self.velocity = self.velocity - (avgSeparation * BOID_SEPARATION_MULT)

    if self.velocity:magnitude() > BOID_MAX_SPEED then
        self.velocity:normalize()
        self.velocity:scale(BOID_MAX_SPEED)
    end
end