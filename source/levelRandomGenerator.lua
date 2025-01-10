import 'lume'

import 'constants'
import 'enemyBase'
import 'asteroid'

-- Generates random levels, based on settings provided by the LevelManager and some simple rules
local pd = playdate
local gfx = pd.graphics

local MAP_CELL_SIZE <const> = 16

-- EnemyBase occcupied map images
local baseVert = Assets.getImage('images/baseOccupiedVert.png')
local baseHoriz = Assets.getImage('images/baseOccupiedHoriz.png')

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

function LevelRandomGenerator:spawn(levelManager, obj, cellX, cellY)
    local poolObj = PoolManager:freeInPool(obj)
    if (poolObj) then
        local enemyX = cellX * MAP_CELL_SIZE
        local enemyY = cellY * MAP_CELL_SIZE
        levelManager:addToLevel(enemyX, enemyY, obj, poolObj)
    else
        print('Level Generate nil poolObj')
    end
end

function LevelRandomGenerator:generate(levelManager)
    -- We're drawing on the occupiedMap as we spawn level objects
    gfx.pushContext(self.occupiedMap)
    gfx.setColor(gfx.kColorWhite)

    -- TODO; Expand

    -- TODO: Fill the centre of the map with a player spawn circle
    local cellsWidthHalf = self.cellsWidth / 2
    local cellsHeightHalf = self.cellsHeight / 2
    gfx.fillCircleInRect(cellsWidthHalf - 4, cellsHeightHalf - 4, 8, 8)

    -- TODO: Spawn required bases first
    local poolObj
    local enemyX, enemyY
    for i = 1, 5, 1 do
        for j = 1, 3, 1 do
            local cellX, cellY = LevelRandomGenerator.randomPointInCircle(60, 90, 90)
            if not gfx.checkAlphaCollision(self.occupiedMap, 0, 0, gfx.kImageUnflipped, baseVert, cellX, cellY, gfx.kImageUnflipped) then
                baseVert:draw(cellX, cellY)
                self:spawn(levelManager, EnemyBase, cellX, cellY)
                break
            else
                -- We really DO care if we can't place all the bases
                print('Level generator base collision!')
            end
        end
    end

    -- Scatter some asteroids around, that don't overlap
    for i = 1, 60, 1 do
        local cellX, cellY = LevelRandomGenerator.randomPointInCircle(70, 90, 90)

        if (self.occupiedMap:sample(cellX, cellY) == gfx.kColorClear) then
            gfx.drawPixel(cellX, cellY)

            self:spawn(levelManager, Asteroid, cellX, cellY)
        else
            -- We don't really care if we lose a few asteroids
            print('Level generator asteroid collision!')
        end
    end

    gfx.popContext()
end

function LevelRandomGenerator.randomPointInCircle(circleRadius, centreX, centreY)
    local angle = math.random() * 2 * math.pi
    local radius = math.sqrt(math.random()) * circleRadius

    local x = centreX + radius * math.cos(angle)
    local y = centreY + radius * math.sin(angle)

    return x, y
end
