-- Plays retro 80's chip sounds
-- See https://www.youtube.com/watch?v=BMENZloYz6Q&list=LL&index=1
local snd = playdate.sound

SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    local self = setmetatable({}, SoundManager)

    self.synth1 = snd.synth.new(snd.kWaveNoise)
    self.synth1:setADSR(0.02, 0.22, 0.02, 0.35)

    self.synth2 = snd.synth.new(snd.kWaveSawtooth)
    self.synth2:setADSR(0.1, 0.12, 0.15, 0.15)

    return self
end

function SoundManager:playerShoots()
    self.synth1:playNote(130, 0.25, 0.10)
    print('player pew')
end

function SoundManager:enemyDies()
    self.synth2:playNote(1200, 0.10, 0.10)
    print('enemy dies')
end

function SoundManager:enemyBaseShoots()
    -- TODO:
    print('enemy base pew')
end

function SoundManager:smallExplosion()
    -- TODO:
    print('small explosion')
end

function SoundManager:mediumExplosion()
    -- TODO:
    print('medium explosion')
end

function SoundManager:largeExplosion()
    -- TODO:
    print('large explosion')
end