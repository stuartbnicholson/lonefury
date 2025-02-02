import 'constants'
import 'enemyBase'
import 'asteroid'

-- Generates random levels, based on settings provided by the LevelManager and some simple rules
local pd = playdate
local gfx = pd.graphics

local MAP_CELL_SIZE <const> = 16

-- The number of enemy bases goes up per level with variation, and they get more radius to occupy
local basesPerLevel = {
    { min = 1, max = 2,  radius = 30 },
    { min = 2, max = 3,  radius = 30 },
    { min = 3, max = 4,  radius = 40 },
    { min = 4, max = 5,  radius = 50 },
    { min = 5, max = 6,  radius = 60 },
    { min = 6, max = 7,  radius = 60 },
    { min = 7, max = 8,  radius = 70 },
    { min = 8, max = 10, radius = 70 }
    -- After this we just keep repeating the highest
}

-- The number of asteroids, eggs and mines per level
local obstaclesPerLevel = {
    { asteroids = 20, mines = 2,  eggs = 5,  radius = 35 },
    { asteroids = 30, mines = 5,  eggs = 5,  radius = 45 },
    { asteroids = 40, mines = 10, eggs = 5,  radius = 55 },
    { asteroids = 50, mines = 10, eggs = 10, radius = 60 },
    { asteroids = 50, mines = 20, eggs = 10, radius = 60 },
    { asteroids = 40, mines = 30, eggs = 10, radius = 60 },
    { asteroids = 40, mines = 30, eggs = 10, radius = 60 },
    { asteroids = 40, mines = 30, eggs = 10, radius = 60 }
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

    -- Scatter bases around first
    -- TODO: Did consider some light trig to keep them separated, but I enjoy the fact they can overlap closely.
    -- It might actually be more fun to randomly add fixed patterns of base levels...
    local poolObj
    local enemyX, enemyY
    for i = 1, numBases, 1 do
        for j = 1, 3, 1 do
            local cellX, cellY = LevelRandomGenerator.randomPointInCircle(baseRadius, 90, 90)
            if not gfx.checkAlphaCollision(self.occupiedMap, 0, 0, gfx.kImageUnflipped, baseOccupied, cellX, cellY, gfx.kImageUnflipped) then
                baseOccupied:draw(cellX, cellY)
                self:spawn(levelManager, EnemyBase, cellX + 2, cellY + 2) -- Sprites are centered
                break
            else
                -- We really DO care if we can't place all the bases
                print('Level generator base collision!')
            end
        end
    end

    -- Scatter some asteroids around
    self:scatterObstacles(levelManager, Asteroid, numAsteroids, obstacleRadius)

    -- TODO: Scatter some mines around
    self:scatterObstacles(levelManager, Mine, numMines, obstacleRadius)

    -- Scatter some eggs around
    self:scatterObstacles(levelManager, Egg, numEggs, obstacleRadius)

    gfx.popContext()
end

function LevelRandomGenerator.randomPointInCircle(circleRadius, centreX, centreY)
    local angle = math.random() * 2 * math.pi
    local radius = math.sqrt(math.random()) * circleRadius

    local x = centreX + radius * math.cos(angle)
    local y = centreY + radius * math.sin(angle)

    return x, y
end
