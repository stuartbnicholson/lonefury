-- State: Game highscore entry screen after game finishes!
import 'constants'

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local alpha <const> = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local CrankTicksPerRev <const> = 12 -- 360/30

StateHighscoreEntry = {}
StateHighscoreEntry.__index = StateHighscoreEntry

function StateHighscoreEntry.new()
    local self = setmetatable({}, StateHighscoreEntry)

    self.blinker = gfx.animation.blinker.new(150, 150, true)
    self.blinker:start()

    return self
end

function StateHighscoreEntry:start()
    print('StateHighscoreEntry start')

    self.currentAlpha = 1
    self.currentPos = 1
    self.name = ''
    self.row = HighScoreManager:insert(Player:getScore(), LevelManager:getLevel())

    -- TODO: Determine starting row for high score
    self.rowX = 60
    self.rowY = 50 + (self.row * 20)
end

function StateHighscoreEntry:nextLetter()
    if self.currentAlpha == alpha:len() then
        self.currentAlpha = 1
    else
        self.currentAlpha += 1
    end
end

function StateHighscoreEntry:prevLetter()
    if self.currentAlpha == 1 then
        self.currentAlpha = alpha:len()
    else
        self.currentAlpha -= 1
    end
end

function StateHighscoreEntry:saveLetter(alph)
    self.name = self.name .. alph
    HighScoreManager:update(self.row, self.name)
    if self.currentPos < 3 then
        self.currentPos += 1

        local w, _ = gfx.getTextSize(self.name)
        self.rowX = 60 + w + self.currentPos - 1
    else
        -- Save new highscore
        HighScoreManager:save()

        StateHighscore:start(false)
        return StateHighscore
    end

    return self
end

function StateHighscoreEntry:update()
    Starfield:update()
    Dashboard:update()
    gfx.animation.blinker.updateAll()

    gfx.pushContext()
    gfx.setFont(font)

    HighScoreManager:draw(60, 40)

    -- Cursor is currently selected character position blinking
    local alph = alpha:sub(self.currentAlpha, self.currentAlpha)
    if self.blinker.on then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(alph, self.rowX, self.rowY)
    else
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(self.rowX, self.rowY, 16, 16)
    end

    if not pd.isCrankDocked() then
        local crankTicks = pd.getCrankTicks(CrankTicksPerRev)
        if crankTicks > 0 then
            self:nextLetter()
        elseif crankTicks < 0 then
            self:prevLetter()
        end
    end

    local state = self
    if pd.buttonJustPressed(pd.kButtonUp) then
        self:prevLetter()
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self:nextLetter()
    elseif pd.buttonJustPressed(pd.kButtonRight | pd.kButtonA | pd.kButtonB) then
        state = self:saveLetter(alph)
    end
    gfx.popContext()

    return state
end
