-- Plays retro 80's chip sounds
-- See https://www.youtube.com/watch?v=BMENZloYz6Q&list=LL&index=1
local snd = playdate.sound

SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    local self = setmetatable({}, SoundManager)

    self.playerSynth = snd.synth.new(snd.kWaveNoise)
    self.playerSynth:setADSR(0.02, 0.16, 0.02, 0.35)

    self.enemyBaseSynth = snd.synth.new(snd.kWaveNoise)
    self.enemyBaseSynth:setADSR(0.02, 0.22, 0.02, 0.35)

    self.enemySynth = snd.synth.new(snd.kWaveSawtooth)
    self.enemySynth:setADSR(0.1, 0.12, 0.15, 0.15)

    return self
end

function SoundManager:playerShoots()
    self.playerSynth:playNote(220, 0.25, 0.05)
end

function SoundManager:enemyDies()
    self.enemySynth:playNote(1200, 0.10, 0.10)
end

function SoundManager:enemyBaseShoots()
    self.enemyBaseSynth:playNote(130, 0.25, 0.10)
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