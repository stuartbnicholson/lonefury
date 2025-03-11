-- The minimalist talking heads that give you the 'game story'.

local pd = playdate
local gfx = playdate.graphics

StoryLane = {}
StoryLane.__index = StoryLane

local font = Assets.getFont('images/Xevious-table-8-8.png')
local talkingHeads = Assets.getImagetable('images/talkingHeads-table-32-32.png')
local stories = {
    {
        level = 1,
        frame = 1,
        text  = { "PILOT--", "LAUNCH", "DENIED!", "RETURN", "TO BASE", "IMMEDIA", "TELY!" }
    },
    {
        level = 3,
        frame = 2,
        text = { "PILOT--", "ALL ENE", "MY BASE", "ALERTED", "OF LONE", "FURY!", "STAND", "DOWN!" }
    },
    {
        level = 5,
        frame = 3,
        text = { "TRAITOR", "--", "ENEMY", "CLEARED", "TO KILL", "LONE", "FURY!", "DIPLOMA", "TIC CALA", "MITY!" }
    }
}

local TALKINGHEAD_X = 327
local TALKINGHEAD_Y = 32

local STORY_X = 328
local STORY_Y = 71
local STORY_LINES = 3

StoryLane = {}
StoryLane.__index = StoryLane

function StoryLane.new()
    local self = setmetatable({}, StoryLane)

    self.head = nil
    self.text = nil
    self.startMs = nil

    return self
end

function StoryLane:start(level)
    for _, story in ipairs(stories) do
        if story.level == level then
            self.head = talkingHeads:getImage(story.frame)
            self.text = story.text
            self.textIdx = 1
            self.startMs = pd.getCurrentTimeMilliseconds()

            return self
        end
    end

    return nil
end

function StoryLane:update()
    local now = pd.getCurrentTimeMilliseconds()

    if Player:alive() then
        -- TODO: Storylane pause

        -- TODO: Storylane come in

        -- TODO: Relay message
        gfx.setFont(font)
        self.head:draw(TALKINGHEAD_X, TALKINGHEAD_Y)

        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local storyY = STORY_Y
        for i = 0, 2 do
            gfx.drawText(self.text[self.textIdx + i], STORY_X, storyY)
            storyY += 9
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        -- TODO: Storylane over and out
    else
    end
end
