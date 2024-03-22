import 'lume'

local gfx = playdate.graphics
local pd = playdate

Dashboard = {}
Dashboard.__index = Dashboard

DASH_HEIGHT = 240
DASH_WIDTH = 80

local dashImg, playerLifeImg, medal1, medal5, err
dashImg, err = gfx.image.new('images/dashboard.png')
assert(dashImg, err)
playerLifeImg, err = gfx.image.new('images/playerLife.png')
assert(playerLifeImg, err)
medal1Img, err = gfx.image.new('images/medal1.png')
assert(medal1Img, err)
medal5Img, err = gfx.image.new('images/medal5.png')
assert(medal5Img, err)

function Dashboard.new()
    local self = setmetatable({}, Dashboard)
    
    self.img = dashImg

    -- Initial dashboard draw
    self:drawPlayerScore()
    self:drawLivesMedals()

    return self
end

function Dashboard:update()
    self.img:draw(WORLD_WIDTH, 0)

    pd.drawFPS(WORLD_WIDTH + 64, 3)
end

function Dashboard:drawPlayerScore()
    gfx.pushContext(self.img)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, DASH_WIDTH, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(Font)
    gfx.drawText('' .. Player.score, 2, 3)

    gfx.popContext()
end

function Dashboard:drawLivesMedals()
    gfx.pushContext(self.img)

    -- Medals
    local medal1 = StateGame.level % 5
    local medal5 = math.floor(StateGame.level / 5)
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
    for i = 1, lume.clamp(Player.livesLeft, 0, 5) do
        playerLifeImg:draw(x, y)
        x += 15
    end

    gfx.popContext()
end