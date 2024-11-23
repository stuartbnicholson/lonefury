-- State: Game highscore entry screen after game finishes!
import 'constants'

local pd = playdate

StateHighscoreEntry = {}
StateHighscoreEntry.__index = StateHighscoreEntry

function StateHighscoreEntry.new()
    local self = setmetatable({}, StateHighscoreEntry)

    return self
end

function StateHighscoreEntry:start()
    print('StateHighscoreEntry start')
end

function StateHighscoreEntry:update()
    Starfield:update()
    Dashboard:update()

    -- TODO: HERE:

    return self
end
