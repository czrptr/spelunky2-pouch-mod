--- module
local input = {}

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

local BEHAVIOR_CLIMBING <const> = 6

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

---@param self Player
---@return boolean
local function on_player_last_inserted(self)
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
local function on_player_selectable(self)
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
    elseif self.user_data.selected_slot < 1 then
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

-- ==============================================================================

---@enum RetrievalOption
input.RETRIEVAL_OPTION = {
  LAST_INSERTED = 1,
  SELECTABLE = 2,
}

---@param player Player
---@param retrieval_option RetrievalOption
function input.register(player, retrieval_option)
  if retrieval_option == input.RETRIEVAL_OPTION.LAST_INSERTED then
    player:set_pre_process_input(on_player_last_inserted)
  else
    player:set_pre_process_input(on_player_selectable)
  end
end

-- ==============================================================================

return input
