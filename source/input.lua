--- module
local input = {}

local keyboard = require("keyboard")
local controller = require("controller")

---@param player Player
local function player_is_keyboard_controlled(player)
  local player_index = player.input.player_slot
  local input_index = game_manager.game_props.input_index[player_index]
  return input_index >= 0 and input_index <= 3
end

-- ==============================================================================

---@param player Player
---@param retrieval_option RetrievalOption
function input.register(player, retrieval_option)
  if player_is_keyboard_controlled(player) then
    keyboard.register(player, retrieval_option)
  else
    controller.register(player, retrieval_option)
  end
end

-- ==============================================================================

return input
