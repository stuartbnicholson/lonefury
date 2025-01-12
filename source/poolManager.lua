import 'asteroid'
import 'egg'
import 'enemy'
import 'enemyBase'
import 'enemyBigBullet'
import 'enemyBaseZap'
import 'enemyMonster'
import 'playerBullet'
import 'mine'
import 'mineExplosion'

-- Manages pools of game objects, in an attempt to avoid Lua GC issues.
PoolManager = {}
PoolManager.__index = PoolManager

-- Object pooling
ASTEROID_POOL_SIZE = 80
MINE_POOL_SIZE = 30
MINE_EXPLOSION_POOL_SIZE = 3
EGG_POOL_SIZE = 10
ENEMY_POOL_SIZE = 20
ENEMYBASE_POOL_SIZE = 16
ENEMYBIGBULLET_POOL_SIZE = 15
ENEMYBASEZAP_POOL_SIZE = 4
ENEMYMONSTER_POOL_SIZE = 1
PLAYERBULLET_POOL_SIZE = 4

local levelObjPoolSize = {}
levelObjPoolSize[Asteroid] = ASTEROID_POOL_SIZE
levelObjPoolSize[Mine] = MINE_POOL_SIZE
levelObjPoolSize[MineExplosion] = MINE_EXPLOSION_POOL_SIZE
levelObjPoolSize[Egg] = EGG_POOL_SIZE
levelObjPoolSize[Enemy] = ENEMY_POOL_SIZE
levelObjPoolSize[EnemyBase] = ENEMYBASE_POOL_SIZE
levelObjPoolSize[EnemyBigBullet] = ENEMYBIGBULLET_POOL_SIZE
levelObjPoolSize[EnemyBaseZap] = ENEMYBASEZAP_POOL_SIZE
levelObjPoolSize[EnemyMonster] = ENEMYMONSTER_POOL_SIZE
levelObjPoolSize[PlayerBullet] = PLAYERBULLET_POOL_SIZE

function PoolManager.new()
    local self = setmetatable({}, PoolManager)

    -- Objects are pooled by type
    self.objPools = {}

    return self
end

-- Fill an object pool with new objects if req'd
function PoolManager:fillPool(obj, size)
    local pool = {}
    for i = 1, size do
        pool[i] = obj.new()
    end

    self.objPools[obj] = pool
end

-- Take all pooled objects OUT of the world, placing them back into the pool
function PoolManager:refillPool(obj)
    local pool = self.objPools[obj]
    local obj
    for i = 1, #pool do
        obj = pool[i]
        if obj.isSpawned then
            obj:despawn()
        end
    end
end

function PoolManager:freeInPool(obj, count)
    local pool = self.objPools[obj]

    -- Count > 1 is a special case, we usually expect to ask for single objects
    count = count or 1
    if count == 1 then
        for i = 1, #pool do
            -- isSpawned is a game special value, nothing to do with sprites
            if not pool[i].isSpawned then
                return pool[i]
            end
        end
    else
        local objs = {}
        local found = 0
        for i = 1, #pool do
            if not pool[i].isSpawned then
                table.insert(objs, pool[i])
                found += 1
                if found == count then
                    return objs
                end
            end
        end
    end

    return nil
end

function PoolManager:reset()
    -- TODO: Memory management monitoring: https://devforum.play.date/t/tracking-memory-usage-throughout-your-game/1132

    -- Create or re-fill pools
    for obj, count in pairs(levelObjPoolSize) do
        if not self.objPools[obj] then
            self:fillPool(obj, count)
        else
            self:refillPool(obj)
        end
    end
end
