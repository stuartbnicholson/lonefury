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

LevelManager = {}
LevelManager.__index = LevelManager

-- TODO: We need a pool of each enemy type, so they can be re-used rather than constantly created.
-- Consider the limit of around 25-40 active sprites...
function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self.level = 1
    self.basesToKill = 0

    return self
end

function LevelManager:reset()
    PoolManager:reset()

    self.level = 1  -- ad astra!
    self:generateLevelAndMinimap()
end

function LevelManager:nextLevel()
    self.level += 1

    self:generateLevelAndMinimap()

    -- TODO: Set enemy counts and speeds
end

function LevelManager:applyLevelPart(part, worldX, worldY)
    local enemyX, enemyY, obj, poolObj
    for i = 1, #part.objs do
        enemyX = worldX + part.objs[i].x
        enemyY = worldY + part.objs[i].y

        -- Find a pool object and spawn it into the world
        obj = levelObj[part.objs[i].obj]
        poolObj = PoolManager:freeInPool(obj)
        poolObj:spawn(enemyX, enemyY, self.level)
    end
end

function LevelManager:generateLevelAndMinimap()
    -- TODO: Multiple level options?
    local lvl = levelDef.levels[tostring(self.level)]
    local row
    local cell
    local part
    local wX = 0
    local wY = 0
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
                    self:applyLevelPart(part, wX, wY)
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