-- State: Game title screen before game starts.
import 'CoreLibs/animation'

local pd = playdate
local gfx = pd.graphics

local titleImg = Assets.getImage('images/title.png')
local font = Assets.getFont('images/Xevious-2x-table-16-16.png')

StateMenu = {}
StateMenu.__index = StateMenu

function StateMenu.new()
    local self = setmetatable({}, StateMenu)

    self.blinker = gfx.animation.blinker.new(800, 400, true)
    self.blinker:start()

    return self
end

function StateMenu:start()
    print('StateMenu start')
end

function StateMenu:update()
    Starfield:update()
    Dashboard:update()

    titleImg:draw(50, 50)

    gfx.animation.blinker.updateAll()
    if self.blinker.on then
        gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.setFont(font)
        gfx.drawText('PRESS A BUTTON', 48, 144)
        gfx.popContext()
    end

    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        StateStart:start()
        return StateStart
    else
        return self
    end
end