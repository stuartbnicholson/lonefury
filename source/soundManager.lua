import 'assets'

-- Plays retro 80's chip sounds and samples
-- See https://www.youtube.com/watch?v=BMENZloYz6Q&list=LL&index=1
-- WAV assets from https://www.oryxdesignlab.com/
local snd = playdate.sound

SoundManager = {}
SoundManager.__index = SoundManager

local bazooka = Assets.getSamplePlayer('assets/oryx/bazooka.wav')
local computer_b = Assets.getSamplePlayer('assets/oryx/computer_b.wav')
local explode_a = Assets.getSamplePlayer('assets/oryx/explode_a.wav')
local explode_b = Assets.getSamplePlayer('assets/oryx/explode_b.wav')
local explode_c = Assets.getSamplePlayer('assets/oryx/explode_c.wav')
local collect_b = Assets.getSamplePlayer('assets/oryx/collect_b.wav')
local score = Assets.getSamplePlayer('assets/oryx/score.wav')
local extra_life = Assets.getSamplePlayer('assets/kronbits/Retro PowerUP 09.wav')
local roar = Assets.getSamplePlayer('assets/kronbits/Retro Roar 12.wav')
local start2 = Assets.getSamplePlayer('assets/start 2.wav')
local new_turn = Assets.getSamplePlayer('assets/oryx/new_turn.wav')
new_turn:setVolume(0.5)

function SoundManager.new()
    local self = setmetatable({}, SoundManager)

    self.playerSynth = snd.synth.new(snd.kWaveNoise)
    self.playerSynth:setADSR(0.02, 0.16, 0.02, 0.35)

    self.enemyBaseSynth = snd.synth.new(snd.kWaveNoise)
    self.enemyBaseSynth:setADSR(0.02, 0.22, 0.02, 0.35)

    self.enemySynth = snd.synth.new(snd.kWaveSawtooth)
    self.enemySynth:setADSR(0.1, 0.12, 0.15, 0.15)

    self.musicPlayer, error = snd.sampleplayer.new('assets/kronbits/Retro Music - ABMU - ChipWave 10 mono.wav')
    assert(self.musicPlayer, error)
    self.musicPlayer:setVolume(0.5)

    return self
end

function SoundManager:playerShoots()
    self.playerSynth:playNote(220, 0.25, 0.05)
end

function SoundManager:playerDies()
    bazooka:play(1)
end

function SoundManager:enemyDies()
    computer_b:play(1)
    -- self.enemySynth:playNote(1200, 0.10, 0.10)
end

function SoundManager:enemyBaseShoots()
    self.enemyBaseSynth:playNote(130, 0.25, 0.10)
end

function SoundManager:smallExplosion()
    explode_a:play(1)
    -- bazooka:play(1)
end

function SoundManager:mediumExplosion()
    explode_c:play(1)
end

function SoundManager:largeExplosion()
    explode_b:play(1)
end

function SoundManager:alert()
    collect_b:play(1)
end

function SoundManager:interfaceClick()
    score:play(1)
end

function SoundManager:titleMusic(play)
    if play and TitleMusic then
        if not self.musicPlayer:isPlaying() then
            self.musicPlayer:play(0) -- Loop until stopped
        end
    else
        if self.musicPlayer:isPlaying() then
            self.musicPlayer:stop()
        end
    end
end

function SoundManager:playerSpawn1()
    new_turn:play(1)
end

function SoundManager:playerSpawn2()
    start2:play(1)
end

function SoundManager:playerExtraLife()
    extra_life:play(1)
end

function SoundManager:roar()
    roar:play(1)
end
