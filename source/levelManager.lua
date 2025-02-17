import 'lume'

import 'constants'
import 'egg'
import 'enemy'
import 'enemyBase'
import 'enemyAI'

-- Generates levels! Sets up the minimap, sets enemy limits, bullet speeds etc.
-- Spawns amusing things like enemy formations.
-- Levels are largely laid out using JSON definitions of repeatable map areas.
-- Each area is assumed to be viewport size = 320 x 240
-- Also tracks things like level alerts, increasing difficulty etc.
local pd = playdate

-- Every two levels, enemy bases have an extra shot
local ENEMYBASE_SHOTS_LEVEL_RATIO <const> = 2
local ENEMYBASE_SHOTS_MIN <const> = 1
local ENEMYBASE_SHOTS_MAX <const> = 6
local ENEMYBASE_FIREMS_MAX <const> = 1500
local ENEMYBASE_FIREMS_MIN <const> = 200
local ENEMYBASE_FIREMS_LEVEL_REDUCTION <const> = 100
local ENEMYBASE_FIRST_SHIELD_LEVEL = 3 -- Bases start shielding their cores
local ENEMYBASE_FIRST_ZAP_LEVEL = 5    -- Bases start zapping from their open cores
local ENEMYBASE_ZAPMS_MAX <const> = 5000
local ENEMYBASE_ZAPMS_MIN <const> = 1500
local ENEMYBASE_ZAPMS_LEVEL_REDUCTION <const> = 150
local ENEMYBASEKILL_SECS_MIN = 8
local ENEMYBASEKILL_SECS_MAX = 25
local ENEMYBASEKILL_SECOND_LEVEL_DEC <const> = 3

-- Max enemy that we want visible on screen
local ENEMY_VISIBLE_MIN = 1
local ENEMY_VISIBLE_PER_LEVEL = 1
local ENEMY_VISIBLE_MAX = 8

local ENEMY_SPAWN_MIN_MS = 5500
local ENEMY_PLAYER_SPAWN_DISTANCE = 200

-- Maximum number of active formations
local FORMATION_SPAWN_MIN = 1
local FORMATION_SPAWN_PER_LEVEL = 0.25
local FORMATION_SPAWN_MAX = 3
local FORMATION_SPAWN_DIST = 600
local FORMATION_SPAWN_MIN_MS = 5500

-- Time that has to elapse after the last base is killed, before the level ends.
local LEVEL_CLEARED_AFTER_MS = 2000

LevelManager = {}
LevelManager.__index = LevelManager

function LevelManager.new(levelGenerator)
    local self = setmetatable({}, LevelManager)

    self.levelGenerator = levelGenerator

    self.level = 1
    self.basesToKill = 0
    self.enemyBaseMultiShot = 0
    self.enemyBaseFireMs = 0
    self.enemyBaseZapMs = 0
    self.formationLeaders = {}

    self.spawn = {}
    self.spawn[Asteroid] = self.simpleSpawn
    self.spawn[Egg] = self.simpleSpawn
    self.spawn[Mine] = self.simpleSpawn
    self.spawn[Enemy] = self.simpleSpawn
    self.spawn[EnemyBase] = self.enemyBaseSpawn

    return self
end

function LevelManager:addToLevel(x, y, obj, poolObj)
    local spawner = self.spawn[obj]
    assert(spawner, 'Level spawner is nil?')
    spawner(self, x, y, poolObj)
end

function LevelManager:simpleSpawn(worldX, worldY, obj)
    obj:spawn(worldX, worldY, self.level)
end

function LevelManager:enemyBaseSpawn(worldX, worldY, obj)
    obj:spawn(worldX, worldY, self.enemyBaseMultiShot, self.enemyBaseFireMs, self.enemyBaseShieldActive,
        self.enemyBaseZapMs)

    self.basesToKill += 1
end

function LevelManager:clockReset()
    -- Reset the clock!
    local now = pd.getCurrentTimeMilliseconds()
    self.lastBaseKillMS = now
    self.lastFormationActiveMS = now
    self.lastEnemySpawnMS = now
    self.levelClearedMs = nil
end

function LevelManager:reset()
    PoolManager:reset()

    self.level = 1 -- ad astra!
    self.basesToKill = 0

    self:clockReset()
    self:generateLevelAndMinimap()
end

function LevelManager:getLevel()
    return self.level
end

function LevelManager:nextLevel()
    PoolManager:reset()

    self.level += 1
    self.basesToKill = 0

    self:clockReset()
    self:generateLevelAndMinimap()
end

function LevelManager:setAggressionValues()
    -- How much time between base kills for an alert
    self.baseKillSecs = lume.clamp(ENEMYBASEKILL_SECS_MAX - (ENEMYBASEKILL_SECOND_LEVEL_DEC * (self.level - 1)),
        ENEMYBASEKILL_SECS_MIN, ENEMYBASEKILL_SECS_MAX)

    -- Enemy bases get more and more aggressive per level
    self.enemyBaseMultiShot = lume.clamp(self.level // ENEMYBASE_SHOTS_LEVEL_RATIO, ENEMYBASE_SHOTS_MIN,
        ENEMYBASE_SHOTS_MAX)
    self.enemyBaseFireMs = lume.clamp(ENEMYBASE_FIREMS_MAX - ((self.level - 1) * ENEMYBASE_FIREMS_LEVEL_REDUCTION),
        ENEMYBASE_FIREMS_MIN, ENEMYBASE_FIREMS_MAX)

    self.enemyBaseShieldActive = self.level >= ENEMYBASE_FIRST_SHIELD_LEVEL
    if self.level < ENEMYBASE_FIRST_ZAP_LEVEL then
        self.enemyBaseZapMs = 0;
    else
        self.enemyBaseZapMs = lume.clamp(
            ENEMYBASE_ZAPMS_MAX - ((self.level - ENEMYBASE_FIRST_ZAP_LEVEL) * ENEMYBASE_ZAPMS_LEVEL_REDUCTION),
            ENEMYBASE_ZAPMS_MIN, ENEMYBASE_ZAPMS_MAX)
    end

    -- Maximum formations
    self.formationsMax = lume.clamp(math.floor(FORMATION_SPAWN_MIN + (self.level * FORMATION_SPAWN_PER_LEVEL)),
        FORMATION_SPAWN_MIN, FORMATION_SPAWN_MAX)

    -- Maximum on-screen enemies
    self.enemiesVisibleMax = lume.clamp(math.floor(ENEMY_VISIBLE_MIN + (self.level * ENEMY_VISIBLE_PER_LEVEL)),
        ENEMY_VISIBLE_MIN, ENEMY_VISIBLE_MAX)
end

function LevelManager:generateLevelAndMinimap()
    -- Set how aggressive various settings are based on level
    self:setAggressionValues()

    self.levelGenerator:generate(self)
end

----------------------------------------
-- Single enemy spawn management
----------------------------------------
function LevelManager:spawnSingleEnemy()
    -- Find an enemy to spawn
    local enemy = PoolManager:freeInPool(Enemy, 1)
    if enemy then
        -- Spawn behind player, and offscreen
        local angle = Player:getAngle()
        local rearAngle = (angle + 180) % 360
        local dx, dy = AngleToDeltaXY(rearAngle)
        local px, py = Player:getWorldV():unpack()

        enemy:spawn(px - (dx * ENEMY_PLAYER_SPAWN_DISTANCE), py - (dy * ENEMY_PLAYER_SPAWN_DISTANCE))
        enemy:setAngle(angle)

        self.lastEnemySpawnMS = pd.getCurrentTimeMilliseconds()
    end
end

----------------------------------------
-- Formation management
----------------------------------------
function LevelManager:getFormationLeaders()
    return self.formationLeaders
end

function LevelManager:formationLeaderAt(leader, worldV)
    LevelManager.activeEnemyFormations += 1

    self.formationLeaders[leader] = worldV
    self.lastFormationActiveMS = pd.getCurrentTimeMilliseconds()
end

function LevelManager:formationLeaderDied(leader)
    self.formationLeaders[leader] = nil
end

function LevelManager:spawnFormation()
    -- Spawn far enough away from the player, but pointing towards them.
    local playerV = Player:getWorldV()
    local x, y = AngleToDeltaXY(math.random(360))
    x = playerV.dx + (x * FORMATION_SPAWN_DIST)
    y = playerV.dy + (y * FORMATION_SPAWN_DIST)

    local angle = PointsAngle(x, y, playerV.x, playerV.y)

    -- Formations don't collide outside viewport, so we don't care if we spawn overlapping stuff
    self:spawnFormationAt(x, y, angle, EnemyBrainFlyFormation)

    self.lastFormationSpawnMS = pd.getCurrentTimeMilliseconds()
    self.lastFormationActiveMS = pd.getCurrentTimeMilliseconds()
end

function LevelManager:spawnFormationAt(worldX, worldY, angle)
    -- Pick a formation
    local formation = lume.randomchoice(Formations)

    -- Find enough enemies to spawn into formation
    local enemies = PoolManager:freeInPool(Enemy, 1 + #formation)

    -- First enemy is the leader and is assumed to be at 0, 0 in the formation
    local leader = table.remove(enemies)
    leader:makeFormationLeader(enemies)
    leader:spawn(worldX, worldY)
    leader:setAngle(angle)

    for i = 1, #enemies do
        enemies[i]:makeFormationWingman(leader, formation, i)
        enemies[i]:spawn(worldX + formation[i].x, worldY + formation[i].y)
    end
end

function LevelManager:spawnMonster()
    -- Spawn far enough away from the player, but pointing towards them.
    local playerV = Player:getWorldV()
    local x, y = AngleToDeltaXY(math.random(360))
    x = playerV.dx + (x * FORMATION_SPAWN_DIST)
    y = playerV.dy + (y * FORMATION_SPAWN_DIST)
    local angle = PointsAngle(x, y, playerV.x, playerV.y)
    local monster = PoolManager:freeInPool(EnemyMonster)
    if monster ~= nil then
        monster:spawn(x, y)
        monster:setAngle(angle)
    end
end

function LevelManager:levelStart()
    self:clockReset()
    self.levelStartMS = pd.getCurrentTimeMilliseconds()
end

function LevelManager:baseDestroyed()
    self.basesToKill -= 1
    assert(self.basesToKill >= 0)

    local now = pd.getCurrentTimeMilliseconds()
    self.lastBaseKillMS = now

    if self.basesToKill == 0 then
        self.levelClearedMs = pd.getCurrentTimeMilliseconds()
    else
        self.levelClearedMs = nil
    end
end

function LevelManager:isLevelClear()
    if self.basesToKill == 0 then
        local now = pd.getCurrentTimeMilliseconds()
        if self.levelClearedMs then
            if now - self.levelClearedMs > LEVEL_CLEARED_AFTER_MS then
                return true
            end
        else
            self.levelClearedMs = now
        end
    end

    return false
end

function LevelManager:percentAlertTimeLeft()
    if Player:alive() and self.lastBaseKillMS then
        local lastKillSecs = (pd.getCurrentTimeMilliseconds() - self.lastBaseKillMS) / 1000
        return 1.0 - (lastKillSecs / self.baseKillSecs)
    else
        return 1.0
    end
end

function LevelManager:update()
    local now = pd.getCurrentTimeMilliseconds()

    -- Check if we need to challenge the player with pressure by spawning individual enemies.
    if now - self.lastEnemySpawnMS > ENEMY_SPAWN_MIN_MS then
        if LevelManager.activeVisibleEnemy < self.enemiesVisibleMax and LevelManager.activeEnemyFormations < self.formationsMax then
            self:spawnSingleEnemy()
        end
    end

    -- Check if we need to challenge the player with time pressure by spawning formations.
    if self:percentAlertTimeLeft() < 0.005 then
        local formationActiveMS = now - self.lastFormationActiveMS
        if LevelManager.activeEnemyFormations < self.formationsMax and formationActiveMS > FORMATION_SPAWN_MIN_MS then
            self:spawnFormation()
        end
    end

    -- Check if we need to unleash a monster if the player is beyond board edges
    local playerWorldX, playerWorldY = Player:getWorldV():unpack()
    if (playerWorldX <= 0 or playerWorldX >= WORLD_WIDTH or playerWorldY <= 0 or playerWorldY >= WORLD_HEIGHT) then
        if PoolManager:freeInPool(EnemyMonster) ~= nil then
            self:spawnMonster()
        end
    end
end

function LevelManager.resetActiveCounts()
    LevelManager.activeVisibleEnemy = 0
    LevelManager.activeEnemyFormations = 0
end
