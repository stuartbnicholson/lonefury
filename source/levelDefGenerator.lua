import 'lume'

import 'constants'

-- Generates levels, based on settings provided by the LevelManager and JSON definitions
local pd = playdate

-- Load JSON level part definitions
local levelFile, err = pd.file.open('assets/levelParts.json')
assert(levelFile, error)
local levelDef = json.decodeFile(levelFile)
levelFile:close()

-- Maps levelParts to game objects
local levelObj = {}
levelObj['a'] = Asteroid
levelObj['g'] = Egg
levelObj['b'] = EnemyBase
levelObj['e'] = Enemy

LevelDefGenerator = {}
LevelDefGenerator.__index = LevelDefGenerator

function LevelDefGenerator.new()
    local self = setmetatable({}, LevelDefGenerator)

    return self
end

function LevelDefGenerator:applyLevelPart(levelManager, part, worldX, worldY)
    local enemyX, enemyY, obj, poolObj
    for i = 1, #part.objs do
        enemyX = worldX + part.objs[i].x
        enemyY = worldY + part.objs[i].y

        -- Find a pool object and (possibly) spawn it into the world
        obj = levelObj[part.objs[i].obj]
        poolObj = PoolManager:freeInPool(obj)
        if (poolObj) then
            levelManager:addToLevel(enemyX, enemyY, obj, poolObj)
        end
    end
end

function LevelDefGenerator:generate(levelManager)
    local row
    local cell
    local part
    local wX = 0
    local wY = 0

    -- Pick one of several level definitions for this level
    -- TODO: What happens when we run out of levels?
    local lvls = levelDef.levels[tostring(levelManager:getLevel())]
    local lvl = lume.randomchoice(lvls)

    if lvl then
        for y = 1, #lvl.map do
            wX = 0
            row = lvl.map[y]
            for x = 1, 9 do
                -- TODO: Wonder how inefficient this is?
                cell = string.sub(row, x, x)
                if cell ~= "-" then
                    part = levelDef.parts[cell]
                    assert(part, "Unknown part: " .. cell)
                    self:applyLevelPart(levelManager, part, wX, wY)
                end

                wX += VIEWPORT_WIDTH
            end

            wY += VIEWPORT_HEIGHT
        end
    else
        assert("no level " .. self.level .. "?")
    end
end
