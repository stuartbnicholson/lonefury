local gfx = playdate.graphics

Starfield = {}
Starfield.__index = Starfield

function Starfield.new()
    local self = setmetatable({}, Starfield)

    self.x = 0
    self.y = 0
    self.image = gfx.image.new(400, 240, gfx.kColorBlack)
    
    -- Draw starfield on background image so we don't have to update it constantly
    gfx.pushContext(self.image)
    gfx.setColor(gfx.kColorWhite)
    for i = 1, 80 do
        gfx.drawPixel(math.random(400), math.random(240))
    end
    gfx.popContext()
    
    return self
end

function Starfield:draw()
    self.image:draw(self.x, self.y)   
    
    print(self.x, self.y)
end