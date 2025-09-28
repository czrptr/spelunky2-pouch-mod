-- TODO: read and store from file for persistance

---@class PouchConfig
---@field MIN_CAPACITY integer Minimum number of slots allowed in pouch
---@field MAX_CAPACITY integer Maximum number of slots allowed in pouch
---@field DEFAULT_CAPACITY integer Default number of slots in pouch
local POUCH_CONFIG = {
  MIN_CAPACITY = 1,
  MAX_CAPACITY = 7,
  DEFAULT_CAPACITY = 2,
}

local SOUND_STORE = get_sound(VANILLA_SOUND.MOUNTS_MOUNT)
---@cast SOUND_STORE CustomSound -- will never be nil
local SOUND_INVALID = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)
---@cast SOUND_INVALID CustomSound -- will never be nil


---@class AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level

---@class AudioStoreConfig : AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level
local AUDIO_STORE_CONFIG = {
  SOUND = SOUND_STORE,
  PITCH = 1.1,
  VOLUME = 1.2,
}

---@class AudioInvalidConfig : AudioSoundConfig
---@field SOUND CustomSound Sound effect
---@field PITCH number Pitch multiplier
---@field VOLUME number Volume level
local AUDIO_INVALID_CONFIG = {
  SOUND = SOUND_INVALID,
  PITCH = 1.3,
  VOLUME = 0.775,
}

---@class AudioConfig
---@field STORE AudioStoreConfig Configuration for item storage sound effects
---@field INVALID AudioInvalidConfig Configuration for invalid action sound effects
local AUDIO_CONFIG = {
  STORE = AUDIO_STORE_CONFIG,
  INVALID = AUDIO_INVALID_CONFIG
}

-- forced by the engine
local ASPECT_RATIO = 16 / 9

---@class UiSlotConfig
---@field WIDTH number Screen-space width of each pouch slot
---@field HEIGHT number Screen-space height of each pouch slot (calculated from width and aspect ratio)
---@field MARGIN number Screen-space margin between adjacent slots
---@field ALPHA number Transparency level for slot rendering
---@field TEXTURE TEXTURE Texture used for rendering empty slot backgrounds
local UI_SLOT_CONFIG = {
  WIDTH = 0.035,
  MARGIN = 0.0035,
  ALPHA = 0.5,
}
UI_SLOT_CONFIG.HEIGHT = UI_SLOT_CONFIG.WIDTH * ASPECT_RATIO
do
  local TEXTURE_WIDHT = 28
  local TEXTURE_HEIGHT = 28

  local texture_def = TextureDefinition.new()
  texture_def.texture_path = 'slot.png'
  texture_def.width = TEXTURE_WIDHT
  texture_def.height = TEXTURE_HEIGHT
  texture_def.tile_width = TEXTURE_WIDHT
  texture_def.tile_height = TEXTURE_HEIGHT

  UI_SLOT_CONFIG.TEXTURE = define_texture(texture_def)
end

---@class UiConfig
---@field ASPECT_RATIO number Screen aspect ratio used for UI calculations
---@field BASE_X number Screen-space X coordinate for first slot of first player
---@field BASE_Y number Screen-space Y coordinate for pouch UI elements
---@field PLAYER_STRIDE number Screen-space horizontal offset between different players' pouches
---@field SLOT UiSlotConfig Configuration specific to individual pouch slots
local UI_CONFIG = {
  ASPECT_RATIO = ASPECT_RATIO,
  BASE_X = -0.9625,
  BASE_Y = 0.67,
  PLAYER_STRIDE = 0.32,
  SLOT = UI_SLOT_CONFIG,
}

---@class Config
---@field POUCH PouchConfig Pouch capacity and behavior settings
---@field AUDIO AudioConfig Sound effect configurations
---@field UI UiConfig User interface layout and rendering settings
return {
  POUCH = POUCH_CONFIG,
  AUDIO = AUDIO_CONFIG,
  UI = UI_CONFIG,
}