-- State: Game highscore screen before game starts.

local pd = playdate

local TIMEOUT_MS = 1200 * 5

StateHighscore = {}
StateHighscore.__index = StateHighscore

function StateHighscore.new()
    local self = setmetatable({}, StateHighscore)
    self.acceptButtons = true

    return self
end

function StateHighscore:start(acceptButtons)
    SoundManager:titleMusic(TitleMusic)

    self.acceptButtons = acceptButtons
    self.started = pd.getCurrentTimeMilliseconds()
end

function StateHighscore:update()
    Starfield:update()
    Dashboard:update()

    HighScoreManager:draw(60, 40)

    if self.acceptButtons and pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        StateStart:start()
        return StateStart
    elseif pd.getCurrentTimeMilliseconds() - self.started > TIMEOUT_MS then
        StateMenu:start()
        return StateMenu
    else
        return self
    end
end
