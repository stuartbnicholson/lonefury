local pd = playdate
local snd = playdate.sound

MusicManager = {}
MusicManager.__index = MusicManager

-- Load multi-track frequency based music from JSON files.
function MusicManager.new()
    local self = setmetatable({}, MusicManager)

    return self
end

-- Converts frequency to MIDI note (in the C3 middle C standard).
-- See https://devforum.play.date/t/playdate-sound-track-addnote-uses-midi-but-playdate-sound-synth-playnote-uses-pitch/17410
function MusicManager:freqToNote(f)
    return 69+12 * math.log(f / 440)
    -- return (39.863137 * math.log(f)) - 36.376317
end

-- Loads music JSON file and returns decoded table
function MusicManager:loadMusicFile(jsonFilename)
    local file, err = pd.file.open(jsonFilename)
    assert(file, error)
    local music = json.decodeFile(file)
    file:close()

    return music
end

-- Loads music JSON, returns a Sequence with Tracks and Synths
function MusicManager:loadMusicJSON(music)
    local seq = snd.sequence.new()
    seq:setTempo(music.tempo)

    local trac, track, instr, synth, note
    for i = 1, #music.tracks do
        --[[ from pd_api_sound.h
            typedef enum
            {
                kWaveformSquare,
                kWaveformTriangle,
                kWaveformSine,
                kWaveformNoise,
                kWaveformSawtooth,
                kWaveformPOPhase,
                kWaveformPODigital,
                kWaveformPOVosim
            } SoundWaveform;
        ]]
        trac = music.tracks[i]
        if trac.on then
            instr = trac.instrument
            synth = snd.synth.new(instr.wave)
            if instr.a or instr.d or instr.s or instr.r then
                synth:setADSR(instr.a, instr.d, instr.s, instr.r)
            end
            if instr.vol then
                synth:setVolume(instr.vol)
            end
            track = snd.track.new()
            track:setInstrument(synth)

            for j = 1, #trac.notes do
                note = trac.notes[j]
                track:addNote(note.seq, self:freqToNote(note.freq), note.dur, note.vel)
            end
            seq:addTrack(track)
        end
    end

    return seq
end

function MusicManager:loadMusic(musicFile)
    local json = self:loadMusicFile(musicFile)
    local seq = self:loadMusicJSON(json)
    return seq
end