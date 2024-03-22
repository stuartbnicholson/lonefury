local gfx = playdate.graphics
local pd = playdate

Dashboard = {}
Dashboard.__index = Dashboard

local dashImg, err = gfx.image.new("images/dashboard.png")
assert(dashImg, err)

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    return self
end

function Dashboard:draw()
    dashImg:draw(400 - 80, 0)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(400 - 80, 0, 400, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(Font)
    gfx.drawText('' .. Player.score, 400 - 78, 3)
    pd.drawFPS(400 - 16, 3)
end