-- The minimalist talking heads that give you the 'game story'. Performed with a hand rolled state machine.

local pd = playdate
local gfx = pd.graphics

StoryLane = {}
StoryLane.__index = StoryLane

local font = Assets.getFont('images/Xevious-table-8-8.png')
local talkingHeads = Assets.getImagetable('images/talkingHeads-table-32-32.png')
local fade = Assets.getImagetable('images/fade-table-32-32.png')
local stories = {
    {
        level = 1,
        frame = 1,
        text  = { "PILOT--", "LAUNCH", "DENIED!", "RETURN", "TO BASE", "IMMEDIA", "TELY!", "", "", "" }
    },
    {
        level = 3,
        frame = 2,
        text = { "PILOT--", "ALL ENE", "MY BASE", "ALERTED", "OF LONE", "FURY!", "STAND", "DOWN!", "", "", "" }
    },
    {
        level = 5,
        frame = 3,
        text = { "TRAITOR", "--", "ENEMY", "CLEARED", "TO KILL", "LONE", "FURY!", "DIPLOMA", "TIC CAL", "AMITY!", "", "", "" }
    },
    {
        level = 8,
        frame = 4,
        text = { "ZZZ--", "HUMAN", "PILOT", "THIS IS", "WAR! ZZ", "FRAGILE", "CEASE", "FIRE", "TERMIN", "ATED!", "", "", "" }
    }
}

local TALKINGHEAD_X = 327
local TALKINGHEAD_Y = 32
local TALKINGHEAD_W = 32
local TALKINGHEAD_H = 32
local TALKINGHEAD_FADEMS = 300
local TALKINGHEAD_TALK = 1500

local STORY_X = 328
local STORY_Y = 71
local STORY_W = 66
local STORY_H = 25

StoryLane = {}
StoryLane.__index = StoryLane

function StoryLane.new()
    local self = setmetatable({}, StoryLane)

    self.head = nil
    self.text = nil
    self.startMs = nil

    return self
end

function StoryLane:waitUpdate(nowMs)
    if nowMs > self.endMs then
        self.fadeFrame = 6
        self.updateFunc = StoryLane.fadeInUpdate
    end
end

function StoryLane:fadeInUpdate(nowMs)
    if nowMs > self.endMs then
        if self.fadeFrame > 1 then
            self.fadeFrame -= 1
            self.endMs = nowMs + TALKINGHEAD_FADEMS

            local fade = fade:getImage(self.fadeFrame)
            self.head:setMaskImage(fade)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            self.head:draw(TALKINGHEAD_X, TALKINGHEAD_Y)
        else
            self.textIdx = 1
            self.endMs = nowMs
            self.updateFunc = StoryLane.talkingHeadUpdate
        end
    end
end

function StoryLane:talkingHeadUpdate(nowMs)
    if nowMs > self.endMs then
        gfx.setFont(font)

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(STORY_X, STORY_Y, STORY_W, STORY_H)
        gfx.setColor(gfx.kColorWhite)

        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local storyY = STORY_Y
        for i = 0, 2 do
            gfx.drawText(self.text[self.textIdx + i], STORY_X, storyY)
            storyY += 9
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        if self.textIdx < #self.text - 2 then
            self.textIdx += 1
            self.endMs = nowMs + TALKINGHEAD_TALK
        else
            self.fadeFrame = 0
            self.updateFunc = StoryLane.fadeOutUpdate
        end
    end
end

function StoryLane:fadeOutUpdate(nowMs)
    if nowMs > self.endMs then
        if self.fadeFrame < 5 then
            self.fadeFrame += 1
            self.endMs = nowMs + TALKINGHEAD_FADEMS

            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(TALKINGHEAD_X, TALKINGHEAD_Y, TALKINGHEAD_W, TALKINGHEAD_H)
            gfx.setColor(gfx.kColorWhite)

            local fade = fade:getImage(self.fadeFrame)
            self.head:setMaskImage(fade)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            self.head:draw(TALKINGHEAD_X, TALKINGHEAD_Y)
        else
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(STORY_X, STORY_Y, STORY_W, STORY_H)
            gfx.setColor(gfx.kColorWhite)

            self.updateFunc = nil
        end
    end
end

function StoryLane:start(level, nowMs)
    for _, story in ipairs(stories) do
        if story.level == level then
            self.head = talkingHeads:getImage(story.frame)
            self.text = story.text
            self.textIdx = 1
            self.endMs = nowMs + 3000
            self.updateFunc = StoryLane.waitUpdate

            return self
        end
    end

    return nil
end

function StoryLane:clear()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(TALKINGHEAD_X, TALKINGHEAD_Y, TALKINGHEAD_W, TALKINGHEAD_H)
    gfx.fillRect(STORY_X, STORY_Y, STORY_W, STORY_H)
    gfx.setColor(gfx.kColorWhite)
end

function StoryLane:update()
    local now = pd.getCurrentTimeMilliseconds()

    if Player:alive() and self.updateFunc then
        self:updateFunc(now)
    else
        self:clear()
    end
end
