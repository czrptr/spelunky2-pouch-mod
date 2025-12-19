-- POUCH MOD
--[[
TODO:
  - add item (through pools) that expands the capacity
  - horizontally center the transition cards
]]

meta = {
  name = "Pouch",
  version = "2.1",
  description = "Store held items and retrieve them later",
  author = "Quasar",
}

-- ==============================================================================

local POUCH_SIZE <const> = {
  DEFAULT = 2,
  MIN = 1,
  MAX = 7,
}

local on_level = -1
local on_transition = -1
local on_render_post_hud = -1

---@param entity Player
---@return integer
local function get_player_index(entity)
  for idx, player in ipairs(get_local_players()) do
    if entity.uid == player.uid then
      return idx
    end
  end
  return -1
end

local Metadata = require("Metadata")
local Pouch = require("Pouch")
local input = require("input")
local ui = require("ui")

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
---@return boolean
local function on_player_kill(self)
  self.user_data.pouch:spill(self.uid)
  return false
end

local function handle_level()
  clear_callback(on_render_post_hud)
  on_render_post_hud = set_callback(ui.render_slots, ON.RENDER_POST_HUD)
end

local function handle_transition()
  clear_callback(on_render_post_hud)
  on_render_post_hud = set_callback(ui.render_cards, ON.RENDER_POST_HUD)
end

---@param player Player
local function on_spawn_player(player)
  -- guard against other mods which use user_data
  if player.user_data == nil then
    ---@diagnostic disable-next-line: missing-fields
    player.user_data = {}
  end

  player.user_data.pouch = Pouch.init(options.pouch_size)
  player.user_data.previous_input = INPUTS.RUN
  player.user_data.is_retrieving = false
  player.user_data.selected_slot = 1
  player:set_pre_kill(on_player_kill)

  -- wait one frame so that on_spawn callback return and get_player_index()
  -- can access an updated list of players
  set_timeout(function()
    -- TODO: use player.inventory.player_slot
    local retrieval_option = options[string.format("player%i_retrieval_option", get_player_index(player))]
    input.register(player, retrieval_option)
  end, 1)
end

---@param backpack Backpack
local function on_spawn_backpack(backpack)
  backpack:set_post_putting_off(function(_, holder)
    if not Metadata.is_player(holder) then
      return false
    end

    ---@cast holder Player
    local _, _, layer = get_position(holder.uid)
    local clone_uid = Metadata.init(backpack.uid):spawn(layer)
    pick_up(holder.uid, clone_uid)
    backpack:destroy()
    return false
  end)
end

---@param entity Entity
local function on_spawn(entity)
  if Metadata.is_player(entity) then
    ---@cast entity Player
    on_spawn_player(entity)
  elseif Metadata.is_backpack(entity) then
    ---@cast entity Backpack
    on_spawn_backpack(entity)
  end
end

local function enable()
  --guard against invalid user options
  options.pouch_size = math.min(POUCH_SIZE.MAX, math.max(POUCH_SIZE.MIN, options.pouch_size))
  on_level = set_callback(handle_level, ON.LEVEL)
  on_transition = set_callback(handle_transition, ON.TRANSITION)
end

local function disable()
  clear_callback(on_level)
  clear_callback(on_transition)
  clear_callback(on_render_post_hud)
  on_level = -1
  on_transition = -1
  on_render_post_hud = -1
end

-- ==============================================================================

register_option_int(
  "pouch_size",
  "Pouch capacity",
  POUCH_SIZE.DEFAULT,
  POUCH_SIZE.MIN,
  POUCH_SIZE.MAX)

register_option_bool(
  "idols_are_storable",
  "Idols can be stored",
  false)

register_option_bool(
  "pets_are_storable",
  "Pets can be stored",
  false)

register_option_bool(
  "mounts_are_storable",
  "Mounts can be stored after they are tamed",
  false)

register_option_bool(
  "monsters_are_storable",
  "Monsters can be stored after they are killed",
  true)

for idx = 1, 4 do
  register_option_combo(
    string.format("player%i_retrieval_option", idx),
    string.format("Player %i item retrieval", idx),
    "Last inserted\0Selectable\0\0",
    input.RETRIEVAL_OPTION.LAST_INSERTED)
end

set_callback(save_options, ON.SAVE)
set_callback(load_options, ON.LOAD)

set_callback(enable, ON.START)
set_callback(disable, ON.MENU)
set_callback(disable, ON.DEATH)

set_post_entity_spawn(on_spawn, SPAWN_TYPE.ANY, MASK.ANY)
