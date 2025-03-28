local pd = playdate
local gfx = pd.graphics

local medal1Img = Assets.getImage('images/medal1.png')
local medal5Img = Assets.getImage('images/medal5.png')
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
            { name = "AAA", score = 1000, level = 6 },
            { name = "BBB", score = 800,  level = 5 },
            { name = "CCC", score = 600,  level = 4 },
            { name = "DDD", score = 500,  level = 3 },
            { name = "STU", score = 300,  level = 2 },
            { name = "NIC", score = 150,  level = 1 } }

        pd.datastore.write(self.highScores, HIGHSCORE_TABLEFILE)
    end

    return self
end

function HighScoreManager:draw(startX, startY)
    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    gfx.drawText("HIGH SCORES", startX, startY)

    local x = startX
    local y = startY + 30

    for i, high in ipairs(self.highScores) do
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(high.name, x, y)

        -- Medals
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        local medal1 = high.level % 5
        local medal5 = math.floor(high.level / 5)
        x = startX + 70
        -- TODO: Higher values
        -- Medals 5
        for i = 1, medal5 do
            medal5Img:draw(x, y)
            x += 8
        end
        -- Medals 1
        for i = 1, medal1 do
            medal1Img:draw(x, y)
            x += 8
        end

        x = startX + 115
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(high.score, x, y)

        -- Next line
        y += 20
        x = startX
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function HighScoreManager:isHighScore(score)
    local lowest = self.highScores[#self.highScores]

    return score > lowest.score
end

function HighScoreManager:insert(score, level)
    for i = 1, #self.highScores do
        if self.highScores[i].score < score then
            table.insert(self.highScores, i, { name = '', score = score, level = level })
            table.remove(self.highScores)

            return i
        end
    end

    return nil
end

function HighScoreManager:update(i, name)
    self.highScores[i].name = name
end

function HighScoreManager:save()
    pd.datastore.write(self.highScores, HIGHSCORE_TABLEFILE)
end
