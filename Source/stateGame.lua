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
local PlayerConstantThrust <const> = not pd.isSimulator
local CrankTicksPerRev <const> = 24 -- 360/15

Player = Player.new()
local worldDeltaX = 0
local worldDeltaY = 0

-- Generate some placeholder enemies
Enemies = {}
Enemies[1] = Asteroid.new(50, 50)
Enemies[2] = Asteroid.new(350, 50)
Enemies[3] = Asteroid.new(50, 150)
Enemies[4] = EnemyBase.new(100,240)
-- Enemies[5] = Enemy.new(80,50)
-- Enemies[6] = Enemy.new(-30,-30)
-- Enemies[7] = Enemy.new(-10,-10)

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
        worldDeltaX, worldDeltaY = Player:thrust()

        worldDeltaX *= 2.0
        worldDeltaY *= 2.0
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
    print('StateGame start')

    Player:spawn()
end

function StateGame:update()
    -- If we don't reset these, but delta them down to 0 we'd have thrust simulation\
    -- We also only care about worldDelta when the Player is alive and scorllin'
    worldDeltaX *= 0.65
    worldDeltaY *= 0.65

    -- Update
    self:buttonUpdate()
    Starfield:updateWorldPos(worldDeltaX, worldDeltaY)
    for i = 1, #Enemies do
        Enemies[i]:updateWorldPos(worldDeltaX, worldDeltaY)
    end

    WorldUpdate()

    if not Player.isAlive then
        StateDead:start()
        return StateDead
    else
        return self
    end
end