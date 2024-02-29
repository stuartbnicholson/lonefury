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
    for i = 1, 80 do
        gfx.drawPixel(math.random(400), math.random(240))
    end
    gfx.popContext()

    -- Make background transparent so we can see starfield draws
    gfx.setBackgroundColor(gfx.kColorClear)

    return self
end

function Starfield:update(deltaX, deltaY)    
    self.x += deltaX * 0.5
    self.y += deltaY * 0.5
end

function Starfield:draw()
    self.image:draw(self.x, self.y)   
end