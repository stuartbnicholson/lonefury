local gfx = playdate.graphics
local geom = playdate.geometry

Starfield = {}
Starfield.__index = Starfield

local STATIC_STARS = 160
local HINT_STARS = 10
local HINT_STAR_VELOCITY = 5.0

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

    -- Make sure there's no stars underneath the Player's ship because it looks visually ugly.
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(HALF_VIEWPORT_WIDTH - 1, HALF_VIEWPORT_HEIGHT - 1, 12)
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
    -- Draw some hint stars that move
    local pdx, pdy = Player:getWorldDelta()
    pdx *= HINT_STAR_VELOCITY
    pdy *= HINT_STAR_VELOCITY

    -- Decide which direction to draw the hint stars, based on the Player
    local dx = 0
    local dy = 0
    local angle = Player:getAngle()

    -- TODO: Angled schmutz?
    if angle < 45 or angle > 315 then
        dy = 1
    elseif angle < 135 then
        dx = 1
    elseif angle < 225 then
        dy = 1
    elseif angle < 315 then
        dx = 1
    end

    gfx.setColor(gfx.kColorWhite)
    for i = 1, #self.hintStars do
        local x = self.hintStars[i].x
        local y = self.hintStars[i].y
        x = (x + pdx) % VIEWPORT_WIDTH
        y = (y + pdy) % VIEWPORT_HEIGHT
        self.hintStars[i].x = x
        self.hintStars[i].y = y

        gfx.drawLine(x, y, x + dx, y + dy)
    end
end
