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
    deltaX *= 0.65 -- If we don't reset these, but delta them down to 0 we'd have thrust simulation
    deltaY *= 0.65
    print(deltaX, deltaY)

    -- Update
    buttonUpdate()
    starfield:update(deltaX, deltaY)
    for i, enemy in ipairs(enemies) do
        enemy:updateWorldPos(deltaX, deltaY)
    end

    -- Draw
    starfield:draw()    -- This works, it just doesn't work if you draw it via a background function? Odd
    gfx.sprite.update()

    local collisions = gfx.sprite.allOverlappingSprites()
    if #collisions > 0 then
        print('Collision! ' .. #collisions)
    end

    playdate.drawFPS(0,0)
end

-- setup