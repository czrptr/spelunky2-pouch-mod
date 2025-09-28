-- POUCH MOD
-- TODO: special tranzition ui, configurable what kind of entities are allowed to be stored, memory and callback cleanup

meta = {
  name = 'Pouch',
  version = '0.1',
  description = 'Store held items and retrieve them later',
  author = 'Quasar',
}

local CONFIG = require('config')
local Pouch = require('pouch')

-- ==============================================================================

local is_enabled  = false

local function enable()
  is_enabled = true
end

local function disable()
  is_enabled = false
end

---@param current_input INPUTS
---@param previous_input INPUTS
---@param input_flag INPUT_FLAG
---@return boolean
local function was_just_pressed(current_input, previous_input, input_flag)
  return test_flag(current_input, input_flag) and not test_flag(previous_input, input_flag)
end

---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS?

---@class Player
---@field user_data UserData

local function initialize()
  for _, player in ipairs(get_local_players()) do
    -- guard against other mods who use user_data
    if player.user_data == nil then
      ---@diagnostic disable-next-line: missing-fields
      player.user_data = {}
    end

    player.user_data.pouch = Pouch:init()
    player.user_data.previous_input = nil
  end
end

local function game_update()
  if not is_enabled then
    return
  end

  for _, player in ipairs(get_local_players()) do
    local current_input = player.input.buttons
    local previous_input = player.user_data.previous_input
    ---@cast previous_input INPUTS

    if test_flag(current_input, INPUT_FLAG.UP) and was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      if player.holding_uid ~= -1 then
        player.user_data.pouch:store(player.uid, player.holding_uid)
      else
        player.user_data.pouch:retrieve(player.uid)
      end
    end

    player.user_data.previous_input = current_input
  end
end

local function user_interface(render_ctx)
  if not is_enabled then
    return
  end

  for idx, player in ipairs(get_local_players()) do
    for jdx = 1, options.pouch_size do
      local bounds = AABB:new()
      bounds.left = CONFIG.UI.BASE_X + (CONFIG.UI.SLOT.WIDTH + CONFIG.UI.SLOT.MARGIN) * (jdx - 1) + CONFIG.UI.PLAYER_STRIDE * (idx - 1)
      bounds.right = bounds.left + CONFIG.UI.SLOT.WIDTH
      bounds.bottom = CONFIG.UI.BASE_Y
      bounds.top = bounds.bottom + CONFIG.UI.SLOT.HEIGHT

      render_ctx:draw_screen_texture(CONFIG.UI.SLOT.TEXTURE, 0, 0, bounds, Color:new(1, 1, 1, CONFIG.UI.SLOT.BACKGROUND_ALPHA))

      local metadata = player.user_data.pouch.slots[jdx]
      if metadata ~= nil then
        local texture = metadata.texture
        local texture_definition = get_texture_definition(texture)
        local columns = texture_definition.width / texture_definition.tile_width
        local rows = texture_definition.height / texture_definition.tile_height
        local sprite_row = math.floor(metadata.animation_frame // rows)
        local sprite_column = math.floor(metadata.animation_frame % columns)

        bounds = bounds:extrude(CONFIG.UI.SLOT.ICON_ZOOM_X, CONFIG.UI.SLOT.ICON_ZOOM_Y)
        render_ctx:draw_screen_texture(texture, sprite_row, sprite_column, bounds, Color:new(1, 1, 1, CONFIG.UI.SLOT.ICON_ALPHA))
      end
    end
  end
end

-- ==============================================================================

register_option_int(
  'pouch_size', -- name
  'Pouch capacity', -- description
  CONFIG.POUCH.DEFAULT_CAPACITY,
  CONFIG.POUCH.MIN_CAPACITY,
  CONFIG.POUCH.MAX_CAPACITY
)

set_callback(initialize, ON.START)
set_callback(game_update, ON.GAMEFRAME)
set_callback(user_interface, ON.RENDER_POST_HUD)

set_callback(enable, ON.LEVEL)
set_callback(disable, ON.MENU)
set_callback(disable, ON.DEATH)
set_callback(disable, ON.TRANSITION)