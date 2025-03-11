-- The game dashboard. Shows the player's score, lives, minimap, condition etc.
local gfx = playdate.graphics
local pd = playdate

Dashboard = {}
Dashboard.__index = Dashboard

local DASH_WIDTH = 80

local MINIMAP_SX = 325
local MINIMAP_SY = 122
local MINIMAP_WIDTH = 72
local MINIMAP_HEIGHT = 72
local MINIMAP_CELLW = 8
local MINIMAP_CELLH = 6
local ALERT_SX = VIEWPORT_WIDTH + 2
local ALERT_SY = 103

local medal1Img = Assets.getImage('images/medal1.png')
local medal5Img = Assets.getImage('images/medal5.png')
local playerLifeImg = Assets.getImage('images/playerLife.png')
local alertImg = Assets.getImage('images/alert.png')
local mapPlayerTable = Assets.getImagetable('images/mapPlayer-table-7-6.png')
local formationImg = Assets.getImage('images/cross.png')
local scoreFont = Assets.getFont('images/Xevious-Score-table-8-16.png')

function Dashboard.new()
    local self = setmetatable({}, Dashboard)

    self.dash = Assets.getImage('images/dashboard.png')
    self.miniMap = gfx.image.new(MINIMAP_WIDTH * MINIMAP_CELLW, MINIMAP_HEIGHT * MINIMAP_CELLH)
    self.story = nil

    -- Initial dashboard draw
    self:drawPlayerScore()
    self:drawLivesMedals()

    -- Alert blinker
    self.alertBlinker = gfx.animation.blinker.new(800, 400, true)
    self.alertBlinker:start()
    self.blinkerTurnedOn = false

    return self
end

function Dashboard:worldToDashXY(worldX, worldY)
    local mx, my

    mx = worldX / VIEWPORT_WIDTH
    mx = mx * MINIMAP_CELLW
    mx = lume.clamp(mx, 0, MINIMAP_WIDTH)

    my = worldY / VIEWPORT_HEIGHT
    my = my * MINIMAP_CELLH
    my = lume.clamp(my, 0, MINIMAP_HEIGHT)

    return mx, my
end

function Dashboard:addEnemyBase(worldX, worldY)
    local mx, my = self:worldToDashXY(worldX, worldY)

    gfx.pushContext(self.miniMap)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(mx, my, 2, 2)
    gfx.popContext()
end

function Dashboard:removeEnemyBase(worldX, worldY)
    local mx, my = self:worldToDashXY(worldX, worldY)

    gfx.pushContext(self.miniMap)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(mx, my, 2, 2)
    gfx.popContext()
end

function Dashboard:update()
    self.dash:draw(VIEWPORT_WIDTH, 0)
    self.miniMap:draw(MINIMAP_SX, MINIMAP_SY)
    self:drawAlertTimer()

    -- Draw formation leaders
    local mx, my
    for _, worldV in pairs(LevelManager:getFormationLeaders()) do
        mx, my = self:worldToDashXY(worldV.dx, worldV.dy)
        formationImg:draw(mx + MINIMAP_SX, my + MINIMAP_SY)
    end

    -- Draw the player ship roughly pointing the right way, but clipped to the mini map
    mx, my = self:worldToDashXY(Player:getWorldV():unpack())
    local frame = 1 + (Player:getAngle() // 45) % 8
    mapPlayerTable:drawImage(frame, mx + MINIMAP_SX - 3, my + MINIMAP_SY - 2)

    if self.story then
        self.story:update()
    end

    if ShowFPS then
        pd.drawFPS(VIEWPORT_WIDTH + 64, 3)
    end
end

function Dashboard:drawAlertTimer()
    -- LevelManager tells us percentage time left to next alert
    gfx.pushContext()
    local percent = LevelManager:percentAlertTimeLeft()

    if percent == 1 then
        -- Don't draw anything, dashboard contains danger bar
    elseif percent > 0 then
        self.blinkerTurnedOn = false
        gfx.setColor(gfx.kColorBlack)

        local fill = percent * 77
        gfx.fillRect(ALERT_SX + fill, ALERT_SY, 77 - fill, 13)
    else
        if self.alertBlinker.on then
            alertImg:draw(ALERT_SX, ALERT_SY)

            if not self.blinkerTurnedOn then
                self.blinkerTurnedOn = true
                SoundManager:alert()
            end
        else
            self.blinkerTurnedOn = false
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(ALERT_SX, ALERT_SY, 77, 13)
        end
    end
    gfx.popContext()
end

function Dashboard:drawPlayerScore()
    gfx.pushContext(self.dash)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, DASH_WIDTH, 26)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(scoreFont)
    gfx.drawText('' .. Player.score, 2, 3)

    gfx.popContext()
end

function Dashboard:drawLivesMedals()
    self:drawMedals()
    self:drawLives()
end

function Dashboard:drawMedals()
    gfx.pushContext(self.dash)

    -- Medals
    local medal1 = LevelManager.level % 5
    local medal5 = math.floor(LevelManager.level / 5)
    local x = 4
    local y = 205
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, 64, 14)
    -- TODO: Higher values
    -- Medals 5
    for i = 1, medal5 do
        medal5Img:draw(x, y)
        x += 8
    end
    -- Medals 1
    for i = 1, medal1 do
        medal1Img:draw(x, y)
        x += 8
    end
    gfx.popContext()
end

function Dashboard:drawLives()
    gfx.pushContext(self.dash)
    -- Lives
    local x = 4
    local y = 222
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, 75, 15)
    for i = 1, lume.clamp(Player.lives, 1, 6) - 1 do
        playerLifeImg:draw(x, y)
        x += 15
    end

    gfx.popContext()
end

function Dashboard:setStory(story)
    self.story = story
end
