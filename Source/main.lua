import "player"
import "asteroid"
import "starfield"

local gfx = playdate.graphics

local starfield = Starfield.new()
local player = Player.new()
local enemies = {}
local deltaX = 0
local deltaY = 0

-- Generate some placeholder enemies
enemies[1] = Asteroid.new(50, 50)
enemies[2] = Asteroid.new(350, 50)
enemies[3] = Asteroid.new(50, 150)

function buttonUpdate()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        player:fire()
    end

    if playdate.buttonIsPressed(playdate.kButtonDown) then
        deltaX, deltaY = player:thrust()
    end
 
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        player:left()
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        player:right()
    end     
end

--[[ button functions
function playdate.leftButtonHeld()
    print('left')
end

function playdate.rightButtonHeld()
    print('right')
end

function playdate.upButtonHeld()
    print('up')
end

function playdate.downButtonHeld()
    print('down')
end

function playdate.BButtonHeld()
    print('B')
end

function playdate.AButtonHeld()
    print('A')
end
]]--

function playdate.update()
    -- Reset
    deltaX = 0 -- If we don't reset these, but delta them down to 0 we'd have thrust simulation
    deltaY = 0

    -- Update
    buttonUpdate()
    starfield:update(deltaX, deltaY)
    for i, enemy in ipairs(enemies) do
        enemy:update(deltaX, deltaY)
    end

    -- Draw
    starfield:draw()    -- This works, it just doesn't work if you draw it via a background function? Odd
    gfx.sprite.update()

    -- playdate.drawFPS(0,0)
end

-- setup