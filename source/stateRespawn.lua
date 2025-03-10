-- State: Player is respawning for another round

local pd = playdate
local gfx = pd.graphics

StateRespawn = {}
StateRespawn.__index = StateRespawn

function StateRespawn.new()
    local self = setmetatable({}, StateRespawn)

    self.blinker = gfx.animation.blinker.new(600, 600, false, 4)
    self.blinker:stop()

    return self
end

function StateRespawn:start()
    -- if DEVELOPER_BUILD then MemoryCheck() end

    -- Despawn every enemy and their bullets
    PoolManager:refillPool(Enemy)
    PoolManager:refillPool(EnemyMonster)
    PoolManager:refillPool(EnemyBigBullet)
    PoolManager:refillPool(EnemyBaseZap)

    -- Recenter world, to make sure player isn't near anything dangerous
    Player.worldV.dx = WORLD_PLAYER_STARTX
    Player.worldV.dy = WORLD_PLAYER_STARTY
    Player:resetAngle()
    Player:add()
    Player:setAlive(false) -- Player is spawning, not quite alive yet!

    ViewPortWorldX, ViewPortWorldY = Player:getWorldV():unpack()

    Dashboard:drawLivesMedals()
    self.blinker:start(600, 600, false, 5)
    self.prevOn = false
end

function StateRespawn:update()
    LevelManager:clockReset() -- While the Player spawns, keep resetting the level clock
    WorldUpdateInTitles()

    if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    elseif FixedCrank then
        Player:crankAngle()
    end

    gfx.animation.blinker.updateAll()
    if self.blinker.running then
        if self.blinker.on then
            Player:setVisible(true)
            if not self.prevOn then
                if self.blinker.counter == 1 then
                    SoundManager:playerSpawn2()
                else
                    SoundManager:playerSpawn1()
                end
            end
            self.prevOn = true
        else
            Player:setVisible(false)
            self.prevOn = false
        end
    else
        StateGame:start()
        return StateGame
    end

    return self
end
