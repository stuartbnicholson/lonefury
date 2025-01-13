-- Collision Groups
GROUP_PLAYER            = 0x01
GROUP_BULLET            = 0x02
GROUP_ENEMY             = 0x04
GROUP_OBSTACLE          = 0x08
GROUP_ENEMY_BASE        = 0x10

SPRITE_TAGS             = {
    player = 1,
    playerBullet = 2,
    asteroid = 3,
    enemy = 4,
    enemyBullet = 5,
    enemyBase = 6,
    egg = 7,
    mine = 8,
    mineExplosion = 9
}

-- World gameplay occurs in (minus the dashboard)
VIEWPORT_WIDTH          = 400 - 80
VIEWPORT_HEIGHT         = 240

HALF_VIEWPORT_WIDTH     = VIEWPORT_WIDTH >> 1
HALF_VIEWPORT_HEIGHT    = VIEWPORT_HEIGHT >> 1

MINIMAP_WIDTH           = 9
MINIMAP_HEIGHT          = 12

WORLD_WIDTH             = 320 * MINIMAP_WIDTH
WORLD_HEIGHT            = 240 * MINIMAP_HEIGHT

WORLD_PLAYER_STARTX     = WORLD_WIDTH >> 1
WORLD_PLAYER_STARTY     = WORLD_HEIGHT >> 1

-- Playing scoring!
SCORE_ASTEROID          = 5
SCORE_EGG               = 8
SCORE_ENEMY             = 15
SCORE_ENEMYBASE_SPHERE  = 25 -- * 6 = 150
SCORE_ENEMYBASE_ONESHOT = 250
SCORE_MINE              = 10
SCORE_EXTRALIFE         = 2500

HIGHSCORE_TABLEFILE     = 'highscores'
HIGHSCORE_MAX           = 6
