-- Explosions are non-critical pieces of animation. We create enough to share around,
-- but won't be particularly distressed if there are explosions missing from an in-flight game.
local pd                 = playdate
local gfx                = pd.graphics
local anim               = gfx.animation

Explosion                = {}
Explosion.__index        = Explosion

ExplosionSmall           = 0x01 -- Player, enemies, bullets
ExplosionMed             = 0x02 -- Enemy base spheres, larger enemies
ExplosionLarge           = 0x04 -- Enemy base destruction

local exploSmallImgTable = Assets.getImagetable('images/explosmall-table-15-15.png')
local exploMedImgTable   = Assets.getImagetable('images/explomed-table-20-20.png')
local exploLargeImgTable = Assets.getImagetable('images/explobase-table-72-72.png')

function Explosion.new(size)
    local w, h, imgTable
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

    local self = anim.loop.new(120, imgTable, false)
    self.size = size
    self.width = w
    self.height = h
    self.worldX = -100 -- Start offscreen
    self.x = -100
    self.worldY = -100
    self.y = -100

    function self:update()
        -- Larger explosions adjust viewport position so they don't drift
        if self.size > ExplosionSmall then
            self.x, self.y = WorldToViewPort(self.worldX, self.worldY)
        end

        self:draw(self.x - (self.width >> 1), self.y - (self.height >> 1))
    end

    function self:explode(worldX, worldY)
        self.worldX = worldX
        self.worldY = worldY
        self.frame = 1
        self.paused = false

        -- Small explosions don't bother adjusting viewport position, for an simple drift effect
        if self.size == ExplosionSmall then
            self.x, self.y = WorldToViewPort(self.worldX, self.worldY)
        end
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

function Explode(size, worldX, worldY, withoutSound)
    if size == ExplosionSmall then
        if not withoutSound then
            SoundManager.smallExplosion()
        end
        explosions[exploSmallIdx]:explode(worldX, worldY)
        if exploSmallIdx == exploSmallMaxIdx then
            exploSmallIdx = 1
        else
            exploSmallIdx += 1
        end
    elseif size == ExplosionMed then
        if not withoutSound then
            SoundManager.mediumExplosion()
        end
        explosions[exploMedIdx]:explode(worldX, worldY)
        if exploMedIdx == exploMedMaxIdx then
            exploMedIdx = exploSmallMaxIdx + 1
        else
            exploMedIdx += 1
        end
    else
        if not withoutSound then
            SoundManager.largeExplosion()
        end
        explosions[exploLargeIdx]:explode(worldX, worldY)
        if exploLargeIdx == exploLargeMaxIdx then
            exploLargeIdx = exploMedMaxIdx + 1
        else
            exploLargeIdx += 1
        end
    end
end
