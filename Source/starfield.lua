local gfx = playdate.graphics

Starfield = {}
Starfield.__index = Starfield

function Starfield.new()
    local self = setmetatable({}, Starfield)

    self.x = 0
    self.y = 0
    self.image = gfx.image.new(400, 240, gfx.kColorBlack)
    
    gfx.pushContext(self.image)
    gfx.setColor(gfx.kColorWhite)
    for i = 1, 160 do
        gfx.drawPixel(math.random(400), math.random(240))
    end
    gfx.popContext()

    -- Make background transparent so we can see starfield draws
    gfx.setBackgroundColor(gfx.kColorClear)

    return self
end

function Starfield:updateWorldPos(deltaX, deltaY)
    self.x += deltaX * 0.5
    self.y += deltaY * 0.5

    if math.floor(self.x) % 400 == 0 then
        self.x = 0
    end

    if math.floor(self.y) % 240 == 0 then
        self.y = 0
    end
end

function Starfield:draw()
    self.image:draw(self.x, self.y)

    if self.y > 0 then
        -- Draw additional stafield above
        self.image:draw(self.x, self.y - 240)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - 400, self.y - 240)
        elseif self.x < 0 then
            self.image:draw(self.x + 400, self.y - 240)
        end
    elseif self.y < 0 then
        -- Draw additional starfield below
        self.image:draw(self.x, self.y + 240)

        -- Don't forget the corners
        if self.x > 0 then
            self.image:draw(self.x - 400, self.y + 240)
        elseif self.x < 0 then
            self.image:draw(self.x + 400, self.y + 240)
        end
    end

    if self.x > 0 then
        -- Draw additional starfield left
        self.image:draw(self.x - 400, self.y)
    elseif self.x < 0 then
        -- Draw additional starfield right
        self.image:draw(self.x + 400, self.y)
    end
end