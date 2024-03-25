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
local levelJson = json.decodeFile(levelFile)
levelFile:close()

-- TODO: We need a pool of each enemy type, so they can be re-used rather than constantly created.
-- Consider the limit of around 25 sprites...

local enemyNew = {}
enemyNew[SPRITE_TAGS.asteroid] = Asteroid.new
enemyNew[SPRITE_TAGS.enemy] = Enemy.new
enemyNew[SPRITE_TAGS.enemyBase] = EnemyBase.new

-- Generate some placeholder enemies
-- TODO: This is effectively 'level generation' :)
Enemies = {}

function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self.level = 1

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
        Enemies[#Enemies + i] = enemyNew[part.objs[i].type](enemyX, enemyY)
    end
end

function LevelManager:generateLevelAndMinimap()
    print('level parts loaded: ' .. #levelJson.parts)

    -- TODO: Initially just set up a test 'level' part around the player
    local part = lume.randomchoice(levelJson.parts)
    self:applyLevelPart(part, WORLD_PLAYER_STARTX, WORLD_PLAYER_STARTY)
end