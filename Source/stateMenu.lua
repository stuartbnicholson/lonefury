import 'CoreLibs/animation'

local pd = playdate
local gfx = pd.graphics

local titleImg, err = gfx.image.new("images/title.png") 
assert(titleImg, err)

StateMenu = {}
StateMenu.__index = StateMenu

function StateMenu.new()
    local self = setmetatable({}, StateMenu)

    self.blinker = gfx.animation.blinker.new(800, 400, true)
    self.blinker:start()

    return self
end

function StateMenu:update()
    Starfield:draw()
    Dashboard:draw()

    titleImg:draw(50, 50)

    gfx.animation.blinker.updateAll()
    if self.blinker.on then
        gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText('PRESS ANY BUTTON', 50, 144)
        gfx.popContext()
    end

    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        return StateGame
    else
        return self
    end
end