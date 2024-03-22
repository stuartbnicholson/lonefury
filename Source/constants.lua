-- Collision Groups
GROUP_PLAYER = 0x01
GROUP_BULLET = 0x02
GROUP_ENEMY  = 0x04

SPRITE_TAGS = {
    player = 1,
    playerBullet = 2,
    asteroid = 3,
    enemy = 4,
    enemyBullet = 5,
    enemyBase = 6,
}

-- World gameplay occurs in (minus the dashboard)
WORLD_WIDTH = 400 - 80
WORLD_HEIGHT = 240