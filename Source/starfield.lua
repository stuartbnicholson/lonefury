local gfx = playdate.graphics
local geom = playdate.geometry

Starfield = {}
Starfield.__index = Starfield

STATIC_STARS = 160
HINT_STARS = 10

function Starfield.new()
    local self = setmetatable({}, Starfield)

    self.x = 0
    self.y = 0
    self.image = gfx.image.new(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, gfx.kColorBlack)

    gfx.pushContext(self.image)
    gfx.setColor(gfx.kColorWhite)
    for i = 1, STATIC_STARS do
        gfx.drawPixel(math.random(VIEWPORT_WIDTH), math.random(VIEWPORT_HEIGHT))
    end
    gfx.popContext()

    -- Make background transparent so we can see starfield draws
    gfx.setBackgroundColor(gfx.kColorClear)

    self.hintStars = {}
    for i = 1, HINT_STARS do
        self.hintStars[i] = geom.point.new(math.random(VIEWPORT_WIDTH), math.random(VIEWPORT_HEIGHT))
    end

    return self
end

function Starfield:update()
    -- This was originally an attempt to parallax scroll a viewport sized image, which requires drawing a large image multiple times
    -- which consumes about 5fps so probably isn't worth the effort. Instead we'll draw a stationary background and some 'hint' stars.
    self.image:draw(0, 0)

    -- TODO: Draw some hint stars that move
end