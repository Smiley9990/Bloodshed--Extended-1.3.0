**Note:** Much of this gamemode and content was made locally for a private group. Players are encouraged to modify modes, items, and settings to better suit their own servers and preferences.

**⚠️ Redux Incompatible with Bloodshed: Extended** do not use both. Choose one to avoid conflicts.

---

## Links

- __Original:__ [Bloodshed: Redux](https://steamcommunity.com/sharedfiles/filedetails/?id=3508448413) (Steam Workshop)
- __Content:__ [Bloodshed: Extended](https://steamcommunity.com/sharedfiles/filedetails/?id=3647700470) (Steam Workshop)
- __MyProfile:__ [Smiley](https://steamcommunity.com/profiles/76561198103415700/) (Steam)

---

## Key Changes

### New Content
- **New Traitor items** — expanded arsenal for killer-based modes
- **Armor system** — character protection mechanics

### New Modes (50+)

| ID | Mode | Description |
|----|------|-------------|
| 50 | **Legion Battle** | Битва легионеров — massive legionnaire battle |
| 51 | **INFENTIBLE** | Survival against droids |
| 52 | **Scenario with Role Choice** | Режим с выбором стиля игры — Traitor mode with role selection |
| 53 | **Raid on Tagilla** | Рейд на Тагиллу — Tagila vs PMC vs Wilds |
| 54 | **Combine vs Rebels** | Team deathmatch: Combine vs Rebels |
| 55 | **The Hidden** | *Work in progress* — не завершён |
| 56 | **Hotline Miami: Extended** | Extended Hotline Miami — Tony vs Mafia with reinforcements |

---

## Debug Menu (F1 → Debug)

Opened via **F1** → **Debug** tab. SuperAdmin required for spawn tools and Sandbox mode.

### Armor & Hitbox Display
Visualize armor, bones and organ hitboxes on players. Useful for understanding damage mechanics and armor coverage.
- **`mur_armor_debug`** — 0=Off, 1=Armor, 2=Bones, 3=Both, 4=Organs, 5=All
- **`mur_debug_hp`** — show HP numbers (bottom left)

### Spawn Points (SuperAdmin)
Visualize and manage spawn locations. Saves blacklist per map to `data/bloodshed/spawn_blacklist_<map>.json`.

| Option | Description |
|--------|-------------|
| Show all spawn points | `mur_debug_spawns 1` — display all spawn points in world |
| Mode filter | `mur_spawn_debug_mode` — 0 = all, 54 = Combine vs Rebel (color by team) |
| Block (stand on point) | `mur_spawn_debug_blacklist_add` — add current position to blacklist |
| Unblock nearest | `mur_spawn_debug_blacklist_remove` — remove nearest blacklisted point |
| Clear blacklist | `mur_spawn_debug_blacklist_clear` |
| Refresh | Reload spawn points |

---

## Map Setup Commands

### Hotline Miami: Extended (Mode 56)
Reinforcement spawn points:
```
mur_mode56_reinforcementspawn              Add current position as reinforcement spawn
mur_mode56_reinforcementspawn clear        Remove all reinforcement spawn points
```

### Combine vs Rebels (Mode 54)
Team spawn points:
```
mur_mode54_spawn combine   Add current position as Combine spawn
mur_mode54_spawn rebel     Add current position as Rebel spawn
mur_mode54_spawn list      Show saved spawn count for current map
mur_mode54_spawn clear     Remove all spawn points for current map
```

---

## Installation

Extract to:
- **Client:** `garrysmod/gamemodes/bloodshed/`
- **Dedicated server:** `srcds/orangebox/garrysmod/gamemodes/bloodshed/`

---

## Development Status

- **The Hidden** (Mode 55) — incomplete, work in progress maybe.....

---
