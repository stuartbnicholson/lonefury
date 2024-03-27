-- The game dashboard. Shows the player's score, lives, minimap, condition etc.
import 'lume'

local gfx = playdate.graphics
local pd = playdate

Dashboard = {}
Dashboard.__index = Dashboard

DASH_WIDTH = 80
DASH_HEIGHT = 240

MINIMAP_SX = 325
MINIMAP_SY = 122
MINIMAP_WIDTH = 72
MINIMAP_HEIGHT = 72
MINIMAP_CELLW = 8
MINIMAP_CELLH = 6

MINIPLAYER_WIDTH = 7
MINIPLAYER_HEIGHT = 6

local dashImg, mapBaseImg, mapPlayerTable, playerLifeImg, medal1Img, medal5Img, err
dashImg, err = gfx.image.new('images/dashboard.png')

-- Lives and medals
assert(dashImg, err)
playerLifeImg, err = gfx.image.new('images/playerLife.png')
assert(playerLifeImg, err)
medal1Img, err = gfx.image.new('images/medal1.png')
assert(medal1Img, err)
medal5Img, err = gfx.image.new('images/medal5.png')
assert(medal5Img, err)

-- Minimap
mapBaseImg, err = gfx.image.new('images/mapBase.png')
assert(mapBaseImg, err)
local mapPlayerTable, err = gfx.imagetable.new("images/mapPlayer-table-7-6.png")
assert(mapPlayerTable, err)

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    self.dash = dashImg
    self.miniMap = gfx.image.new(MINIMAP_WIDTH, MINIMAP_HEIGHT)

    -- Initial dashboard draw
    self:drawPlayerScore()
    self:drawLivesMedals()

    return self
end

function Dashboard:update()
    self.dash:draw(VIEWPORT_WIDTH, 0)
    self.miniMap:draw(MINIMAP_SX, MINIMAP_SY)

    -- Draw the player ship roughly pointing the right way, but clipped to the mini map
    local px, py = Player:getWorldPosition()
    px /= VIEWPORT_WIDTH
    px = (lume.clamp(px, 0, MINIMAP_WIDTH) - 0.5) * MINIMAP_CELLW
    py /= VIEWPORT_HEIGHT
    py = (lume.clamp(py, 0, MINIMAP_HEIGHT) - 0.5) * MINIMAP_CELLH
    local pAngle = math.floor(Player.angle / 90)
    mapPlayerTable:drawImage(1 + pAngle, px + MINIMAP_SX + (MINIPLAYER_WIDTH >> 1), py + MINIMAP_SY + (MINIPLAYER_HEIGHT >> 1))

    pd.drawFPS(VIEWPORT_WIDTH + 64, 3)
end

function Dashboard:drawPlayerScore()
    gfx.pushContext(self.dash)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, DASH_WIDTH, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(Font)
    gfx.drawText('' .. Player.score, 2, 3)

    gfx.popContext()
end

function Dashboard:drawLivesMedals()
    gfx.pushContext(self.dash)

    -- Medals
    local medal1 = LevelManager.level % 5
    local medal5 = math.floor(LevelManager.level / 5)
    local x = 4
    local y = 205
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, 64, 14)
    -- Medals 1
    for i = 1, medal1 do
        medal1Img:draw(x, y)
        x += 8
    end
    -- Medals 5
    for i = 1, medal5 do
        medal5Img:draw(x, y)
        x += 8
    end
    -- TODO: Higher values

    -- Lives
    x = 4
    y = 222
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, 75, 15)
    for i = 1, lume.clamp(Player.lives, 1, 6) - 1 do
        playerLifeImg:draw(x, y)
        x += 15
    end

    gfx.popContext()
end