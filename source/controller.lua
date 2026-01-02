--- module
local controller = {}

local RETRIEVAL_OPTION = require("RetrievalOption")

-- ==============================================================================

---@param current_input INPUTS
---@param previous_input INPUTS
---@param input_flag INPUT_FLAG
---@return boolean
local function was_just_pressed(current_input, previous_input, input_flag)
  return test_flag(current_input, input_flag) and not test_flag(previous_input, input_flag)
end

---@param player Player
local function get_input(player)
  local player_index = player.input.player_slot
  local input_index = game_manager.game_props.input_index[player_index]
  local current_input = get_raw_input()
  if current_input == nil then
    return
        { pressed = false, down = false },
        { pressed = false, down = false },
        player.input.buttons,
        player.user_data.previous_input
  end

  local controller = current_input.controller[input_index].buttons
  return
      controller[RAW_BUTTON.LEFT_TRIGGER],
      controller[RAW_BUTTON.LEFT_SHOULDER],
      player.input.buttons,
      player.user_data.previous_input
end

---@param self Player
---@return boolean
local function on_player_last_inserted(self)
  local l_trigger, l_shoulder, _, _ = get_input(self)
  if l_trigger.pressed then
    if self.holding_uid ~= -1 then
      self.user_data.pouch:store(self.uid, self.holding_uid)
    else
      self.user_data.pouch:retrieve(self.uid)
    end
  elseif l_shoulder.pressed then
    self.user_data.pouch:rotate()
  end
  return false
end

---@param self Player
---@return boolean
local function on_player_selectable(self)
  local l_trigger, l_shoulder, current_input, previous_input = get_input(self)

  if l_shoulder.pressed then
    self.user_data.pouch:rotate()
  end

  local input_captured = false
  if l_trigger.down and self.user_data.is_retrieving then
    if was_just_pressed(current_input, previous_input, INPUT_FLAG.RIGHT) then
      self.user_data.selected_slot = self.user_data.selected_slot + 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.LEFT) then
      self.user_data.selected_slot = self.user_data.selected_slot - 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.DOWN) then
      self.user_data.is_retrieving = false
    end
    if self.user_data.selected_slot > #self.user_data.pouch.slots then
      self.user_data.selected_slot = 1
    elseif self.user_data.selected_slot < 1 then
      self.user_data.selected_slot = #self.user_data.pouch.slots
    end

    input_captured = true
  elseif not l_trigger.down and self.user_data.is_retrieving then
    self.user_data.pouch:retrieve(self.uid, self.user_data.selected_slot)
    self.user_data.is_retrieving = false
    input_captured = true
  elseif l_trigger.pressed then
    if self.holding_uid ~= -1 then
      self.user_data.pouch:store(self.uid, self.holding_uid)
    elseif self.user_data.pouch:can_retrieve() then
      self.user_data.is_retrieving = true
      self.user_data.selected_slot = 1
    end
    input_captured = false
  end

  self.user_data.previous_input = current_input
  return input_captured
end

---@param player Player
---@param retrieval_option RetrievalOption
function controller.register(player, retrieval_option)
  if retrieval_option == RETRIEVAL_OPTION.LAST_INSERTED then
    player:set_pre_process_input(on_player_last_inserted)
  else
    player:set_pre_process_input(on_player_selectable)
  end
end

-- ==============================================================================

return controller
