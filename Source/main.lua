import "player"
import "asteroid"
import "starfield"

local gfx = playdate.graphics

local player = Player.new()
local asteroid1 = Asteroid.new(50, 50)
local asteroid2 = Asteroid.new(350, 50)
local asteroid3 = Asteroid.new(50, 150)

local starfield = Starfield.new()
gfx.sprite.setBackgroundDrawingCallback(
    function(x,y,w,h)
        starfield:draw()
    end
)

--[[
    So we have a starfield that moves slowly
    And objects sprites that move quickly over it in response to the player ship
    The player ship never leaves the centre of the screen
    
    If a sprite is offscreen we don't need to draw it (PlayDate handles that)?
    What happens if we reach the end of the world? We wrap.
]]--


function playerThrust()
    local rot = player.sprite:getRotation()
    local x = math.cos(rot)
    local y = math.sin(rot)

    starfield.x += x
    starfield.y += y
end

function buttonUpdate()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        player:fire()
    end

    if playdate.buttonIsPressed(playdate.kButtonDown) then
        playerThrust()
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
    buttonUpdate()

    gfx.sprite.update()

    -- playdate.drawFPS(0,0)
end

-- setup