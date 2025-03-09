-- State: Game title screen before game starts.

local pd = playdate
local gfx = pd.graphics

local titleImg = Assets.getImage('images/title.png')
local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local smallFont = Assets.getFont('images/Xevious-table-8-8.png')

local TIMEOUT_MS = 1200 * 5

StateMenu = {}
StateMenu.__index = StateMenu

function StateMenu.new()
    local self = setmetatable({}, StateMenu)

    self.blinker = gfx.animation.blinker.new(800, 400, true)
    self.blinker:start()

    return self
end

function StateMenu:start()
    self.started = pd.getCurrentTimeMilliseconds()
    SoundManager:titleMusic(TitleMusic)
end

function StateMenu:update()
    Starfield:update()
    Dashboard:update()
    gfx.animation.blinker.updateAll()

    -- Centered in the play area
    local w, h = titleImg:getSize()
    titleImg:draw((VIEWPORT_WIDTH - w) >> 1, ((VIEWPORT_HEIGHT - h) >> 1) - 32)

    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(smallFont)
    gfx.drawText("V" .. pd.metadata.version, 285, 230)

    if self.blinker.on then
        gfx.setFont(font)
        gfx.drawText('PRESS A BUTTON', 48, 186)
    end
    gfx.popContext()

    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        StateStart:start()
        return StateStart
    elseif pd.getCurrentTimeMilliseconds() - self.started > TIMEOUT_MS then
        StateInstructions:start()
        return StateInstructions
    else
        return self
    end
end
