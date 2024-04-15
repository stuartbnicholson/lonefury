-- The game dashboard. Shows the player's score, lives, minimap, condition etc.
import 'lume'
import 'assets'

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

local medal1Img = Assets.getImage('images/medal1.png')
local medal5Img = Assets.getImage('images/medal5.png')
local playerLifeImg = Assets.getImage('images/playerLife.png')
local alertImg = Assets.getImage('images/alert.png')
local mapPlayerTable = Assets.getImagetable('images/mapPlayer-table-7-6.png')
local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local scoreFont = Assets.getFont('images/Xevious-Score-table-8-16.png')

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    self.dash = Assets.getImage('images/dashboard.png')
    self.miniMap = gfx.image.new(MINIMAP_WIDTH * MINIMAP_CELLW, MINIMAP_HEIGHT * MINIMAP_CELLH)

    -- Initial dashboard draw
    self:drawPlayerScore()
    self:drawLivesMedals()

    return self
end

function Dashboard:worldToDashXY(worldX, worldY)
    local mx, my

    mx = worldX / VIEWPORT_WIDTH
    mx = (lume.clamp(mx, 0, MINIMAP_WIDTH)) * MINIMAP_CELLW

    my = worldY / VIEWPORT_HEIGHT
    my = (lume.clamp(my, 0, MINIMAP_HEIGHT)) * MINIMAP_CELLH

    return mx, my
end

function Dashboard:addEnemyBase(worldX, worldY)
    local mx, my = self:worldToDashXY(worldX, worldY)

    gfx.pushContext(self.miniMap)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(mx, my, 2, 2)
    gfx.popContext()
end

function Dashboard:removeEnemyBase(worldX, worldY)
    local mx, my = self:worldToDashXY(worldX, worldY)

    gfx.pushContext(self.miniMap)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(mx, my, 2, 2)
    gfx.popContext()
end

function Dashboard:update()
    self.dash:draw(VIEWPORT_WIDTH, 0)
    self.miniMap:draw(MINIMAP_SX, MINIMAP_SY)

    -- Alert!
    alertImg:draw(VIEWPORT_WIDTH + 2, 102)

    -- Draw the player ship roughly pointing the right way, but clipped to the mini map
    local mx, my = self:worldToDashXY(Player:getWorldV():unpack())
    local frame = 1 + (((Player.angle + 45) % 360) // 90) % 4
    mapPlayerTable:drawImage(frame, mx + MINIMAP_SX - 3, my + MINIMAP_SY  - 2)

    pd.drawFPS(VIEWPORT_WIDTH + 64, 3)
end

function Dashboard:drawPlayerScore()
    gfx.pushContext(self.dash)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, DASH_WIDTH, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(scoreFont)
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