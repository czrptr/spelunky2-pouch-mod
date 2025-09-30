![Pouch Icon](./icon.png)
# Spelunky 2 Pouch Mod

## Description
The Pouch mod introduces a portable item-storage system for Spelunky 2, allowing players to temporarily stash, and later retrieve, items they are carrying. It adds an on-screen pouch HUD visible during gameplay and level transitions.

Features & Behavior:
- Players can store the item they’re currently holding (if any) into their pouch by pressing the Up + Door.
- When not holding an item, the same input combo (Up + Door) will retrieve the last inserted item from the pouch, placing it back into the player’s hand (if possible).
- Players drop the contents of the pouch onto the ground upon death.
- Pouches can be configured using the following options:
  - Pouch capacity (2 by default)
  - Idols can be stored (false by default)
  - Pets can be stored (false by default)
  - Mounts can be stored after they are tamed (false by default)
  - Monsters can be stored after they are killed (true by default, includes pets and mounts)

Planned features:
- Add more option for item retrieval such as Select, First-in First-out (currently only Last-in First-out)
- Change the pouch capacity from a fixed maximum that a applies to all players to a player specific stat which can be increased with an item (via item pools).
- Online multiplayer support (I haven't tested it online so maybe it works already, let me know 😅)

Explicitly not planned features:
- Being able to store the cursed pot
- Being able to store live monsters, NPCs or other players

## Changelog

### 1.0 - Initial release

Added:
- Base pouch system: players can store and retrieve items via input (Up + Door), items drop upon death
- Options: Configurable pouch capacity and item acceptance
- UI: slot grid overlay during levels and pouch panel during transition

Fixed:
- Prevent retrieval when passing through a door (to avoid losing items)

## Contributions

I am open to feedback, feature requests and bug reports.