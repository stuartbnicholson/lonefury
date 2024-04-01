-- Enemy AI helper functions
local geom = playdate.geometry

-- A formation is one or more enemies, attempting to fly in a pattern. There is a lead enemy that is performing the loiter, chase or avoid
-- and other enemy in the formation are chasing world points derived from a combination of lead world coordinates, heading and offset in formation
-- All formations are relative to the lead enemy at 0,0.
-- Enemies in formation can be killed. If the lead enemy is killed, the formation breaks into individual enemies, at least in original Bosconian.
-- This implies that LeadEnemy is in control of the formation.
local formationV <const> = {
    geom.point.new(0, 0),
    geom.point.new(-15, 15),
    geom.point.new(15, 15),
    geom.point.new(-30, 30),
    geom.point.new(30, 30)
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

-- Translate a formation around 0,0 and 0 degrees to the angle and world position
function CalcFormation(formation, angle, worldPosV, worldFormation)
    local r = math.rad(angle)
    local x, y
    local wx, wy
    for i = 1, #formation do
        x = formation[i].x
        y = formation[i].y

        -- Rotate each formation point by radian(angle) ...
        wx = x * math.cos(r) - y * math.sin(r)
        wy = y * math.cos(r) + x * math.sin(r)

        -- ... and translate to world coordinates
        worldFormation[i].dx = wx + worldPosV.dx
        worldFormation[i].dy = wy + worldPosV.dy
    end
end