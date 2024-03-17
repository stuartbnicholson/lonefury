import 'Corelibs/animation'

local gfx = playdate.graphics

Explosion = {}
Explosion.__index = Explosion

ExplosionSmall  = 0x01 -- Player, enemies, bullets
ExplosionMed    = 0x02 -- Enemy base spheres, larger enemies
ExplosionLarge  = 0x04 -- Enemy base destruction

local err
local exploSmallImgTable, err = gfx.imagetable.new("images/explosmall-table-15-15.png")
assert(exploSmallImgTable, err)
local exploMedImgTable, err = gfx.imagetable.new("images/explomed-table-20-20.png")
assert(exploMedImgTable, err)
-- TODO: ExplosionLarge

function Explosion.new(size)
    local w,h,imgTable
    if size == ExplosionSmall then
        imgTable = exploSmallImgTable
        w = 15
        h = 15
    elseif size == ExplosionMed then
        imgTable = exploMedImgTable
        w = 20
        h = 20
    elseif size == ExplosionLarge then
        assert(false, "TODO!")
    end

    local self = gfx.animation.loop.new(120, imgTable, false)
    self.size = size
    self.width = w
    self.height = h
    self.x = -100   -- Start offscreen
    self.y = -100

    function self:update()
        if self:isValid() then
            self:draw(self.x - (self.width >> 1), self.y - (self.height >> 1))
        end
    end

    function self:explode(x, y)
        self.x = x
        self.y = y
        self.frame = 1
    end

    return self
end

-- Manage explosions, we only cycle a limited set
local explosions <const> = {}
explosions[1] = Explosion.new(ExplosionSmall)
explosions[2] = Explosion.new(ExplosionSmall)
explosions[3] = Explosion.new(ExplosionSmall)
explosions[4] = Explosion.new(ExplosionMed)
explosions[5] = Explosion.new(ExplosionMed)
local exploSmallIdx = 1
local exploSmallMaxIdx <const> = exploSmallIdx + 2
local exploMedIdx = exploSmallMaxIdx + 1
local exploMedMaxIdx <const> = exploMedIdx + 1

function ExplosionsUpdate()
    for i = 1, #explosions do
        explosions[i]:update()
    end
end

function Explode(size, x, y)
    if size == ExplosionSmall then
        print('Explode: ' .. size .. ' ' .. exploSmallIdx)
        explosions[exploSmallIdx]:explode(x, y)
        if exploSmallIdx == exploSmallMaxIdx then
            exploSmallIdx = 1
        else
            exploSmallIdx += 1
        end
    elseif size == ExplosionMed then
        print('Explode: ' .. size .. ' ' .. exploMedIdx)
        explosions[exploMedIdx]:explode(x, y)
        if exploMedIdx == exploMedMaxIdx then
            exploMedIdx = exploSmallMaxIdx + 1
        else
            exploMedIdx += 1
        end
    else
        assert(false, "TODO!")
    end
end
