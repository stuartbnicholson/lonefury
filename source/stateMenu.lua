-- State: Game title screen before game starts.

local pd = playdate
local gfx = pd.graphics
local anim = gfx.animation

local titleImg = Assets.getImage('images/title.png')
local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local smallFont = Assets.getFont('images/Xevious-table-8-8.png')

local TIMEOUT_MS = 1200 * 5

StateMenu = {}
StateMenu.__index = StateMenu

function StateMenu.new()
    local self = setmetatable({}, StateMenu)

    self.blinker = anim.blinker.new(800, 400, true)
    self.blinker:start()

    return self
end

function StateMenu:start()
    Starfield.image:draw(0, 0)

    -- Centered in the play area
    local w, h = titleImg:getSize()
    titleImg:draw((VIEWPORT_WIDTH - w) >> 1, ((VIEWPORT_HEIGHT - h) >> 1) - 32)

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(smallFont)
    gfx.drawText("V" .. pd.metadata.version, 285, 230)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    Dashboard:update()

    self.started = pd.getCurrentTimeMilliseconds()
    SoundManager:titleMusic(TitleMusic)
end

function StateMenu:update()
    anim.blinker.updateAll()

    if self.blinker.on then
        gfx.setFont(font)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText('PRESS A BUTTON', 48, 186)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(48, 186, 238, 15)
        gfx.setColor(gfx.kColorWhite)
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

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
