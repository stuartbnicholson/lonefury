import 'constants'
import 'asteroid'
import 'enemy'
import 'enemyBase'

-- Generates levels! Sets up the minimap, sets enemy limits, bullet speeds etc.
-- Levels are largely laid out using JSON definitions of repeatable map areas.
-- Each area is assumed to be viewport size = 320 x 240
LevelManager = {}
LevelManager.__index = LevelManager

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

-- Object pooling
-- TODO: That is a lot of asteroids
ASTEROID_POOL_SIZE = 80
ENEMY_POOL_SIZE = 20
ENEMYBASE_POOL_SIZE = 16

local levelObjPoolSize = {}
levelObjPoolSize[Asteroid] = ASTEROID_POOL_SIZE
levelObjPoolSize[Enemy] = ENEMY_POOL_SIZE
levelObjPoolSize[EnemyBase] = ENEMYBASE_POOL_SIZE

-- TODO: We need a pool of each enemy type, so they can be re-used rather than constantly created.
-- Consider the limit of around 25-40 active sprites...
function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self.level = 1
    self.basesToKill = 0

    -- Objects are pooled by type
    self.objPools = {}

    return self
end

-- Fill an object pool with new objects if req'd
function LevelManager:fillPool(obj, size)
        local pool = {}
        for i = 1, size do
            pool[i] = obj.new()
        end

        self.objPools[obj] = pool
end

-- Take all pooled objects OUT of the world, placing them back into the pool
function LevelManager:refillPool(obj)
    local pool = self.objPools[obj]
    local obj
    for i = 1, #pool do
        obj = pool[i]
        if obj.isSpawned then
            obj:despawn()
        end
    end
end

function LevelManager:freeInPool(obj)
    local pool = self.objPools[obj]
    for i = 1, #pool do
        -- We treat non-visible sprites as 'free'.
        -- TODO: Will this be a problem for blinkers?
        if not pool[i].isSpawned then
            return pool[i]
        end
    end

    -- TODO: Expand the pool?
    assert('Pool limit reached: ' .. #pool)
end

function LevelManager:reset()
    self.level = 1  -- ad astra!

    -- TODO: Memory management monitoring: https://devforum.play.date/t/tracking-memory-usage-throughout-your-game/1132

    -- Create or re-fill pools
    for obj, count in pairs(levelObjPoolSize) do
        if not self.objPools[obj] then
            self:fillPool(obj, count)
        else
            self:refillPool(obj)
        end
    end

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
        poolObj = self:freeInPool(obj)
        poolObj:spawn(enemyX, enemyY)
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
end