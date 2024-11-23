import 'assets'

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')

-- Manage persistent high scores
HighScoreManager = {}
HighScoreManager.__index = HighScoreManager

function HighScoreManager.new()
    local self = setmetatable({}, HighScoreManager)

    self.highScores = pd.datastore.read(HIGHSCORE_TABLEFILE)
    if self.highScores == nil then
        -- Create an initial high score table
        self.highScores = {
            { name = "AAA", score = 1600, level = 6 },
            { name = "BBB", score = 1400, level = 5 },
            { name = "CCC", score = 1200, level = 4 },
            { name = "DDD", score = 1000, level = 3 },
            { name = "STU", score = 800,  level = 2 },
            { name = "NIC", score = 600,  level = 1 } }

        pd.datastore.write(self.highScores, HIGHSCORE_TABLEFILE)
    end

    return self
end

function HighScoreManager:draw(startX, startY)
    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(font)

    gfx.drawText("HIGH SCORES", startX, startY)

    local x = startX
    local y = startY + 30

    for i, high in ipairs(self.highScores) do
        gfx.drawText(high.name, x, y)
        x += 80
        gfx.drawText(high.score, x, y)
        y += 20

        -- TODO: Draw level medals

        x = startX
    end
    gfx.popContext()
end

function HighScoreManager:isHighScore(score)
    local lowest = self.highScores[#self.highScores]

    return score > lowest.score
end
