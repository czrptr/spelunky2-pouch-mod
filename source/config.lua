---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS
---@field is_retrieving boolean
---@field selected_slot integer
---@field retrieval_option RetrievalOption

---@class Player
---@field user_data UserData

---@class Options
---@field pouch_size integer
---@field idols_are_storable boolean
---@field pets_are_storable boolean
---@field mounts_are_storable boolean
---@field monsters_are_storable boolean
---@field player1_retrieval_option RetrievalOption
---@field player2_retrieval_option RetrievalOption
---@field player3_retrieval_option RetrievalOption
---@field player4_retrieval_option RetrievalOption

---@enum RetrievalOption
RETRIEVAL_OPTION = {
  LAST_INSERTED = 1,
  SELECTABLE = 2,
}

---@class PouchConfig
---@field MIN_CAPACITY integer Minimum number of slots allowed in pouch
---@field MAX_CAPACITY integer Maximum number of slots allowed in pouch
---@field DEFAULT_CAPACITY integer Default number of slots in pouch
local POUCH_CONFIG <const> = {
  MIN_CAPACITY = 1,
  MAX_CAPACITY = 7,
  DEFAULT_CAPACITY = 2,
}

-- ==============================================================================

---@class AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level

---@class AudioConfig
---@field STORE AudioSoundConfig Configuration for item storage sound effects
---@field INVALID AudioSoundConfig Configuration for invalid action sound effects
local AUDIO_CONFIG <const> = (function()
  local SOUND_STORE <const> = get_sound(VANILLA_SOUND.MOUNTS_MOUNT)
  ---@cast SOUND_STORE CustomSound -- will never be nil
  local SOUND_INVALID <const> = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)
  ---@cast SOUND_INVALID CustomSound -- will never be nil

  return {
    STORE = {
      SOUND = SOUND_STORE,
      PITCH = 1.1,
      VOLUME = 1.2,
    },
    INVALID = {
      SOUND = SOUND_INVALID,
      PITCH = 1.3,
      VOLUME = 0.775,
    }
  }
end)()

-- ==============================================================================

---@alias StorableEntityMap table<ENT_TYPE, boolean>

---Items that can always be stored in the pouch
---@type StorableEntityMap
local STORABLE_ALWAYS <const> = {
  -- Weapons
  [ENT_TYPE.ITEM_WEBGUN] = true,
  [ENT_TYPE.ITEM_SHOTGUN] = true,
  [ENT_TYPE.ITEM_FREEZERAY] = true,
  [ENT_TYPE.ITEM_PLASMACANNON] = true,
  [ENT_TYPE.ITEM_CLONEGUN] = true,
  [ENT_TYPE.ITEM_CROSSBOW] = true,
  [ENT_TYPE.ITEM_CAMERA] = true,
  [ENT_TYPE.ITEM_TELEPORTER] = true,
  [ENT_TYPE.ITEM_HOUYIBOW] = true,

  -- Melee weapons
  [ENT_TYPE.ITEM_MATTOCK] = true,
  [ENT_TYPE.ITEM_BROKEN_MATTOCK] = true,
  [ENT_TYPE.ITEM_MACHETE] = true,
  [ENT_TYPE.ITEM_BOOMERANG] = true,
  [ENT_TYPE.ITEM_SCEPTER] = true,
  [ENT_TYPE.ITEM_EXCALIBUR] = true,
  [ENT_TYPE.ITEM_BROKENEXCALIBUR] = true,

  -- Shields
  [ENT_TYPE.ITEM_WOODEN_SHIELD] = true,
  [ENT_TYPE.ITEM_METAL_SHIELD] = true,

  -- Backpacks
  [ENT_TYPE.ITEM_CAPE] = true,
  [ENT_TYPE.ITEM_VLADS_CAPE] = true,
  [ENT_TYPE.ITEM_JETPACK] = true,
  [ENT_TYPE.ITEM_HOVERPACK] = true,
  [ENT_TYPE.ITEM_TELEPORTER_BACKPACK] = true,
  [ENT_TYPE.ITEM_POWERPACK] = true,

  -- Projectiles
  [ENT_TYPE.ITEM_WOODEN_ARROW] = true,
  [ENT_TYPE.ITEM_BROKEN_ARROW] = true,
  [ENT_TYPE.ITEM_LIGHT_ARROW] = true,
  [ENT_TYPE.ITEM_METAL_ARROW] = true,

  -- Keys
  [ENT_TYPE.ITEM_KEY] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST_KEY] = true,

  -- Containers
  [ENT_TYPE.ITEM_CRATE] = true,
  [ENT_TYPE.ITEM_CHEST] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST] = true,
  [ENT_TYPE.ITEM_POT] = true,
  [ENT_TYPE.ITEM_POTOFGOLD] = true,
  [ENT_TYPE.ITEM_VAULTCHEST] = true,
  [ENT_TYPE.ITEM_LAVAPOT] = true,
  [ENT_TYPE.ITEM_PRESENT] = true,

  -- Miscellaneous items
  [ENT_TYPE.ITEM_ROCK] = true,
  [ENT_TYPE.ITEM_SKULL] = true,
  [ENT_TYPE.ITEM_DIE] = true,
  [ENT_TYPE.ITEM_TORCH] = true,
  [ENT_TYPE.ITEM_EGGPLANT] = true,
  [ENT_TYPE.ITEM_CRABMAN_CLAW] = true,

  -- Critters (easter egg)
  [ENT_TYPE.MONS_CRITTERSNAIL] = true,
  [ENT_TYPE.MONS_CRITTERDUNGBEETLE] = true,
  [ENT_TYPE.MONS_CRITTERBUTTERFLY] = true,
  [ENT_TYPE.MONS_CRITTERFISH] = true,
  [ENT_TYPE.MONS_CRITTERCRAB] = true,
  [ENT_TYPE.MONS_CRITTERLOCUST] = true,
  [ENT_TYPE.MONS_CRITTERPENGUIN] = true,
  [ENT_TYPE.MONS_CRITTERFIREFLY] = true,
  [ENT_TYPE.MONS_CRITTERDRONE] = true,
  [ENT_TYPE.MONS_CRITTERSLIME] = true,
  [ENT_TYPE.MONS_CRITTERANCHOVY] = true,
}

---Idols that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_IDOLS <const> = {
  [ENT_TYPE.ITEM_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOLNOTE] = true,
  [ENT_TYPE.ITEM_USHABTI] = true,
}

---Pets that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_PETS <const> = {
  [ENT_TYPE.MONS_PET_DOG] = true,
  [ENT_TYPE.MONS_PET_CAT] = true,
  [ENT_TYPE.MONS_PET_HAMSTER] = true,
}

---Mounts that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_MOUNTS <const> = {
  [ENT_TYPE.MOUNT_TURKEY] = true,
  [ENT_TYPE.MOUNT_ROCKDOG] = true,
  [ENT_TYPE.MOUNT_AXOLOTL] = true,
  [ENT_TYPE.MOUNT_QILIN] = true,
}

---@class StorableConfig
---@field ALWAYS StorableEntityMap Items that can always be stored
---@field IDOLS StorableEntityMap Idols that can be stored
---@field PETS StorableEntityMap Pets that can be stored
---@field MOUNTS StorableEntityMap Mounts that can be stored
local STORABLE_CONFIG <const> = {
  ALWAYS = STORABLE_ALWAYS,
  IDOLS = STORABLE_IDOLS,
  PETS = STORABLE_PETS,
  MOUNTS = STORABLE_MOUNTS,
}

---@enum PlayerBehavior
local PLAYER_HEHAVIOR <const> = {
  CLIMBING = 6,
}

---@class Behavior
local BEHAVIOR <const> = {
  PLAYER = PLAYER_HEHAVIOR
}

---@class PouchInputs
local POUCH_INPUTS <const> = {
  ---@class OnGround
  ON_GROUND = {
    STORE_OR_RETRIEVE = INPUT_FLAG.UP,
    ROTATE = INPUT_FLAG.DOWN,
  },
  ---@class WhileClimbing
  WHILE_CLIMBING = {
    STORE_OR_RETRIEVE = INPUT_FLAG.LEFT,
    ROTATE = INPUT_FLAG.RIGHT,
  },
}

-- ==============================================================================

---@class Config
---@field POUCH PouchConfig Pouch capacity and behavior settings
---@field AUDIO AudioConfig Sound effect configurations
---@field STORABLE StorableConfig Entity types that can be stored in pouch
---@field INPUTS PouchInputs Input configurations for interacting with the pouch
local CONFIG <const> = {
  POUCH = POUCH_CONFIG,
  AUDIO = AUDIO_CONFIG,
  STORABLE = STORABLE_CONFIG,
  BEHAVIOR = BEHAVIOR,
  INPUTS = POUCH_INPUTS,
  RETRIEVAL_OPTION = RETRIEVAL_OPTION
}

return CONFIG
