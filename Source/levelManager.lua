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
local levelFile, err = pd.file.open('assets/levelParts.json')
assert(levelFile, error)
local levelDef = json.decodeFile(levelFile)
levelFile:close()

-- TODO: We need a pool of each enemy type, so they can be re-used rather than constantly created.
-- Consider the limit of around 25 sprites...

local enemyNew = {}
enemyNew["a"] = Asteroid.new
enemyNew["e"] = Enemy.new
enemyNew["b"] = function(x, y)
    Dashboard:addEnemyBase(x, y)
    return EnemyBase.new(x, y)
end

-- Generate some placeholder enemies
-- TODO: This is effectively 'level generation' :)
Enemies = {}

function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self.level = 1
    self.basesToKill = 0

    return self
end

function LevelManager:reset()
    self.level = 1  -- ad astra!

    self:generateLevelAndMinimap()
end

function LevelManager:nextLevel()
    self.level += 1

    self:generateLevelAndMinimap()

    -- TODO: Set enemy counts and speeds
end

function LevelManager:applyLevelPart(part, worldX, worldY)
    -- Translate from centre of level part to top left
    worldX -= HALF_VIEWPORT_WIDTH
    worldY -= HALF_VIEWPORT_HEIGHT

    local enemyX, enemyY
    for i = 1, #part.objs do
        enemyX = worldX + part.objs[i].x
        enemyY = worldY + part.objs[i].y
        Enemies[#Enemies + i] = enemyNew[part.objs[i].obj](enemyX, enemyY)
    end
end

function LevelManager:generateLevelAndMinimap()
    -- TODO: Multiple level options?
    local lvl = levelDef.levels[tostring(self.level)]
    local row
    local cell
    local part
    local wX
    local wY = 0
    if lvl then
        for y = 1, #lvl.map do
            wX = 0
            row = lvl.map[y]
            for x = 1, 9 do
                wX += VIEWPORT_WIDTH
                -- TODO: Wonder how inefficient this is?
                cell = string.sub(row,x,x)
                if cell ~= "-" then
                    part = levelDef.parts[cell]
                    assert(part, "Unknown part: " .. cell)
                    self:applyLevelPart(part, wX, wY)
                end
            end

            wY += VIEWPORT_HEIGHT
        end
    else
        assert("no level " .. self.level .. "?")
    end
end