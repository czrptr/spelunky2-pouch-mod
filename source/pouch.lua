local CONFIG = require("config")
local Metadata = require("metadata")

-- ==============================================================================

---@param sfx AudioSoundConfig
local function play_sfx(sfx)
  local playing_sound = sfx.SOUND:play(true)
  playing_sound:set_pitch(sfx.PITCH)
  playing_sound:set_volume(sfx.VOLUME)
  playing_sound:set_pause(false)
end

---@param uid integer
---@return boolean
local function is_storable(uid)
  local entity = get_entity(uid)
  local type = entity.type.id
  if CONFIG.STORABLE.ALWAYS[type] then
    return true
  end
  if CONFIG.STORABLE.IDOLS[type] and options.idols_are_storable then
    return true
  end
  if test_flag(entity.flags, ENT_FLAG.DEAD) then
    return true
  end
  if CONFIG.STORABLE.PETS[type] and options.pets_are_storable then
    return true
  end
  if CONFIG.STORABLE.MOUNTS[type] and options.mounts_are_storable then
    return (entity --[[@as Mount]]).tamed
  end
  return false
end

-- ==============================================================================

---@class Pouch
---@field slots Metadata[]
local Pouch = {}
Pouch.__index = Pouch

---@return Pouch
function Pouch.init()
  return setmetatable({
    slots = {}
  }, Pouch)
end

---@param player_uid integer
---@param held_uid integer
function Pouch:store(player_uid, held_uid)
  if #self.slots >= options.pouch_size or not is_storable(held_uid) then
    play_sfx(CONFIG.AUDIO.INVALID)
    return
  end

  table.insert(self.slots, 1, Metadata.init(held_uid))

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

  local held_uid = table.remove(self.slots, 1):spawn()
  pick_up(player_uid, held_uid)

  -- Immediate drop/re-pickup on next frame
  -- This is needed because otherwise some entities
  -- will render behind the player when picked up
  set_timeout(function()
    drop(player_uid, held_uid)
    pick_up(player_uid, held_uid)

    -- create pickup visual effect
    generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

    -- sound effect played by pickup
  end, 1)
end

---@param player_uid integer
function Pouch:spill(player_uid)
  local direction = 0.1
  while #self.slots > 0 do
    local x, y, _ = get_position(player_uid)
    local entity_id = table.remove(self.slots, 1):spawn()
    move_entity(entity_id, x, y, direction, 0.1)
    direction = direction * -1
  end
end

function Pouch:rotate()
  if #self.slots < 2 then
    return
  end

  local last_item = table.remove(self.slots, #self.slots)
  table.insert(self.slots, 1, last_item)
end

return Pouch
