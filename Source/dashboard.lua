local gfx = playdate.graphics

Dashboard = {}
Dashboard.__index = Dashboard

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    self.font = gfx.font.new("images/dpaint_8-table-8-8.png") -- From https://github.com/BleuLlama/Playdate-Stuff
    assert(self.font, 'Font failed to load')
    gfx.setFont(self.font)

    return self
end

function Dashboard:draw()    
    gfx.setColor(playdate.graphics.kColorWhite)
    gfx.fillRect(0, 0, 40, 10)
    gfx.setColor(playdate.graphics.kColorBlack)
    gfx.drawText('' .. PlayerScore, 1, 1)

    playdate.drawFPS(0,12)
end