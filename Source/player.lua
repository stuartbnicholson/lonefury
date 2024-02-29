import "CoreLibs/sprites"
import "imageLoader"

local gfx = playdate.graphics
local ROTATE_SPEED = 10

Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)

    local img = loadImage("images/player.png")
    self.sprite = gfx.sprite.new(img)
    self.sprite:moveTo(200,120)
    self.sprite:setZIndex(100)
    self.sprite:add()

    return self
end

function Player:thrust()
    local rot = self.sprite:getRotation()
    local deltaX = -math.sin(math.rad(rot))
    local deltaY = math.cos(math.rad(rot))

    return deltaX, deltaY
end

function Player:fire()
    -- TODO
end

function Player:left()
    self.sprite:setRotation(self.sprite:getRotation() - ROTATE_SPEED)
end

function Player:right()
    self.sprite:setRotation(self.sprite:getRotation() + ROTATE_SPEED)
end