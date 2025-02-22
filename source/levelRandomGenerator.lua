import 'constants'
import 'enemyBase'
import 'asteroid'

-- Generates random levels, based on settings provided by the LevelManager and some simple rules
-- Mostly random - bases sometimes appear in patterns based on the contents of assets/baseMaps.json
local pd = playdate
local gfx = pd.graphics

local MAP_CELL_SIZE <const> = 16
local PERCENT_BASE_MAP = 20 -- The % chance of using a fixed base map if we have one for the level

-- The number of enemy bases goes up per level with variation, and they get more radius to occupy
-- Each base also requires three sprites.
local basesPerLevel = {
    { min = 1,  max = 2,  radius = 30 }, -- L1
    { min = 2,  max = 3,  radius = 30 }, -- L2
    { min = 3,  max = 4,  radius = 40 }, -- L3
    { min = 4,  max = 5,  radius = 50 }, -- L4
    { min = 5,  max = 6,  radius = 60 }, -- L5
    { min = 6,  max = 7,  radius = 60 }, -- L6
    { min = 7,  max = 8,  radius = 60 }, -- L7
    { min = 8,  max = 10, radius = 70 }, -- L8
    { min = 10, max = 12, radius = 70 }, -- L9
    { min = 12, max = 14, radius = 70 }, -- L10
    { min = 14, max = 16, radius = 70 }  -- L11
    -- After this we just keep repeating the highest
}

-- The number of asteroids, eggs and mines per level
local obstaclesPerLevel = {
    { asteroids = 20, mines = 2,  eggs = 5,  radius = 35 },
    { asteroids = 30, mines = 5,  eggs = 5,  radius = 45 },
    { asteroids = 40, mines = 10, eggs = 5,  radius = 50 },
    { asteroids = 40, mines = 10, eggs = 10, radius = 50 },
    { asteroids = 40, mines = 20, eggs = 10, radius = 50 },
    { asteroids = 37, mines = 20, eggs = 10, radius = 50 },
    { asteroids = 34, mines = 20, eggs = 10, radius = 60 },
    { asteroids = 31, mines = 20, eggs = 10, radius = 60 },
    { asteroids = 28, mines = 20, eggs = 10, radius = 60 },
    { asteroids = 25, mines = 20, eggs = 10, radius = 60 },
    { asteroids = 22, mines = 20, eggs = 10, radius = 60 }
    -- After this we just keep repeating the highest
}

-- EnemyBase occcupied map images
local baseOccupied = Assets.getImage('images/baseOccupied.png')

LevelRandomGenerator = {}
LevelRandomGenerator.__index = LevelRandomGenerator

function LevelRandomGenerator.new()
    local self = setmetatable({}, LevelRandomGenerator)

    -- How many discrete cells in the level that can be occupied by sprites`
    self.cellsWidth = WORLD_WIDTH / MAP_CELL_SIZE
    self.cellsHeight = WORLD_HEIGHT / MAP_CELL_SIZE

    local occupiedMap, err = gfx.image.new(self.cellsWidth, self.cellsHeight, gfx.kColorClear)
    assert(occupiedMap, err)
    self.occupiedMap = occupiedMap

    -- Load JSON base map definitions
    local baseMapsFile, err = pd.file.open('assets/baseMaps.json')
    assert(baseMapsFile, error)
    self.baseMaps = json.decodeFile(baseMapsFile)
    baseMapsFile:close()

    return self
end

function LevelRandomGenerator:spawnLevels(level)
    -- How good is this player that they're hitting the cap :)
    if level > #basesPerLevel then
        level = #basesPerLevel
    end

    -- Determine the number of bases in range
    local bases = basesPerLevel[level]
    local numBases = math.random(bases.min, bases.max)
    print("numBases: ", numBases)

    -- Determine the number of asteroids, mines and eggs
    local obstacles = obstaclesPerLevel[level]

    return numBases, bases.radius, obstacles.asteroids, obstacles.mines, obstacles.eggs, obstacles.radius
end

function LevelRandomGenerator:spawn(levelManager, obj, cellX, cellY)
    local poolObj = PoolManager:freeInPool(obj)
    if poolObj then
        local worldX = (cellX * MAP_CELL_SIZE) + 8 -- Sprites are centered
        local worldY = (cellY * MAP_CELL_SIZE) + 8
        levelManager:addToLevel(worldX, worldY, obj, poolObj)
    else
        assert(nil, "Level Generate nil poolObj?")
    end
end

function LevelRandomGenerator:scatterObstacles(levelManager, obj, numObstacles, radius)
    for i = 1, numObstacles, 1 do
        local cellX, cellY = LevelRandomGenerator.randomPointInCircle(radius, 90, 90)
        if (self.occupiedMap:sample(cellX, cellY) == gfx.kColorClear) then
            gfx.drawPixel(cellX, cellY)
            self:spawn(levelManager, obj, cellX, cellY)
        else
            -- We don't really care if we lose a few asteroids
        end
    end
end

function LevelRandomGenerator:findBaseMap(level, numBases)
    local maps = {}

    for _, baseMap in ipairs(self.baseMaps) do
        if baseMap.numBases >= numBases and baseMap.minLevel <= level then
            table.insert(maps, baseMap)
        end
    end

    if #maps > 0 then
        return lume.randomchoice(maps)
    else
        return nil
    end
end

function LevelRandomGenerator:placeBases(levelManager, baseMap)
    -- Place bases based on a map, rather than scattering them randomly
    for _, base in ipairs(baseMap.bases) do
        local cellX = (base.x - 36) / MAP_CELL_SIZE
        local cellY = (base.y - 36) / MAP_CELL_SIZE
        baseOccupied:draw(cellX, cellY)
        self:spawn(levelManager, EnemyBase, cellX + 2, cellY + 2) -- Sprites are centered
    end
end

function LevelRandomGenerator:scatterBases(levelManager, numBases, baseRadius)
    -- PERCENT_BASE_MAP of the time use a pre-defined baseMap layout, if we can find one
    if math.random(100) < PERCENT_BASE_MAP then
        local baseMap = self:findBaseMap(levelManager:getLevel(), numBases)

        if baseMap then
            self:placeBases(levelManager, baseMap)
            return
        end
    end

    -- TODO: Did consider some light trig to keep them separated, but I enjoy the fact they can overlap closely?
    -- It might actually be more fun to randomly add fixed patterns of base levels...
    for i = 1, numBases, 1 do
        for j = 1, 3, 1 do
            local cellX, cellY = LevelRandomGenerator.randomPointInCircle(baseRadius, 90, 90)
            if not gfx.checkAlphaCollision(self.occupiedMap, 0, 0, gfx.kImageUnflipped, baseOccupied, cellX, cellY, gfx.kImageUnflipped) then
                baseOccupied:draw(cellX, cellY)
                self:spawn(levelManager, EnemyBase, cellX + 2, cellY + 2) -- Sprites are centered
                break
            end
        end
    end
end

function LevelRandomGenerator:generate(levelManager)
    -- We're drawing on the occupiedMap as we spawn level objects
    self.occupiedMap:clear(gfx.kColorClear)
    gfx.pushContext(self.occupiedMap)
    gfx.setColor(gfx.kColorWhite)

    -- Determine the number of bases, asteroids, mines and eggs to spawn
    local numBases, baseRadius, numAsteroids, numMines, numEggs, obstacleRadius = self:spawnLevels(levelManager:getLevel())

    -- Fill the centre of the map with a player spawn circle
    local cellsWidthHalf = self.cellsWidth / 2
    local cellsHeightHalf = self.cellsHeight / 2
    gfx.fillCircleInRect(cellsWidthHalf - 4, cellsHeightHalf - 4, 8, 8)

    -- Scatter bases around first because they're the largest, most interesting enemy
    self:scatterBases(levelManager, numBases, baseRadius)

    -- Scatter some asteroids around
    self:scatterObstacles(levelManager, Asteroid, numAsteroids, obstacleRadius)

    -- TODO: Scatter some mines around
    self:scatterObstacles(levelManager, Mine, numMines, obstacleRadius)

    -- Scatter some eggs around
    self:scatterObstacles(levelManager, Egg, numEggs, obstacleRadius)

    gfx.popContext()
end

function LevelRandomGenerator.randomPointInCircle(radius, centreX, centreY)
    local x, y
    local radiusSqrd = radius * radius
    -- Generate random x and y in the range [-R, R] without using sqrt
    -- Using https://en.wikipedia.org/wiki/Rejection_sampling
    repeat
        x = (math.random() * 2 - 1) * radius
        y = (math.random() * 2 - 1) * radius
    until x * x + y * y <= radiusSqrd

    return centreX + x, centreY + y
end
