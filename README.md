![Pouch Icon](./icon.png)
# Spelunky 2 - Pouch

The "Pouch" mod introduces a portable item-storage system, allowing players to temporarily stash and retrieve carried items. It adds an on-screen pouch HUD visible during gameplay and level transitions.

## Input Map

### Last Inserted Mode
| Action             | Condition       | Input                |
|--------------------|-----------------|----------------------|
| Retrieve or store  | On ground       | **UP** + **DOOR**    |
| Retrieve or store  | While climbing  | **LEFT** + **DOOR**  |
| Rotate contents    | On ground       | **RIGHT** + **DOOR** |
| Rotate contents    | While climbing  | **DOWN** + **DOOR**  |

### Selectable Mode
| Action                 | Condition      | Input                |
|------------------------|----------------|----------------------|
| Retrieve menu or store | On ground      | **UP** + **DOOR**    |
| Retrieve menu or store | While climbing | **LEFT** + **DOOR**  |
| Rotate contents        | On ground      | **RIGHT** + **DOOR** |
| Rotate contents        | While climbing | **DOWN** + **DOOR**  |
| Navigate slots         | Retrieve menu  | **LEFT** / **RIGHT** |
| Confirm retrieval      | Retrieve menu  | **DOOR**             |
| Cancel selection       | Retrieve menu  | **DOWN**             |

## Features
- Store the currently held item into your pouch
- Retrieve items from your pouch
  - **Last Inserted mode:** retrieve the item that was inserted last (last-in, first-out)
  - **Selectable mode:** choose which slot you want to retrieve from
- Rotate pouch contents, moving the last item to the first slot
- All pouch items drop on the ground upon death
- Configurable options:
  - Pouch capacity (default: 2 slots; min: 1, max: 7)
  - Allow storing idols (default: false)
  - Allow storing pets (default: false)
  - Allow storing tamed mounts (default: false)
  - Allow storing dead monsters (default: true, includes pets and mounts)
  - Item retrieval method (default: "Last Inserted"; other option: "Selectable"; per player)

### Planned
- Une left trigger and shoulder buttons as inputs on controllers (unused in the base game)
- **Online multiplayer support** (compatibility untested; let me know if it works)
- Scalable pouch capacity via in-game items rather than a fixed maximum
- Modded item support (requires changes to the [Custom Entities Library](https://spelunky.fyi/mods/m/custom-entities-library/))

### Not Planned
- Storing cursed pots
- Storing live monsters, NPCs, or other players

## Changelog

### 2.2
- **Added:**
  - Storing an item when while the pouch is full will swap the held item with the first item currently stored
  - Shop items can be stored
  - When unequipping a cape or pack the item will be placed into the players hand (so that they can store it if they want to)
- **Fixed:**
  - Items behaved weirdly when stored and retrieved between layers

### 2.1
- **Fixed:**
  - Functionality didn't work for players who died and respawned

### 2.0
- **Added:**
  - Total internal rework and cleanup
  - Player corpses cannot be stored
  - When retrieving, highlight the slots above the player character
  - Guard against invalid user options (e.g. setting the capacity to something greater than the maximum allowed)
- **Fixed:**
  - Screen shaking when storing a container (e.g. crate) that contains bombs
  - When using "Selectable" retrieval, trying to select the previous slot would select the next slot

### 1.2
- **Added:**
  - "Selectable" retrieve method: choose the slot you want to retrieve from
  - Sound effect when a pouch action is impossible (e.g., retrieving when empty, storing when full)
- **Fixed:**
  - Crash caused by accidental retrieval prevention check

### 1.1
- **Added:**
  - Separate climbing inputs for better gameplay flow. Use LEFT/RIGHT instead of UP/DOWN when climbing to prevent movement.
  - Item rotation: shift the last item to the first slot (see Input Map)
- **Fixed:**
  - Accidental retrieval when passing through doors
  - Mole corpses falling through floors after retrieval
  - Monsters appearing behind the player after retrieval

### 1.0
- **Added:**
  - Core pouch system: store/retrieve with UP + DOOR
  - Death behavior: items drop from pouch
  - Configuration options for capacity and allowed items
  - UI: slot grid overlay and transition panel
- **Fixed:**
  - Accidental retrieval when passing through level exit doors

## Contributions
I welcome feedback, feature requests, and bug reports!
