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

local POUCH_INPUTS <const> = {
  ON_GROUND = {
    STORE_OR_RETRIEVE = INPUT_FLAG.UP,
    ROTATE = INPUT_FLAG.DOWN,
  },
  WHILE_CLIMBING = {
    STORE_OR_RETRIEVE = INPUT_FLAG.LEFT,
    ROTATE = INPUT_FLAG.RIGHT,
  },
}

---@enum RetrievalOption
local RETRIEVAL_OPTION <const> = {
  LAST_INSERTED = 1,
  SELECTABLE = 2,
}

local BEHAVIOR_CLIMBING <const> = 6

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
local Pouch = require("Pouch")

-- ==============================================================================

---@param current_input INPUTS
---@param previous_input INPUTS
---@param input_flag INPUT_FLAG
---@return boolean
local function was_just_pressed(current_input, previous_input, input_flag)
  return test_flag(current_input, input_flag) and not test_flag(previous_input, input_flag)
end

---@param player Player
---@return boolean
local function can_enter_a_door(player)
  local door_uid = get_entities_overlapping_hitbox(
    ENT_TYPE.DOOR, MASK.ANY, player:get_hitbox(), LAYER.BOTH)[1]

  if door_uid == nil then
    return false
  end

  local door = get_entity(door_uid) --[[@as Door]]
  return door:can_enter(player)
end

---@param player Player
local function get_input_context(player)
  local MODAL_INPUTS =
      (player:get_behavior() == BEHAVIOR_CLIMBING)
      and POUCH_INPUTS.WHILE_CLIMBING
      or POUCH_INPUTS.ON_GROUND

  return MODAL_INPUTS, (not can_enter_a_door(player)), player.input.buttons, player.user_data.previous_input
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
---@return boolean
local function on_player_kill(self)
  self.user_data.pouch:spill(self.uid)
  return false -- the default kill logic still runs
end

---@param self Player
---@return boolean
local function on_player_last_inserted_pre_process_input(self)
  local MODAL_INPUTS, accidental_drop_is_impossible,
  current_input, previous_input = get_input_context(self)

  if was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
    if test_flag(current_input, MODAL_INPUTS.STORE_OR_RETRIEVE) then
      if self.holding_uid ~= -1 then
        self.user_data.pouch:store(self.uid, self.holding_uid)
      elseif accidental_drop_is_impossible then
        self.user_data.pouch:retrieve(self.uid)
      end
    elseif test_flag(current_input, MODAL_INPUTS.ROTATE) then
      self.user_data.pouch:rotate()
    end
  end

  self.user_data.previous_input = current_input
  return false
end

---@param self Player
---@return boolean
local function on_player_selectable_pre_process_input(self)
  local MODAL_INPUTS, accidental_drop_is_impossible,
  current_input, previous_input = get_input_context(self)

  local input_captured = false
  if self.user_data.is_retrieving then
    if was_just_pressed(current_input, previous_input, INPUT_FLAG.RIGHT) then
      self.user_data.selected_slot = self.user_data.selected_slot + 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.LEFT) then
      self.user_data.selected_slot = self.user_data.selected_slot - 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      self.user_data.pouch:retrieve(self.uid, self.user_data.selected_slot)
      self.user_data.is_retrieving = false
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.DOWN) then
      self.user_data.is_retrieving = false
    end

    if self.user_data.selected_slot > #self.user_data.pouch.slots then
      self.user_data.selected_slot = 1
    elseif self.user_data.selected_slot < 0 then
      self.user_data.selected_slot = #self.user_data.pouch.slots
    end

    input_captured = true
  else
    if was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      if test_flag(current_input, MODAL_INPUTS.STORE_OR_RETRIEVE) then
        if self.holding_uid ~= -1 then
          self.user_data.pouch:store(self.uid, self.holding_uid)
        elseif accidental_drop_is_impossible and self.user_data.pouch:can_retrieve() then
          self.user_data.is_retrieving = true
          self.user_data.selected_slot = 1
        end
      elseif test_flag(current_input, MODAL_INPUTS.ROTATE) then
        self.user_data.pouch:rotate()
      end
    end

    input_captured = false
  end

  self.user_data.previous_input = current_input
  return input_captured
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
    if player.user_data.retrieval_option == RETRIEVAL_OPTION.LAST_INSERTED then
      player:set_pre_process_input(on_player_last_inserted_pre_process_input)
    else
      player:set_pre_process_input(on_player_selectable_pre_process_input)
    end
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
    RETRIEVAL_OPTION.LAST_INSERTED)
end

set_callback(save_options, ON.SAVE)
set_callback(load_options, ON.LOAD)

set_callback(initialize, ON.START)
set_callback(ui.render, ON.RENDER_POST_HUD)

set_callback(handle_level_start, ON.LEVEL)
set_callback(disable_mod, ON.MENU)
set_callback(disable_mod, ON.DEATH)
set_callback(handle_transition, ON.TRANSITION)
