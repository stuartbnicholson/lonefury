# TODO:

A good description of the flocking algo: https://www.oreilly.com/library/view/ai-for-game/0596005555/ch04.html

## Limits:

With some simple testing (giving enemy bases 30 bullets to fire), it seems that around 25 sprites on screen is where the FPS starts to drop.
There is a lot of arithmetic going on each update cycle thanks to my (possibly janky) code though. Fairly confident there's optimisations that could be made.
Nice having limits though, forces you to care and get a bit creative.

## World coordinates vs Viewport

- In game every entity needs world coordinates, including the player.
- The Viewport **follows the player's world coordinates** - because of this, the player ship always appears in the middle of the Viewport.

## Game:
- LevelsManager.
- Dashboard
    - Minimap

- States, have been added somewhat.
::: mermaid
graph TD;
    stateMenu-->stateStart;
    stateMenu-->stateCredits;
    stateCredits-->stateMenu;
    stateStart-->stateGame;
    stateGame-->stateNewLevel;
    stateNewLevel-->stateRespawn;
    stateGame-->stateDead;
    stateDead-->stateRespawn;
    stateRespawn-->stateGame;
    stateDead-->stateGameOver;
    stateGameOver-->stateMenu;
:::


## Player
- Multiple bullets

## Enemies
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
