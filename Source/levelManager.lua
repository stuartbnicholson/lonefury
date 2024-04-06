import 'lume'

import 'constants'
import 'asteroid'
import 'enemy'
import 'enemyBase'
import 'enemyAI'

-- Generates levels! Sets up the minimap, sets enemy limits, bullet speeds etc.
-- Spawns amusing things like enemy formations.
-- Levels are largely laid out using JSON definitions of repeatable map areas.
-- Each area is assumed to be viewport size = 320 x 240
local pd = playdate

-- Load JSON level part definitions
-- TODO: Asset manager...!?
local levelFile, err = pd.file.open('assets/levelParts.json')
assert(levelFile, error)
local levelDef = json.decodeFile(levelFile)
levelFile:close()

-- Maps levelParts to game objects
local levelObj = {}
levelObj['a'] = Asteroid
levelObj['b'] = EnemyBase
levelObj['e'] = Enemy

-- On this level, ALL obstacles automatically appear, instead of randomly being left out.
local ALL_OBSTACLES_LEVEL = 6
-- Every two levels, enemy bases have an extra shot
local ENEMYBASE_SHOTS_LEVEL_RATIO <const> = 2
local ENEMYBASE_SHOTS_MIN <const> = 1
local ENEMYBASE_SHOTS_MAX <const> = 6
local ENEMYBASE_FIREMS_MAX <const> = 1000
local ENEMYBASE_FIREMS_MIN <const> = 200
local ENEMYBASE_FIREMS_LEVEL_REDUCTION <const> = 100

-- Time that has to elapse after the last base is killed, before the level ends.
local LEVEL_CLEARED_AFTER_MS = 2000

LevelManager = {}
LevelManager.__index = LevelManager

-- TODO: We need a pool of each enemy type, so they can be re-used rather than constantly created.
-- Consider the limit of around 25-40 active sprites...
function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self.level = 1
    self.basesToKill = 0

    self.spawn = {}
    self.spawn[Asteroid] = self.asteroidSpawn
    self.spawn[Enemy] = self.simpleSpawn
    self.spawn[EnemyBase] = self.enemyBaseSpawn

    return self
end

function LevelManager:simpleSpawn(worldX, worldY, obj)
    obj:spawn(worldX, worldY, self.level)
end

function LevelManager:asteroidSpawn(worldX, worldY, obj)
    if self.obstacleChance < 1 then
        if math.random() < self.obstacleChance then
            obj:spawn(worldX, worldY, self.level)
        end
    else
        -- Spawn regardless, level is too high - player is just too good!
        obj:spawn(worldX, worldY, self.level)
    end
end

function LevelManager:enemyBaseSpawn(worldX, worldY, obj)
    obj:spawn(worldX, worldY, self.enemyBaseMultiShot, self.enemyBaseFireMs)

    self.basesToKill += 1
end

function LevelManager:reset()
    PoolManager:reset()

    self.level = 1  -- ad astra!
    self.basesToKill = 0

    self:generateLevelAndMinimap()
end

function LevelManager:nextLevel()
    PoolManager:reset()

    self.level += 1
    self.basesToKill = 0

    self:generateLevelAndMinimap()

    -- TODO: Set enemy counts and speeds
end

function LevelManager:applyLevelPart(part, worldX, worldY, obstacleChance)
    local enemyX, enemyY, obj, poolObj
    for i = 1, #part.objs do
        enemyX = worldX + part.objs[i].x
        enemyY = worldY + part.objs[i].y

        -- Find a pool object and (possibly) spawn it into the world
        obj = levelObj[part.objs[i].obj]
        poolObj = PoolManager:freeInPool(obj)
        self.spawn[obj](self, enemyX, enemyY, poolObj)
    end
end

function LevelManager:setAggressionValues()
    -- For lower levels, less obstacles will appear. After the Xth level, all asteroid and mine obstacles are present
    self.obstacleChance = self.level / ALL_OBSTACLES_LEVEL
    -- Enemy bases get more and more aggressive per level
    self.enemyBaseMultiShot = lume.clamp(self.level // ENEMYBASE_SHOTS_LEVEL_RATIO, ENEMYBASE_SHOTS_MIN, ENEMYBASE_SHOTS_MAX)
    self.enemyBaseFireMs = lume.clamp(ENEMYBASE_FIREMS_MAX - ((self.level - 1) * ENEMYBASE_FIREMS_LEVEL_REDUCTION), ENEMYBASE_FIREMS_MIN, ENEMYBASE_FIREMS_MAX)

    print('Enemy Base Aggression: ', self.enemyBaseMultiShot, self.enemyBaseFireMs)
end

function LevelManager:generateLevelAndMinimap()
    local row
    local cell
    local part
    local wX = 0
    local wY = 0

    -- Set how aggressive various settings are based on level
    self:setAggressionValues()

    -- Pick one of several level definitions for this level
    -- TODO: What happens when we run out of levels?
    local lvls = levelDef.levels[tostring(self.level)]
    local lvl = lume.randomchoice(lvls)

    if lvl then
        for y = 1, #lvl.map do
            wX = 0
            row = lvl.map[y]
            for x = 1, 9 do
                -- TODO: Wonder how inefficient this is?
                cell = string.sub(row,x,x)
                if cell ~= "-" then
                    part = levelDef.parts[cell]
                    assert(part, "Unknown part: " .. cell)
                    self:applyLevelPart(part, wX, wY, obstacleChance)
                end

                wX += VIEWPORT_WIDTH
            end

            wY += VIEWPORT_HEIGHT
        end
    else
        assert("no level " .. self.level .. "?")
    end

    -- TODO: Throw in a sample formation
    self:spawnFormation(1000, 1000)
end

function LevelManager:spawnFormation(worldX, worldY)
    -- Pick a formation
    local formation = lume.randomchoice(Formations)

    -- Find enough enemies to spawn into formation
    local enemies = PoolManager:freeInPool(Enemy, 1 + #formation)

    -- First enemy is the leader and is assumed to be at 0, 0 in the formation
    local leader = table.remove(enemies)
    leader:makeFormationLeader(enemies)
    leader:spawn(worldX, worldY, self.level)

    for i = 1, #enemies do
        enemies[i]:makeFormationWingman(leader, formation, i)
        enemies[i]:spawn(worldX + formation[i].x, worldY + formation[i].y, self.level)
    end
end

function LevelManager:baseDestroyed()
    self.basesToKill -= 1
    assert(self.basesToKill >= 0)

    if self.basesToKill == 0 then
        print('Start the clock!')
        self.levelClearedMs = pd.getCurrentTimeMilliseconds()
    end
end

function LevelManager:isLevelClear()
    if self.basesToKill == 0 then
        local now = pd.getCurrentTimeMilliseconds()
        if now - self.levelClearedMs > LEVEL_CLEARED_AFTER_MS then
            return true
        end
    end

    return false
end