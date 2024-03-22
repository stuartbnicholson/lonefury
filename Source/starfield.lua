local gfx = playdate.graphics

Starfield = {}
Starfield.__index = Starfield

function Starfield.new()
    local self = setmetatable({}, Starfield)

    self.x = 0
    self.y = 0
    self.image = gfx.image.new(WORLD_WIDTH, WORLD_HEIGHT, gfx.kColorBlack)
    
    gfx.pushContext(self.image)
    gfx.setColor(gfx.kColorWhite)
    for i = 1, 160 do
        gfx.drawPixel(math.random(WORLD_WIDTH), math.random(WORLD_HEIGHT))
    end
    gfx.popContext()

    -- Make background transparent so we can see starfield draws
    gfx.setBackgroundColor(gfx.kColorClear)

    return self
end

function Starfield:updateWorldPos(deltaX, deltaY)
    self.x += deltaX * 0.5
    self.y += deltaY * 0.5

    if math.floor(self.x) % WORLD_WIDTH == 0 then
        self.x = 0
    end

    if math.floor(self.y) % WORLD_HEIGHT == 0 then
        self.y = 0
    end
end

function Starfield:update()
    self.image:draw(self.x, self.y)

    if self.y > 0 then
        -- Draw additional stafield above
        self.image:draw(self.x, self.y - WORLD_HEIGHT)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - WORLD_WIDTH, self.y - WORLD_HEIGHT)
        elseif self.x < 0 then
            self.image:draw(self.x + WORLD_WIDTH, self.y - WORLD_HEIGHT)
        end
    elseif self.y < 0 then
        -- Draw additional starfield below
        self.image:draw(self.x, self.y + WORLD_HEIGHT)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - WORLD_WIDTH, self.y + WORLD_HEIGHT)
        elseif self.x < 0 then
            self.image:draw(self.x + WORLD_WIDTH, self.y + WORLD_HEIGHT)
        end
    end

    if self.x > 0 then
        -- Draw additional starfield left
        self.image:draw(self.x - WORLD_WIDTH, self.y)
    elseif self.x < 0 then
        -- Draw additional starfield right
        self.image:draw(self.x + WORLD_WIDTH, self.y)
    end
end