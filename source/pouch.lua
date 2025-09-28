local CONFIG = require('config')
local Metadata = require('metadata')

-- ==============================================================================

---@param sfx AudioSoundConfig
local function play_sfx(sfx)
  local playing_sound = sfx.SOUND:play(true)
  playing_sound:set_pitch(sfx.PITCH)
  playing_sound:set_volume(sfx.VOLUME)
  playing_sound:set_pause(false)
end

-- ==============================================================================

---@class Pouch
---@field slots Metadata[]
local Pouch = {}
Pouch.__index = Pouch

---comment
---@return Pouch
function Pouch:init()
  return setmetatable({
    slots = {}
  }, Pouch)
end

---@param player_uid integer
---@param held_uid integer
function Pouch:store(player_uid, held_uid)
  if #self.slots >= options.pouch_size then
    play_sfx(CONFIG.AUDIO.INVALID)
    return
  end

  table.insert(self.slots, 1, Metadata:from_entity(held_uid))

  -- create pickup visual effect
  generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

  -- play sound effect
  play_sfx(CONFIG.AUDIO.STORE)

  drop(player_uid, held_uid)
  move_entity(held_uid, 0, 0, 0, 0);
  kill_entity(held_uid)
end

---@param player_uid integer
function Pouch:retrieve(player_uid)
  if #self.slots == 0 then
    return
  end

  local held_uid = table.remove(self.slots, 1):spawn_at(player_uid)
  pick_up(player_uid, held_uid)

  -- create pickup visual effect
  generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

  -- TODO: play sound effect
end

return Pouch