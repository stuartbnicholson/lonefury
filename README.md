# TODO:

A good description of the flocking algo: https://www.oreilly.com/library/view/ai-for-game/0596005555/ch04.html

## Game:
- Levels etc.
- Lives, respawning
- Dashboard
    - Minimap

## World
- Button input and then WorldX,Y updates PRIOR to any delta movement with collision detection. Otherwise things get funky...!

## Player
- Lives
- Dashboard
- Multiple bullets

## Enemies
- Asteroids
 
- Dive Bombers:
    - Limit their turn
    - Avoid colliding with friends
    - AI flight from the ORielly book

- Bases
    - Firing - they fire from the domes! 
    - Spawning dive bombers
    
## History

### 20-Mar-24

- Cranking the ship
- Bases
    - Firing - they fire from the domes! 
- Try it out on an actual device

### 18-Mar-24

- Base explosions!

### 9-Mar-24

- Pixel perfect collisions
- Player explosion
- Working on base death

### 5-Mar-24

- Frame limiting the enemy AI logic just makes them look herky jerky

### 4-Mar-24

Game:
- Starfield

Play.Date
- Hmm apparently sprite:setRotation is expensive on the hardware!
- Pre-rotated sprites are suggested, which Asperite handles.
- Means I could used fixed rotates which might make things easier...
    - 15 degree increments is what the original Bosconian used, although oddly not for the player ship?
        - 7 tiles which can be reflected in X/Y
        - See playdate.graphics.imagetable
- Also apparently radians are preferred to degrees for video games...
