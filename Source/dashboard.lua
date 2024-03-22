local gfx = playdate.graphics
local pd = playdate

Dashboard = {}
Dashboard.__index = Dashboard

local dashImg, err = gfx.image.new("images/dashboard.png")
assert(dashImg, err)

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    -- self.font = gfx.font.new("images/dpaint_8-table-8-8.png")        -- From https://github.com/BleuLlama/Playdate-Stuff
    self.font = gfx.font.new("images/Nontendo-Bold-2x-table-20-26.png") -- From play.date SDK resources
    assert(self.font, 'Font failed to load')
    gfx.setFont(self.font)

    return self
end

function Dashboard:draw()
    dashImg:draw(400 - 80, 0)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(400 - 80, 0, 400, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText('' .. Player.score, 400 - 78, 3)
    pd.drawFPS(400 - 16, 3)
end