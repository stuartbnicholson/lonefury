import "CoreLibs/sprites"

local gfx = playdate.graphics
local geom = playdate.geometry

local stars = {}
local numStars = 50
local framecount = 0

for i = 1,numStars do
    stars[i] = geom.point.new(math.random(400), math.random(240))
end

function starfield()
    gfx.clear(gfx.kColorBlack)

    -- Draw most stars
    gfx.setColor(gfx.kColorWhite)
    for i = 1, numStars - 10 do
       gfx.drawPixel(stars[i])
    end

    -- Draw the rest to twinkle
    framecount += 1
    if framecount % 30 > 15 then
        for i = numStars - 10, numStars do
            gfx.drawPixel(stars[i])
         end     
    end
end

gfx.sprite.setBackgroundDrawingCallback(starfield)

local playerShip = nil
local shipImg, err = gfx.image.new("player.png")
if shipImg ~= nil then
    playerShip = gfx.sprite.new(shipImg)
    playerShip:moveTo(200,120)
    playerShip:add()
    playerShip:setRotation(90)

    w, h = shipImg:getSize()
    print('image size: ' .. w .. ', ' .. h)
else
    print('nil ship image? ' .. err)
end

function playdate.update()
    gfx.sprite.update()

    playdate.drawFPS(0,0)
end
