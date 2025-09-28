-- TODO: read and store from file for persistance

local POUCH_CONFIG = {
  MIN_CAPACITY = 1,
  MAX_CAPACITY = 7,
  DEFAULT_CAPACITY = 2,
}

local AUDIO_STORE_CONFIG = {
  SOUND = get_sound(VANILLA_SOUND.MOUNTS_MOUNT),
  PITCH = 1.1,
  VOLUME = 1.2,
}

local AUDIO_INVALID_CONFIG = {
  SOUND = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE),
  PITCH = 1.3,
  VOLUME = 0.775,
}


local AUDIO_CONFIG = {
  STORE = AUDIO_STORE_CONFIG,
  INVALID = AUDIO_INVALID_CONFIG
}

-- forced by the engine
local ASPECT_RATIO = 16 / 9

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

local UI_CONFIG = {
  ASPECT_RATIO = ASPECT_RATIO,
  BASE_X = -0.9625,
  BASE_Y = 0.67,
  PLAYER_STRIDE = 0.32,
  SLOT = UI_SLOT_CONFIG,
}

-- CONFIG
return {
  POUCH = POUCH_CONFIG,
  AUDIO = AUDIO_CONFIG,
  UI = UI_CONFIG,
}