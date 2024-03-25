local gfx = playdate.graphics

Starfield = {}
Starfield.__index = Starfield

function Starfield.new()
    local self = setmetatable({}, Starfield)

    self.x = 0
    self.y = 0
    self.image = gfx.image.new(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, gfx.kColorBlack)

    gfx.pushContext(self.image)
    gfx.setColor(gfx.kColorWhite)
    for i = 1, 160 do
        gfx.drawPixel(math.random(VIEWPORT_WIDTH), math.random(VIEWPORT_HEIGHT))
    end
    gfx.popContext()

    -- Make background transparent so we can see starfield draws
    gfx.setBackgroundColor(gfx.kColorClear)

    return self
end

function Starfield:update()
    self.image:draw(0, 0)

    --[[TODO: This needs to be totally re-worked
    if self.y > 0 then
        -- Draw additional stafield above
        self.image:draw(self.x, self.y - VIEWPORT_HEIGHT)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - VIEWPORT_WIDTH, self.y - VIEWPORT_HEIGHT)
        elseif self.x < 0 then
            self.image:draw(self.x + VIEWPORT_WIDTH, self.y - VIEWPORT_HEIGHT)
        end
    elseif self.y < 0 then
        -- Draw additional starfield below
        self.image:draw(self.x, self.y + VIEWPORT_HEIGHT)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - VIEWPORT_WIDTH, self.y + VIEWPORT_HEIGHT)
        elseif self.x < 0 then
            self.image:draw(self.x + VIEWPORT_WIDTH, self.y + VIEWPORT_HEIGHT)
        end
    end

    if self.x > 0 then
        -- Draw additional starfield left
        self.image:draw(self.x - VIEWPORT_WIDTH, self.y)
    elseif self.x < 0 then
        -- Draw additional starfield right
        self.image:draw(self.x + VIEWPORT_WIDTH, self.y)
    end
    ]]
end