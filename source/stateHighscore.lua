-- State: Game highscore screen before game starts.
import 'constants'

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')

local TIMEOUT_MS = 1200 * 5

StateHighscore = {}
StateHighscore.__index = StateHighscore

function StateHighscore.new()
    local self = setmetatable({}, StateHighscore)

    return self
end

function StateHighscore:start()
    print('StateHighscore start')

    self.highScores = pd.datastore.read(HIGHSCORE_TABLEFILE)
    if self.highScores == nil then
        -- Create an initial high score table
        self.highScores = {
            { name = "AAA", score = 1600 },
            { name = "BBB", score = 1400 },
            { name = "CCC", score = 1200 },
            { name = "DDD", score = 1000 },
            { name = "STU", score = 800 },
            { name = "NIC", score = 600 } }
        pd.datastore.write(self.highScores, HIGHSCORE_TABLEFILE)
    end

    self.started = pd.getCurrentTimeMilliseconds()
end

function StateHighscore:update()
    Starfield:update()
    Dashboard:update()

    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(font)

    gfx.drawText("HIGH SCORES", 50, 30)

    local x = 50
    local y = 80
    for i, high in ipairs(self.highScores) do
        gfx.drawText(high.name, x, y)
        x += 80
        gfx.drawText(high.score, x, y)
        y += 20
        x = 50
    end
    gfx.popContext()

    -- TODO: Timing out to cycle to menu...

    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        StateStart:start()
        return StateStart
    elseif pd.getCurrentTimeMilliseconds() - self.started > TIMEOUT_MS then
        StateMenu:start()
        return StateMenu
    else
        return self
    end
end
