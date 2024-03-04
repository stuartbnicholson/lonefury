import "player"
import "asteroid"
import "enemy"
import "enemyBase"

import "dashboard"
import "starfield"

local gfx <const> = playdate.graphics

-- Collision Groups
GROUP_PLAYER = 0x01
GROUP_BULLET = 0x02
GROUP_ENEMY  = 0x04

local dashboard  <const> = Dashboard.new()
local starfield  <const> = Starfield.new()

local player <const> = Player.new()
PlayerScore = 0
local deltaX = 0
local deltaY = 0

-- Generate some placeholder enemies
local enemies <const> = {}
enemies[1] = Asteroid.new(50, 50)
enemies[2] = Asteroid.new(350, 50)
enemies[3] = Asteroid.new(50, 150)
enemies[4] = EnemyBase.new(300,140)
enemies[5] = Enemy.new(-50,50)
enemies[6] = Enemy.new(-30,-30)
enemies[7] = Enemy.new(-10,-10)

function getPlayer()
    return player
end

function buttonUpdate()
    if playdate.buttonIsPressed(playdate.kButtonB) then
        player:fire()
    end

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        deltaX, deltaY = player:thrust()

        deltaX *= 2.0
        deltaY *= 2.0
    end
 
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        player:left()
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        player:right()
    end     
end

function playdate.update()
    -- Reset
    deltaX *= 0.65 -- If we don't reset these, but delta them down to 0 we'd have thrust simulation
    deltaY *= 0.65

    -- Update
    buttonUpdate()
    starfield:updateWorldPos(deltaX, deltaY)
    for i, enemy in ipairs(enemies) do
        enemy:updateWorldPos(deltaX, deltaY)
    end

    -- Draw
    starfield:draw()    -- This works, it just doesn't work if you draw it via a background function? Odd
    gfx.sprite.update()
    dashboard:draw()
end

-- setup