-- State: Game highscore entry screen after game finishes!

local pd = playdate
local gfx = pd.graphics
local anim = gfx.animation

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local alpha <const> = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local CrankTicksPerRev <const> = 12 -- 360/30

StateHighscoreEntry = {}
StateHighscoreEntry.__index = StateHighscoreEntry

function StateHighscoreEntry.new()
    local self = setmetatable({}, StateHighscoreEntry)

    self.blinker = anim.blinker.new(150, 150, true)
    self.blinker:start()

    return self
end

function StateHighscoreEntry:start()
    Dashboard:update()
    Starfield.image:draw(0, 0)

    SoundManager:titleMusic(TitleMusic)

    self.currentAlpha = 1
    self.currentPos = 1
    self.name = ''
    self.row = HighScoreManager:insert(Player:getScore(), LevelManager:getLevel())

    -- TODO: Determine starting row for high score
    self.rowX = 60
    self.rowY = 50 + (self.row * 20)
end

function StateHighscoreEntry:nextLetter()
    SoundManager:interfaceClick()

    if self.currentAlpha == alpha:len() then
        self.currentAlpha = 1
    else
        self.currentAlpha += 1
    end
end

function StateHighscoreEntry:prevLetter()
    SoundManager:interfaceClick()
    if self.currentAlpha == 1 then
        self.currentAlpha = alpha:len()
    else
        self.currentAlpha -= 1
    end
end

function StateHighscoreEntry:saveLetter(alph)
    SoundManager:interfaceClick()

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
    anim.blinker.updateAll()

    gfx.setFont(font)

    HighScoreManager:draw(60, 40)

    -- Cursor is currently selected character position blinking
    local alph = alpha:sub(self.currentAlpha, self.currentAlpha)
    if self.blinker.on then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(alph, self.rowX, self.rowY)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(self.rowX, self.rowY, 16, 16)
        gfx.setColor(gfx.kColorWhite)
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

    return state
end
