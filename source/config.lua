---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS
---@field can_enter_a_door boolean
---@field retrieval_option RetrievalOption
---@field is_retrieving boolean
---@field selected_slot integer

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

-- forced by the engine
local ASPECT_RATIO <const> = 16 / 9

---@param texture_path string Path to texture file
---@param width integer Texture width in pixels
---@param height integer Texture height in pixels
---@return TEXTURE
local function create_texture(texture_path, width, height)
  local texture_def = TextureDefinition.new()
  texture_def.texture_path = texture_path
  texture_def.width = width
  texture_def.height = height
  texture_def.tile_width = width
  texture_def.tile_height = height
  return define_texture(texture_def)
end

---@param width number Screen-space width
---@param texture_aspect_ratio number Width/height ratio of texture
---@return number height Screen-space height
local function screen_height(width, texture_aspect_ratio)
  return width / texture_aspect_ratio * ASPECT_RATIO
end

-- Slot Configuration
---@class UiSlotConfig
---@field BASE_X number Screen-space X coordinate for first slot of first player
---@field BASE_Y number Screen-space Y coordinate for pouch UI elements
---@field PLAYER_STRIDE number Screen-space horizontal offset between different players' pouches
---@field WIDTH number Screen-space width of each pouch slot
---@field HEIGHT number Screen-space height of each pouch slot
---@field MARGIN number Screen-space margin between adjacent slots
---@field BACKGROUND_ALPHA number Transparency level for slot background rendering
---@field ICON_ALPHA number Transparency level for slot icon rendering
---@field SELECTED_ICON_ALPHA number Transparency level for selected slot icon rendering
---@field ICON_ZOOM_X number Zoom factor for icon size relative to background (x-axis)
---@field ICON_ZOOM_Y number Zoom factor for icon size relative to background (y-axis)
---@field TEXTURE TEXTURE Texture used for rendering empty slot backgrounds
local UI_SLOT_CONFIG <const> = (function()
  local TEXTURE_WIDTH = 100
  local TEXTURE_HEIGHT = 100
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.035
  local ICON_ZOOM_X = 0.008

  return {
    BASE_X = -0.9625,
    BASE_Y = 0.67,
    PLAYER_STRIDE = 0.32,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    MARGIN = 0.0035,
    BACKGROUND_ALPHA = 0.35,
    ICON_ALPHA = 0.5,
    SELECTED_ICON_ALPHA = 0.75,
    ICON_ZOOM_X = ICON_ZOOM_X,
    ICON_ZOOM_Y = ICON_ZOOM_X * ASPECT_RATIO,
    TEXTURE = create_texture("slot.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
  }
end)()

---@class UiPouchConfig
---@field BASE_X number Screen-space X coordinate for pouch of first player
---@field BASE_Y number Screen-space Y coordinate for pouch of first player
---@field PLAYER_STRIDE number Screen-space horizontal offset between different players' pouches
---@field WIDTH number Screen-space width of each pouch
---@field HEIGHT number Screen-space height of each pouch
---@field TEXTURE TEXTURE Texture used for rendering pouch
local UI_POUCH_CONFIG <const> = (function()
  local TEXTURE_WIDTH = 251
  local TEXTURE_HEIGHT = 233
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.07

  return {
    BASE_X = -0.89,
    BASE_Y = -0.98,
    PLAYER_STRIDE = 0.32,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    TEXTURE = create_texture("pouch.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
  }
end)()

---@class UiSlotPosition
---@field X number Relative X position
---@field Y number Relative Y position

---@class UiBackgroundConfig
---@field BASE_X number Screen-space X coordinate for background of first player
---@field BASE_Y number Screen-space Y coordinate for background of first player
---@field WIDTH number Screen-space width of background
---@field HEIGHT number Screen-space height of background
---@field TEXTURE TEXTURE Texture used for rendering background
---@field SLOT_POSITIONS UiSlotPosition[] Relative positions of slots within background
local UI_BACKGROUND_CONFIG <const> = (function()
  local TEXTURE_WIDTH = 313
  local TEXTURE_HEIGHT = 157
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT

  local WIDTH = 0.233

  return {
    BASE_X = UI_POUCH_CONFIG.BASE_X + 0.005,
    BASE_Y = UI_POUCH_CONFIG.BASE_Y + 0.02,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    TEXTURE = create_texture("background.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
    SLOT_POSITIONS = {
      { X = 0.025, Y = 0.113 },
      { X = 0.075, Y = 0.028 },
      { X = 0.075, Y = 0.113 },
      { X = 0.125, Y = 0.028 },
      { X = 0.125, Y = 0.113 },
      { X = 0.175, Y = 0.028 },
      { X = 0.175, Y = 0.113 },
    },
  }
end)()

---@class UiConfig
---@field ASPECT_RATIO number Screen aspect ratio used for UI calculations
---@field SLOT UiSlotConfig Configuration for individual pouch slots
---@field POUCH UiPouchConfig Configuration for pouch container
---@field BACKGROUND UiBackgroundConfig Configuration for background display
local UI_CONFIG <const> = {
  ASPECT_RATIO = ASPECT_RATIO,
  SLOT = UI_SLOT_CONFIG,
  POUCH = UI_POUCH_CONFIG,
  BACKGROUND = UI_BACKGROUND_CONFIG,
}

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
---@field UI UiConfig User interface layout and rendering settings
---@field STORABLE StorableConfig Entity types that can be stored in pouch
---@field INPUTS PouchInputs Input configurations for interacting with the pouch
local CONFIG <const> = {
  POUCH = POUCH_CONFIG,
  AUDIO = AUDIO_CONFIG,
  UI = UI_CONFIG,
  STORABLE = STORABLE_CONFIG,
  BEHAVIOR = BEHAVIOR,
  INPUTS = POUCH_INPUTS,
  RETRIEVAL_OPTION = RETRIEVAL_OPTION
}

return CONFIG
