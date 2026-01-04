--- module
local controller = {}

local RETRIEVAL_OPTION = require("RetrievalOption")

-- ==============================================================================

-- TODO: allow menuing when gliding and preserve gliding state

local BEHAVIOR_AIRBORNE <const> = 0
local BEHAVIOR_JUMPING <const> = 8
local BEHAVIOR_FALLING <const> = 9
local RISKY_BEHAVIORS <const> = {
  BEHAVIOR_AIRBORNE,
  BEHAVIOR_JUMPING,
  BEHAVIOR_FALLING,
}

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
  local behavior = self:get_behavior()
  local safe_to_menu = true
  for _, risky_behavior in ipairs(RISKY_BEHAVIORS) do
    if behavior == risky_behavior then
      safe_to_menu = false
      break
    end
  end

  if l_shoulder.pressed then
    self.user_data.pouch:rotate()
  end

  if l_trigger.down then
    self.user_data.quick_action_timer = self.user_data.quick_action_timer - 1
  else
    self.user_data.quick_action_timer = options.quick_action_interval
  end

  local input_captured = false
  if l_trigger.pressed then
    -- PRESSED: Start the action

    if self.holding_uid ~= -1 then
      -- Player is holding an item
      self.user_data.wants_to_store = true
      self.user_data.waiting_for_release = true -- Wait for release to decide
    elseif self.user_data.pouch:can_retrieve() then
      -- Player wants to retrieve
      self.user_data.wants_to_store = false
      self.user_data.waiting_for_release = true -- Wait for release to decide
    end
  elseif l_trigger.down and self.user_data.waiting_for_release then
    -- HELD DOWN: Check if we should switch to menu mode

    -- If timer has expired, switch to menu mode
    if self.user_data.quick_action_timer <= 0 and safe_to_menu then
      self.user_data.waiting_for_release = false
      self.user_data.is_retrieving = true
      self.user_data.selected_slot = 1
      input_captured = false
    end
  elseif l_trigger.down and self.user_data.is_retrieving and safe_to_menu then
    -- HELD DOWN: Menu navigation

    if was_just_pressed(current_input, previous_input, INPUT_FLAG.RIGHT) then
      self.user_data.selected_slot = self.user_data.selected_slot + 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.LEFT) then
      self.user_data.selected_slot = self.user_data.selected_slot - 1
    elseif was_just_pressed(current_input, previous_input, INPUT_FLAG.DOWN) then
      -- Cancel
      self.user_data.is_retrieving = false
      self.user_data.wants_to_store = false
      self.user_data.waiting_for_release = false
    end

    -- Wrap selection
    if self.user_data.selected_slot > #self.user_data.pouch.slots then
      self.user_data.selected_slot = 1
    elseif self.user_data.selected_slot < 1 then
      self.user_data.selected_slot = #self.user_data.pouch.slots
    end

    input_captured = true
  elseif not l_trigger.down then
    -- RELEASED: Complete the action

    -- Quick action (released before timer expired)
    if self.user_data.waiting_for_release then
      if self.user_data.wants_to_store then
        -- Quick store
        self.user_data.pouch:store(self.uid, self.holding_uid)
      else
        -- Quick retrieve
        self.user_data.pouch:retrieve(self.uid)
      end

      -- Reset states
      self.user_data.waiting_for_release = false
      self.user_data.wants_to_store = false
      input_captured = false
    elseif self.user_data.is_retrieving then
      -- Menu action completed
      if self.user_data.wants_to_store then
        -- Store in selected slot
        self.user_data.pouch:store(self.uid, self.holding_uid, self.user_data.selected_slot)
      else
        -- Retrieve from selected slot
        self.user_data.pouch:retrieve(self.uid, self.user_data.selected_slot)
      end

      -- Reset states
      self.user_data.is_retrieving = false
      self.user_data.wants_to_store = false
      self.user_data.waiting_for_release = false
      input_captured = false
    end
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
