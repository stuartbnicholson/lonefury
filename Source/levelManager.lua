-- Generates levels! Sets up the minimap, sets enemy limits, bullet speeds etc.
LevelManager = {}
LevelManager.__index = LevelManager

function LevelManager.new()
    local self = setmetatable({}, LevelManager)

    self:reset()
    
    return self
end

function LevelManager:reset()
    self.level = 1  -- ad astra!
end

function LevelManager:nextLevel()
    self.level += 1

    -- TODO: Generate minimap

    -- TODO: Set enemy counts and speeds
end