---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS
---@field is_retrieving boolean
---@field selected_slot integer
---@field retrieval_option RetrievalOption

---@class Player
---@field user_data UserData

---@class Options
---@field pouch_size integer
---@field idols_are_storable boolean
---@field pets_are_storable boolean
---@field mounts_are_storable boolean
---@field monsters_are_storable boolean
---@field player1_retrieval_option RetrievalOption
---@field player2_retrieval_option RetrievalOption
---@field player3_retrieval_option RetrievalOption
---@field player4_retrieval_option RetrievalOption

---@enum RetrievalOption
RETRIEVAL_OPTION = {
  LAST_INSERTED = 1,
  SELECTABLE = 2,
}

---@class PouchConfig
---@field MIN_CAPACITY integer Minimum number of slots allowed in pouch
---@field MAX_CAPACITY integer Maximum number of slots allowed in pouch
---@field DEFAULT_CAPACITY integer Default number of slots in pouch
local POUCH_CONFIG <const> = {
  MIN_CAPACITY = 1,
  MAX_CAPACITY = 7,
  DEFAULT_CAPACITY = 2,
}

-- ==============================================================================

---@enum PlayerBehavior
local PLAYER_HEHAVIOR <const> = {
  CLIMBING = 6,
}

---@class Behavior
local BEHAVIOR <const> = {
  PLAYER = PLAYER_HEHAVIOR
}

---@class PouchInputs
local POUCH_INPUTS <const> = {
  ---@class OnGround
  ON_GROUND = {
    STORE_OR_RETRIEVE = INPUT_FLAG.UP,
    ROTATE = INPUT_FLAG.DOWN,
  },
  ---@class WhileClimbing
  WHILE_CLIMBING = {
    STORE_OR_RETRIEVE = INPUT_FLAG.LEFT,
    ROTATE = INPUT_FLAG.RIGHT,
  },
}

-- ==============================================================================

---@class Config
---@field POUCH PouchConfig Pouch capacity and behavior settings
---@field AUDIO AudioConfig Sound effect configurations
---@field INPUTS PouchInputs Input configurations for interacting with the pouch
local CONFIG <const> = {
  POUCH = POUCH_CONFIG,
  BEHAVIOR = BEHAVIOR,
  INPUTS = POUCH_INPUTS,
  RETRIEVAL_OPTION = RETRIEVAL_OPTION
}

return CONFIG
