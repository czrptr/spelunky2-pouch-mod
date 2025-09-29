-- TODO: Crop textures to content and take their aspect ratio into account

---@class PouchConfig
---@field MIN_CAPACITY integer Minimum number of slots allowed in pouch
---@field MAX_CAPACITY integer Maximum number of slots allowed in pouch
---@field DEFAULT_CAPACITY integer Default number of slots in pouch
local POUCH_CONFIG<const> = {
  MIN_CAPACITY = 1,
  MAX_CAPACITY = 7,
  DEFAULT_CAPACITY = 2,
}

local SOUND_STORE<const> = get_sound(VANILLA_SOUND.MOUNTS_MOUNT)
---@cast SOUND_STORE CustomSound -- will never be nil
local SOUND_INVALID<const> = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)
---@cast SOUND_INVALID CustomSound -- will never be nil

---@class AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level

---@class AudioStoreConfig : AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level
local AUDIO_STORE_CONFIG<const> = {
  SOUND = SOUND_STORE,
  PITCH = 1.1,
  VOLUME = 1.2,
}

---@class AudioInvalidConfig : AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level
local AUDIO_INVALID_CONFIG<const> = {
  SOUND = SOUND_INVALID,
  PITCH = 1.3,
  VOLUME = 0.775,
}

---@class AudioConfig
---@field STORE AudioStoreConfig Configuration for item storage sound effects
---@field INVALID AudioInvalidConfig Configuration for invalid action sound effects
local AUDIO_CONFIG<const> = {
  STORE = AUDIO_STORE_CONFIG,
  INVALID = AUDIO_INVALID_CONFIG
}

-- forced by the engine
local ASPECT_RATIO<const> = 16 / 9

---@class UiSlotConfig
---@field BASE_X number Screen-space X coordinate for first slot of first player
---@field BASE_Y number Screen-space Y coordinate for pouch UI elements
---@field PLAYER_STRIDE number Screen-space horizontal offset between different players' pouches
---@field WIDTH number Screen-space width of each pouch slot
---@field HEIGHT number Screen-space height of each pouch slot (calculated from width and aspect ratio)
---@field MARGIN number Screen-space margin between adjacent slots
---@field BACKGROUND_ALPHA number Transparency level for slot background rendering
---@field ICON_ALPHA number Transparency level for slot icon rendering
---@field ICON_ZOOM_X TEXTURE Zoom factor used to calculated icon sized relative to background size (x-axis)
---@field ICON_ZOOM_Y TEXTURE Zoom factor used to calculated icon sized relative to background size (y-axis)
---@field TEXTURE TEXTURE Texture used for rendering empty slot backgrounds
local UI_SLOT_CONFIG<const> = {
  BASE_X = -0.9625,
  BASE_Y = 0.67,
  PLAYER_STRIDE = 0.32,
  WIDTH = 0.035,
  MARGIN = 0.0035,
  BACKGROUND_ALPHA = 0.35,
  ICON_ALPHA = 0.5,
  ICON_ZOOM_X = 0.008
}
do
  -- actual size is 23 but having this be larger makes the texture
  -- look rounder for some reason (maybe I'm imagining it)
  local TEXTURE_SIZE = 100

  local texture_def = TextureDefinition.new()
  texture_def.texture_path = 'slot.png'
  texture_def.width = TEXTURE_SIZE
  texture_def.height = TEXTURE_SIZE
  texture_def.tile_width = TEXTURE_SIZE
  texture_def.tile_height = TEXTURE_SIZE

  UI_SLOT_CONFIG.HEIGHT = UI_SLOT_CONFIG.WIDTH * ASPECT_RATIO
  UI_SLOT_CONFIG.ICON_ZOOM_Y = UI_SLOT_CONFIG.ICON_ZOOM_X * ASPECT_RATIO
  UI_SLOT_CONFIG.TEXTURE = define_texture(texture_def)
end

---@class UiPouchDisplay
---@field ROPE integer Display a rope
---@field HANGING_1 integer Display player hanging with legs down
---@field HANGING_2 integer Display player hanging with legs to the side
local UI_POUCH_DISPLAY<const> = {
  ROPE = 0,
  HANGING_1 = 1,
  HANGING_2 = 2,
}

---@class UiPouchConfig
---@field BASE_X number Screen-space X coordinate for pouch of first player
---@field BASE_Y number Screen-space Y coordinate for pouch of first player
---@field PLAYER_STRIDE number Screen-space horizontal offset between different players' pouches
---@field WIDTH number Screen-space width of each pouch
---@field HEIGHT number Screen-space height of each pouch (calculated from width and aspect ratio)
---@field TEXTURE TEXTURE Texture used for rendering empty slot backgrounds
---@field DISPLAY UiPouchDisplay How the pouch will be displayed
local UI_POUCH_CONFIG<const> = {
  BASE_X = -0.89,
  BASE_Y = -0.98,
  PLAYER_STRIDE = 0.32,
  WIDTH = 0.07,
  DISPLAY = UI_POUCH_DISPLAY
}
do
  local TEXTURE_SIZE = 256

  local texture_def = TextureDefinition.new()
  texture_def.texture_path = 'pouch.png'
  texture_def.width = TEXTURE_SIZE
  texture_def.height = TEXTURE_SIZE
  texture_def.tile_width = TEXTURE_SIZE
  texture_def.tile_height = TEXTURE_SIZE

  UI_POUCH_CONFIG.HEIGHT = UI_POUCH_CONFIG.WIDTH * ASPECT_RATIO
  UI_POUCH_CONFIG.TEXTURE = define_texture(texture_def)
end

---@class UiBackgroundConfig
---@field BASE_X number Screen-space X coordinate for background of first player
---@field BASE_Y number Screen-space Y coordinate for background of first player
---@field WIDTH number Screen-space width of each pouch
---@field HEIGHT number Screen-space height of each pouch (calculated from width and aspect ratio)
---@field TEXTURE TEXTURE Texture used for rendering empty slot backgrounds
---@field DISPLAY UiPouchDisplay How the pouch will be displayed
local UI_BACKGROUND_CONFIG<const> = {
  BASE_X = UI_POUCH_CONFIG.BASE_X + 0.005,
  BASE_Y = UI_POUCH_CONFIG.BASE_Y - 0.18,
  WIDTH = 0.233,
}
do
  local TEXTURE_SIZE = 313

  local texture_def = TextureDefinition.new()
  texture_def.texture_path = 'background.png'
  texture_def.width = TEXTURE_SIZE
  texture_def.height = TEXTURE_SIZE
  texture_def.tile_width = TEXTURE_SIZE
  texture_def.tile_height = TEXTURE_SIZE

  UI_BACKGROUND_CONFIG.HEIGHT = UI_BACKGROUND_CONFIG.WIDTH * ASPECT_RATIO
  UI_BACKGROUND_CONFIG.TEXTURE = define_texture(texture_def)
end

---@class UiConfig
---@field ASPECT_RATIO number Screen aspect ratio used for UI calculations
---@field SLOT UiSlotConfig Configuration specific to individual pouch slots
---@field POUCH UiPouchConfig Configuration specific to individual pouchs
---@field BACKGROUND UiBackgroundConfig Configuration specific to individual backgrounds
local UI_CONFIG<const> = {
  ASPECT_RATIO = ASPECT_RATIO,
  SLOT = UI_SLOT_CONFIG,
  POUCH = UI_POUCH_CONFIG,
  BACKGROUND = UI_BACKGROUND_CONFIG,
}

local STORABLE_ALWAYS<const> = {
  [ENT_TYPE.ITEM_ROCK] = true,
  [ENT_TYPE.ITEM_SKULL] = true,
  [ENT_TYPE.ITEM_DIE] = true,
  [ENT_TYPE.ITEM_TELEPORTER] = true,
  [ENT_TYPE.ITEM_WEBGUN] = true,
  [ENT_TYPE.ITEM_SHOTGUN] = true,
  [ENT_TYPE.ITEM_FREEZERAY] = true,
  [ENT_TYPE.ITEM_PLASMACANNON] = true,
  [ENT_TYPE.ITEM_WOODEN_SHIELD] = true,
  [ENT_TYPE.ITEM_MATTOCK] = true,
  [ENT_TYPE.ITEM_BROKEN_MATTOCK] = true,
  [ENT_TYPE.ITEM_CLONEGUN] = true,
  [ENT_TYPE.ITEM_METAL_SHIELD] = true,
  [ENT_TYPE.ITEM_MACHETE] = true,
  [ENT_TYPE.ITEM_BOOMERANG] = true,
  [ENT_TYPE.ITEM_CAMERA] = true,
  [ENT_TYPE.ITEM_HOUYIBOW] = true,
  [ENT_TYPE.ITEM_CROSSBOW] = true,
  [ENT_TYPE.ITEM_SCEPTER] = true,
  [ENT_TYPE.ITEM_EXCALIBUR] = true,
  [ENT_TYPE.ITEM_BROKENEXCALIBUR] = true,
  [ENT_TYPE.ITEM_CAPE] = true,
  [ENT_TYPE.ITEM_VLADS_CAPE] = true,
  [ENT_TYPE.ITEM_JETPACK] = true,
  [ENT_TYPE.ITEM_HOVERPACK] = true,
  [ENT_TYPE.ITEM_TELEPORTER_BACKPACK] = true,
  [ENT_TYPE.ITEM_POWERPACK] = true,
  [ENT_TYPE.ITEM_TORCH] = true,
  [ENT_TYPE.ITEM_WOODEN_ARROW] = true,
  [ENT_TYPE.ITEM_BROKEN_ARROW] = true,
  [ENT_TYPE.ITEM_LIGHT_ARROW] = true,
  [ENT_TYPE.ITEM_METAL_ARROW] = true,
  [ENT_TYPE.ITEM_KEY] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST_KEY] = true,
  [ENT_TYPE.ITEM_EGGPLANT] = true,
  [ENT_TYPE.ITEM_CRATE] = true,
  [ENT_TYPE.ITEM_CHEST] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST] = true,
  [ENT_TYPE.ITEM_POT] = true,
  [ENT_TYPE.ITEM_POTOFGOLD] = true,
  [ENT_TYPE.ITEM_VAULTCHEST] = true,
  [ENT_TYPE.ITEM_LAVAPOT] = true,
  [ENT_TYPE.ITEM_PRESENT] = true,
  [ENT_TYPE.ITEM_CRABMAN_CLAW] = true,
  -- critters storable as easter egg
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
  [ENT_TYPE.MONS_CRITTERANCHOVY] = true
}
---@alias STORABLE_ALWAYS table<ENT_TYPE, boolean>

local STORABLE_IDOLS<const> = {
  [ENT_TYPE.ITEM_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOLNOTE] = true,
  [ENT_TYPE.ITEM_USHABTI] = true,
}
---@alias STORABLE_IDOLS table<ENT_TYPE, boolean>

local STORABLE_PETS<const> = {
  [ENT_TYPE.MONS_PET_DOG] = true,
  [ENT_TYPE.MONS_PET_CAT] = true,
  [ENT_TYPE.MONS_PET_HAMSTER] = true,
}
---@alias STORABLE_PETS table<ENT_TYPE, boolean>

local STORABLE_MOUNTS<const> = {
  [ENT_TYPE.MOUNT_TURKEY] = true,
  [ENT_TYPE.MOUNT_ROCKDOG] = true,
  [ENT_TYPE.MOUNT_AXOLOTL] = true,
  [ENT_TYPE.MOUNT_QILIN] = true,
}
---@alias STORABLE_MOUNTS table<ENT_TYPE, boolean>

---@class Storable
---@field ALWAYS STORABLE_ALWAYS
---@field IDOLS STORABLE_IDOLS
---@field PETS STORABLE_PETS
---@field MOUNTS STORABLE_MOUNTS
local STORABLE<const> = {
  ALWAYS = STORABLE_ALWAYS,
  IDOLS = STORABLE_IDOLS,
  PETS = STORABLE_PETS,
  MOUNTS = STORABLE_MOUNTS,
}

---@class Config
---@field POUCH PouchConfig Pouch capacity and behavior settings
---@field AUDIO AudioConfig Sound effect configurations
---@field UI UiConfig User interface layout and rendering settings
---@field STORABLE Storable Lookup table used to check if entities are storable
local CONFIG<const> = {
  POUCH = POUCH_CONFIG,
  AUDIO = AUDIO_CONFIG,
  UI = UI_CONFIG,
  STORABLE = STORABLE,
}

return CONFIG