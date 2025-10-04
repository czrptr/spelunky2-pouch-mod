![Pouch Icon](./icon.png)
# Spelunky 2 Pouch Mod

## Description
The Pouch mod introduces a portable item-storage system for Spelunky 2, allowing players to temporarily stash and retrieve carried items. It adds an on-screen pouch HUD visible during gameplay and level transitions.

## Input Map
| Action             | Condition       | Input        |
|--------------------|-----------------|--------------|
| Retrieve or store  | While climbing  | LEFT + DOOR  |
| Retrieve or store  | Otherwise       | UP + DOOR    |
| Rotate contents    | While climbing  | DOWN + DOOR  |
| Rotate contents    | Otherwise       | RIGHT + DOOR |

## Features & Behavior
- Store currently held items into your pouch
- Retrieve the last inserted item when not holding anything
- Rotate pouch contents, moving the last item to the first slot
- All pouch items drop on the ground upon death
- Configurable options:
  - Pouch capacity (default: 2 slots)
  - Allow storing idols (default: false)
  - Allow storing pets (default: false)
  - Allow storing tamed mounts (default: false)
  - Allow storing dead monsters (default: true, includes pets and mounts)
  - Item retrieval method (default: Last inserted)

## Planned Features
- "Selectable" retrieval option for choosing which item to retrieve
- Scalable pouch capacity via in-game items rather than fixed maximum
- Online multiplayer support (compatibility untested)
- Modded item support (requires changes to [Custom Entities Library](https://spelunky.fyi/mods/m/custom-entities-library/))

## Not Planned
- Storing cursed pots
- Storing live monsters, NPCs, or other players

## Changelog

### 1.1
**Added:**
- Separate climbing inputs for better gameplay flow. Use LEFT/RIGHT instead of UP/DOWN when climbing to prevent movement.
- Item rotation: shift last item to first slot (see input map)

**Fixed:**
- Accidental retrieval when passing through any door
- Mole corpses falling through floors after retrieval
- Monsters appearing behind player after retrieval

### 1.0
**Added:**
- Core pouch system: store/retrieve with Up + Door
- Death behavior: items drop from pouch
- Configuration options for capacity and allowed items
- UI: slot grid overlay and transition panel

**Fixed:**
- Accidental retrieval when passing through level exit door

## Contributions
I welcome feedback, feature requests, and bug reports!