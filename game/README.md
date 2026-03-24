# Bloons TD5 - Roblox Edition

A faithful recreation of Bloons Tower Defense 5 for Roblox.

## Game Features

### Bloon Types (14 total)
| Bloon | Speed | HP | Children |
|-------|-------|----|----------|
| Red | 25 | 1 | - |
| Blue | 30 | 1 | Red |
| Green | 35 | 1 | Blue |
| Yellow | 53 | 1 | Green |
| Pink | 68 | 1 | Yellow |
| Black | 40 | 1 | Pink x2 (explosion immune) |
| White | 45 | 1 | Pink x2 (freeze immune) |
| Lead | 23 | 1 | Black x2 (sharp immune) |
| Zebra | 40 | 1 | Black + White |
| Rainbow | 55 | 1 | Zebra x2 |
| Ceramic | 25 | 10 | Rainbow x2 |
| M.O.A.B. | 10 | 200 | Ceramic x4 |
| B.F.B. | 6 | 700 | MOAB x4 |
| Z.O.M.G. | 3.25 | 4000 | BFB x4 |

### Towers (16 total)
1. **Dart Monkey** ($170) - Basic tower, fast attack
2. **Tack Shooter** ($230) - Shoots 8 directions
3. **Sniper Monkey** ($350) - Infinite range, precise shots
4. **Boomerang Thrower** ($325) - High pierce arc shots
5. **Ninja Monkey** ($425) - Fast, detects camo
6. **Bomb Tower** ($550) - Explosive area damage
7. **Ice Tower** ($340) - Freezes bloons in range
8. **Glue Gunner** ($275) - Slows bloons
9. **Monkey Buccaneer** ($425) - Water placement, boat
10. **Monkey Ace** ($875) - Plane that circles and drops darts
11. **Super Monkey** ($3000) - Extremely powerful laser
12. **Mortar Tower** ($700) - Manual aim, area damage
13. **Dartling Gun** ($1700) - Cursor-aimed rapid fire
14. **Spike Factory** ($850) - Drops spikes on path
15. **Monkey Village** ($1200) - Support buffs for nearby towers
16. **Engineer Monkey** ($475) - Sentry guns, special abilities

### Each tower has 2 upgrade paths with 4 upgrades each (BTD5 system)

### Rounds
- **85 main rounds** with escalating difficulty
- **Freeplay** after round 85 (infinite)
- Round 38: First MOAB
- Round 50: First BFB
- Round 70: First ZOMG
- Round 66: Camo ceramics wave

## Setup in Roblox Studio

### File Structure
Place the scripts in these Roblox service locations:

```
ReplicatedStorage/
  Shared/
    Config (ModuleScript)       <- game/shared/Config.lua
    BloonData (ModuleScript)    <- game/shared/BloonData.lua
    TowerData (ModuleScript)    <- game/shared/TowerData.lua
    WaveData (ModuleScript)     <- game/shared/WaveData.lua

ServerScriptService/
  GameManager (Script)          <- game/server/GameManager.server.lua
  BloonManager (ModuleScript)   <- game/server/BloonManager.server.lua
  TowerManager (ModuleScript)   <- game/server/TowerManager.server.lua
  WaveManager (ModuleScript)    <- game/server/WaveManager.server.lua

StarterPlayer/
  StarterPlayerScripts/
    GameClient (LocalScript)    <- game/client/GameClient.client.lua
    UIManager (ModuleScript)    <- game/client/UIManager.client.lua
    TowerPlacer (ModuleScript)  <- game/client/TowerPlacer.client.lua
```

### Steps:
1. Open Roblox Studio → Create New Place
2. Set `Workspace.StreamingEnabled = false`
3. Create the folder structure above in the Explorer
4. Copy each `.lua` file content into the corresponding script
5. Set game gravity: `Workspace.Gravity = 0` (bloons float)
6. Publish the game

## Controls

| Action | Control |
|--------|---------|
| Select tower | Click tower button (right panel) |
| Place tower | Left click on green area |
| Cancel placement | Escape |
| Select placed tower | Click on it |
| Start round | Click START or press Space |
| Fast forward | Click ⏩ x2 button |
| Sell tower | Select tower → SELL |

## Game Rules
- Start with **$650 cash** and **200 lives**
- Earn **$1 per bloon popped**
- Earn **round bonus cash** at end of each round
- Lose lives = bloon's **RBE value** (Red Bloon Equivalent)
- Beat **round 85** to win
- 0 lives = Game Over

## Architecture

### Server-Side
- `GameManager` - Main game loop, coordinates all systems
- `BloonManager` - Bloon spawning, movement along waypoints, damage
- `TowerManager` - Tower placement, targeting, attacking, upgrades
- `WaveManager` - Round/wave data and spawn scheduling

### Client-Side
- `GameClient` - Connects UI to server via RemoteEvents
- `UIManager` - Full HUD: lives, cash, round counter, tower shop, upgrades
- `TowerPlacer` - Mouse-based tower placement with preview and range circle
