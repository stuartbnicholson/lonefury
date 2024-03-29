-- Explosions are non-critical pieces of animation. We create enough to share around,
-- but won't be particularly distressed if there are explosions missing from an in-flight game.
import 'Corelibs/animation'
import 'assets'

local gfx = playdate.graphics

Explosion = {}
Explosion.__index = Explosion

ExplosionSmall  = 0x01 -- Player, enemies, bullets
ExplosionMed    = 0x02 -- Enemy base spheres, larger enemies
ExplosionLarge  = 0x04 -- Enemy base destruction

local exploSmallImgTable = Assets.getImagetable('images/explosmall-table-15-15.png')
local exploMedImgTable = Assets.getImagetable('images/explomed-table-20-20.png')
local exploLargeImgTable = Assets.getImagetable('images/explobase-table-72-72.png')

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
        imgTable = exploLargeImgTable
        w = 72
        h = 72
    end

    local self = gfx.animation.loop.new(120, imgTable, false)
    self.size = size
    self.width = w
    self.height = h
    self.x = -100   -- Start offscreen
    self.y = -100

    function self:update()
        self:draw(self.x - (self.width >> 1), self.y - (self.height >> 1))
    end

    function self:explode(x, y)
        self.x = x
        self.y = y
        self.frame = 1
        self.paused = false
    end

    return self
end

-- Manage explosions, we only cycle a limited set
local explosions = {}
explosions[1] = Explosion.new(ExplosionSmall)
explosions[2] = Explosion.new(ExplosionSmall)
explosions[3] = Explosion.new(ExplosionSmall)
explosions[4] = Explosion.new(ExplosionMed)
explosions[5] = Explosion.new(ExplosionMed)
explosions[6] = Explosion.new(ExplosionLarge)

local exploSmallIdx = 1
local exploSmallMaxIdx <const> = exploSmallIdx + 2

local exploMedIdx = exploSmallMaxIdx + 1
local exploMedMaxIdx <const> = exploMedIdx + 1

local exploLargeIdx = exploMedMaxIdx + 1
local exploLargeMaxIdx <const> = exploLargeIdx

function ExplosionsUpdate()
    for i = 1, #explosions do
        if explosions[i]:isValid() then
            explosions[i]:update()
        end
    end
end

function Explode(size, x, y)
    if size == ExplosionSmall then
        SoundManager.smallExplosion()
        explosions[exploSmallIdx]:explode(x, y)
        if exploSmallIdx == exploSmallMaxIdx then
            exploSmallIdx = 1
        else
            exploSmallIdx += 1
        end
    elseif size == ExplosionMed then
        SoundManager.mediumExplosion()
        explosions[exploMedIdx]:explode(x, y)
        if exploMedIdx == exploMedMaxIdx then
            exploMedIdx = exploSmallMaxIdx + 1
        else
            exploMedIdx += 1
        end
    else
        SoundManager.largeExplosion()
        explosions[exploLargeIdx]:explode(x, y)
        if exploLargeIdx == exploLargeMaxIdx then
            exploLargeIdx = exploMedMaxIdx + 1
        else
            exploLargeIdx += 1
        end
    end
end
