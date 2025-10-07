-- POUCH MOD
--[[
TODO:
  - change capacity to starting capacity and add item that expands the capacity to item pools
  - horizontally center the transition cards
  - guard against invalid options
]]

meta = {
  name = "Pouch",
  version = "1.2",
  description = "Store held items and retrieve them later",
  author = "Quasar",
}

local POUCH_SIZE <const> = {
  MIN = 1,
  MAX = 7,
  DEFAULT = 2,
}

-- ==============================================================================

---@type boolean
local is_enabled = false

---@return boolean
local function get_is_enabled()
  return is_enabled
end

---@type boolean
local is_in_transition = false

---@return boolean
local function get_is_in_transition()
  return is_in_transition
end

local function enable_mod()
  is_enabled = true
end

local function disable_mod()
  is_enabled = false
end

local ui = require("ui").using(get_is_enabled, get_is_in_transition)
local input = require("input")
local Pouch = require("Pouch")

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
  return false -- the default kill logic still runs
end

local function initialize()
  for idx, player in ipairs(get_local_players()) do
    -- guard against other mods which use user_data
    if player.user_data == nil then
      ---@diagnostic disable-next-line: missing-fields
      player.user_data = {}
    end

    player.user_data.pouch = Pouch.init()
    player.user_data.previous_input = INPUTS.RUN
    player.user_data.is_retrieving = false
    player.user_data.selected_slot = 1
    player.user_data.retrieval_option =
        options[string.format("player%i_retrieval_option", idx)]
  end
end

local function handle_level_start()
  enable_mod()
  is_in_transition = false
  for _, player in ipairs(get_local_players()) do
    player:set_pre_kill(on_player_kill)
    input.register(player)
  end
end

local function handle_transition()
  enable_mod()
  is_in_transition = true
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

set_callback(initialize, ON.START)
set_callback(ui.render, ON.RENDER_POST_HUD)

set_callback(handle_level_start, ON.LEVEL)
set_callback(disable_mod, ON.MENU)
set_callback(disable_mod, ON.DEATH)
set_callback(handle_transition, ON.TRANSITION)
