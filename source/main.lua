-- POUCH MOD
--[[
TODO:
  - add FIFO (currently only option), LIFO and SELECTABLE options for pouch interactions
  - change capacity to starting capacity and add item that expands the capacity to item pools
]]

meta = {
  name = 'Pouch',
  version = '1.0',
  description = 'Store held items and retrieve them later',
  author = 'Quasar',
}

local CONFIG = require('config')
local Pouch = require('pouch')

-- ==============================================================================

---@type boolean
local is_enabled = false

---@type boolean
local is_in_transition = false

local function enable_mod()
  is_enabled = true
end

local function disable_mod()
  is_enabled = false
end

---@param current_input INPUTS
---@param previous_input INPUTS
---@param input_flag INPUT_FLAG
---@return boolean
local function was_just_pressed(current_input, previous_input, input_flag)
  return test_flag(current_input, input_flag) and not test_flag(previous_input, input_flag)
end

---@param left number
---@param bottom number
---@param width number
---@param height number
---@return AABB
local function bounds_from(left, bottom, width, height)
  return AABB:new(left, bottom + height, left + width, bottom)
end

-- ==============================================================================

---@param save_context SaveContext
local function save_options(save_context)
  save_context:save(json.encode(options))
end

---@param load_context LoadContext
local function load_options(load_context)
  local options_str = load_context:load()
  if options_str ~= '' then
    options = json.decode(options_str)
  end
end

---@param self Player
---@param _ boolean
---@param resposible Entity
---@return boolean
local function on_player_kill(self, _, resposible)
  self.user_data.pouch:spill(self.uid)
  return false -- the default kill logic still runs
end

---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS?

---@class Player
---@field user_data UserData

local function initialize_user_data()
  for _, player in ipairs(get_local_players()) do
    -- guard against other mods which use user_data
    if player.user_data == nil then
      ---@diagnostic disable-next-line: missing-fields
      player.user_data = {}
    end

    player.user_data.pouch = Pouch:init()
    player.user_data.previous_input = nil
  end
end

local function handle_level_start()
  enable_mod()
  is_in_transition = false
  for _, player in ipairs(get_local_players()) do
    player:set_pre_kill(on_player_kill)
  end
end

local function handle_transition()
  enable_mod()
  is_in_transition = true
end

local function on_game_frame()
  if not is_enabled then
    return
  end

  -- handle player input
  for _, player in ipairs(get_local_players()) do
    local current_input = player.input.buttons
    local previous_input = player.user_data.previous_input
    ---@cast previous_input INPUTS

    if test_flag(current_input, INPUT_FLAG.UP)
        and was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      -- prevent players from retrieving right as they exit the floor so that they
      -- don't accidentally lose items that cannot be carried through level trasitions
      local door_uid = get_entities_overlapping_hitbox(
        ENT_TYPE.FLOOR_DOOR_EXIT, MASK.ANY, player:get_hitbox(), LAYER.BOTH)[1]

      if player.holding_uid ~= -1 then
        player.user_data.pouch:store(player.uid, player.holding_uid)
      elseif door_uid == nil then
        player.user_data.pouch:retrieve(player.uid)
      end
    end
    player.user_data.previous_input = current_input
  end
end

---@param render_context VanillaRenderContext
local function render_slots(render_context)
  for idx, player in ipairs(get_local_players()) do
    for jdx = 1, options.pouch_size do
      local bounds = bounds_from(
        CONFIG.UI.SLOT.BASE_X
        + (CONFIG.UI.SLOT.WIDTH + CONFIG.UI.SLOT.MARGIN) * (jdx - 1)
        + CONFIG.UI.SLOT.PLAYER_STRIDE * (idx - 1),
        CONFIG.UI.SLOT.BASE_Y,
        CONFIG.UI.SLOT.WIDTH,
        CONFIG.UI.SLOT.HEIGHT
      )
      render_context:draw_screen_texture(
        CONFIG.UI.SLOT.TEXTURE, 0, 0, bounds, Color:new(1, 1, 1, CONFIG.UI.SLOT.BACKGROUND_ALPHA))

      local metadata = player.user_data.pouch.slots[jdx]
      if metadata ~= nil then
        bounds = bounds:extrude(
          CONFIG.UI.SLOT.ICON_ZOOM_X, CONFIG.UI.SLOT.ICON_ZOOM_Y)
        render_context:draw_screen_texture(
          metadata.texture, metadata.sprite_row, metadata.sprite_column, bounds,
          Color:new(1, 1, 1, CONFIG.UI.SLOT.ICON_ALPHA))
      end
    end
  end
end

---@param render_context VanillaRenderContext
local function render_cards(render_context)
  for idx, player in ipairs(get_local_players()) do
    local bounds = bounds_from(
      CONFIG.UI.BACKGROUND.BASE_X
      + CONFIG.UI.POUCH.PLAYER_STRIDE * (idx - 1),
      CONFIG.UI.BACKGROUND.BASE_Y,
      CONFIG.UI.BACKGROUND.WIDTH,
      CONFIG.UI.BACKGROUND.HEIGHT
    )
    render_context:draw_screen_texture(
      CONFIG.UI.BACKGROUND.TEXTURE, 0, 0, bounds, Color:white())

    bounds = bounds_from(
      CONFIG.UI.POUCH.BASE_X
      + CONFIG.UI.POUCH.PLAYER_STRIDE * (idx - 1),
      CONFIG.UI.POUCH.BASE_Y,
      CONFIG.UI.POUCH.WIDTH,
      CONFIG.UI.POUCH.HEIGHT
    )
    render_context:draw_screen_texture(
      CONFIG.UI.POUCH.TEXTURE, 0, 0, bounds, Color:white())

    local zoom = -0.002
    bounds = bounds:extrude(zoom, zoom * CONFIG.UI.ASPECT_RATIO):offset(-0.025, 0.01)
    render_context:draw_screen_texture(
      player:get_texture(), 9, 14, bounds, Color:white(), -0.2, 0, 0)

    for jdx, metadata in ipairs(player.user_data.pouch.slots) do
      bounds = bounds_from(
        CONFIG.UI.BACKGROUND.BASE_X
        + CONFIG.UI.POUCH.PLAYER_STRIDE * (idx - 1)
        + CONFIG.UI.BACKGROUND.SLOT_POSITIONS[jdx].X,
        CONFIG.UI.BACKGROUND.BASE_Y
        + CONFIG.UI.BACKGROUND.SLOT_POSITIONS[jdx].Y,
        CONFIG.UI.SLOT.WIDTH,
        CONFIG.UI.SLOT.HEIGHT
      )
      zoom = 0.015
      bounds = bounds:extrude(zoom, zoom * CONFIG.UI.ASPECT_RATIO)
      render_context:draw_screen_texture(
        metadata.texture, metadata.sprite_row, metadata.sprite_column, bounds, Color:white())
    end
  end
end

---@param render_context VanillaRenderContext
local function render_user_interface(render_context)
  if not is_enabled then
    return
  end

  if is_in_transition then
    render_cards(render_context)
  elseif pause:get_pause() == PAUSE_TYPE.NONE then
    render_slots(render_context)
  end
end

-- ==============================================================================

register_option_int(
  'pouch_size',
  'Pouch capacity',
  CONFIG.POUCH.DEFAULT_CAPACITY,
  CONFIG.POUCH.MIN_CAPACITY,
  CONFIG.POUCH.MAX_CAPACITY
)

register_option_bool(
  'idols_are_storable',
  'Idols can be stored',
  false
)

register_option_bool(
  'pets_are_storable',
  'Pets can be stored',
  false
)

register_option_bool(
  'mounts_are_storable',
  'Mounts can be stored after they are tamed',
  false
)

register_option_bool(
  'monster_are_storable',
  'Monsters can be stored after they are killed',
  true
)

set_callback(save_options, ON.SAVE)
set_callback(load_options, ON.LOAD)

set_callback(initialize_user_data, ON.START)
set_callback(on_game_frame, ON.GAMEFRAME)
set_callback(render_user_interface, ON.RENDER_POST_HUD)

set_callback(handle_level_start, ON.LEVEL)
set_callback(disable_mod, ON.MENU)
set_callback(disable_mod, ON.DEATH)
set_callback(handle_transition, ON.TRANSITION)
