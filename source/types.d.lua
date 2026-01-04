---@meta

---@class UserData
---@field pouch Pouch
---@field previous_input INPUTS
---@field is_retrieving boolean
---@field selected_slot integer
---@field quick_action_timer integer
---@field wants_to_store boolean
---@field waiting_for_release boolean

---@class Player
---@field user_data UserData | any

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
---@field quick_action_interval integer

---@type Options | any
options = nil
