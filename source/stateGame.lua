-- State: Game is actively running, player is fighting and dying but has lives left.

import 'CoreLibs/sprites'
import 'CoreLibs/crank'

import 'constants'
import 'asteroid'
import 'player'
import 'enemy'
import 'enemyBase'
import 'explosion'

local pd = playdate
local gfx = pd.graphics

-- Thrust the player ship constantly, or require button input
local PlayerConstantThrust <const> = true -- not pd.isSimulator
local CrankTicksPerRev <const> = 24       -- 360/15

Player = Player.new()

-- Where is the CENTRE of the ViewPort in the World?
ViewPortWorldX = 0
ViewPortWorldY = 0

StateGame = {}
StateGame.__index = StateGame

function StateGame.new()
    local self = setmetatable({}, StateGame)

    return self
end

function StateGame:buttonUpdate()
    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonDown) then
        Player:fire()
    end

    if PlayerConstantThrust or pd.buttonIsPressed(pd.kButtonUp) then
        Player:thrust()
    end

    -- Crank overrides buttons
    if pd.isCrankDocked() then
        if pd.buttonIsPressed(pd.kButtonLeft) then
            Player:left()
        end

        if pd.buttonIsPressed(pd.kButtonRight) then
            Player:right()
        end
    else
        local crankTicks = pd.getCrankTicks(CrankTicksPerRev)
        if crankTicks > 0 then
            Player:right()
        elseif crankTicks < 0 then
            Player:left()
        end
    end
end

function StateGame:start()
    Player:setAlive(true)
    LevelManager:levelStart()
end

function StateGame:update()
    -- Player input might change things.
    self:buttonUpdate()

    -- Update world positions based on the viewport - which is tied to the Player
    ViewPortWorldX, ViewPortWorldY = Player:getWorldV():unpack()

    -- ...then update world entities WITH collisions etc.
    WorldUpdate()

    if not Player:alive() then
        StateDead:start()
        return StateDead
    elseif LevelManager:isLevelClear() then
        StateNewLevel:start()
        return StateNewLevel
    else
        return self
    end
end
