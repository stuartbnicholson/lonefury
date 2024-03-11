import 'CoreLibs/sprites'

import "player"
import "asteroid"
import "enemy"
import "enemyBase"
import "explosion"

import "dashboard"
import "starfield"

local gfx <const> = playdate.graphics

-- Collision Groups
GROUP_PLAYER = 0x01
GROUP_BULLET = 0x02
GROUP_ENEMY  = 0x04

SPRITE_TAGS = {
    player = 1,
    playerBullet = 2,
    asteroid = 3,
    enemy = 4,
    enemyBullet = 5,
    enemyBase = 6,
}

local dashboard  <const> = Dashboard.new()
local starfield  <const> = Starfield.new()
FrameCount = 0

local player <const> = Player.new()
PlayerScore = 0
local worldDeltaX = 0
local worldDeltaY = 0

-- Generate some placeholder enemies
local enemies <const> = {}
enemies[1] = Asteroid.new(50, 50)
enemies[2] = Asteroid.new(350, 50)
enemies[3] = Asteroid.new(50, 150)
enemies[4] = EnemyBase.new(100,240)
-- enemies[5] = Enemy.new(80,50)
-- enemies[6] = Enemy.new(-30,-30)
-- enemies[7] = Enemy.new(-10,-10)

-- Manage explosions, we only cycle three
local explosions <const> = {}
local explosionIdx = 1
local explosionMaxIdx = 3
explosions[1] = Explosion.new()
explosions[2] = Explosion.new()
explosions[3] = Explosion.new()

function Explode(x, y)
    explosions[explosionIdx]:explode(x, y)
    if explosionIdx == explosionMaxIdx then
        explosionIdx = 1
    else
        explosionIdx += 1
    end
end

function GetPlayer()
    return player
end

function ButtonUpdate()
    if playdate.buttonIsPressed(playdate.kButtonB) then
        player:fire()
    end

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        worldDeltaX, worldDeltaY = player:thrust()

        worldDeltaX *= 2.0
        worldDeltaY *= 2.0
    end
 
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        player:left()
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        player:right()
    end     
end

function playdate.update()
    worldDeltaX *= 0.65 -- If we don't reset these, but delta them down to 0 we'd have thrust simulation
    worldDeltaY *= 0.65

    -- Update
    ButtonUpdate()
    starfield:updateWorldPos(worldDeltaX, worldDeltaY)
    for i = 1, #enemies do
        enemies[i]:updateWorldPos(worldDeltaX, worldDeltaY)
    end

    -- Draw
    starfield:draw()    -- This works, it just doesn't work if you draw it via a background function? Odd
    gfx.sprite.update()

    for i = 1, #explosions do
        explosions[i]:update()
    end 

    dashboard:draw()

    FrameCount += 1
end