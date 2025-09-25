meta.name = 'Pouch'
meta.version = '0.1'
meta.description = 'Store held items and retrieve them later'
meta.author = 'Quasar'

-- TODO: UI, configurable size, configurable what kind of entities are allowed to be stored

local SFX_STORE = get_sound(VANILLA_SOUND.MOUNTS_MOUNT)
local SFX_INVALID = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)

function play_sfx(sfx, pitch, volume)
  local playing_sound = sfx:play(true)
  playing_sound:set_pitch(pitch)
  playing_sound:set_volume(volume)
  playing_sound:set_pause(false)
end

function unset_flag(flags, bit)
  return flags & ~bit
end

--== Pouch ==--

local Pouch = {}
Pouch.__index = Pouch

function Pouch:init(player_uid, size)
  return setmetatable({
    size = size,
    capacity = size,
    slots = {},
    selection = 1,
    player_uid = player_uid
  }, Pouch)
end

function Pouch:store(held_uid)
  if self.capacity <= 0 then
    play_sfx(SFX_INVALID, 1.3, 0.775)
    return
  end

  self.slots[1 + self.size - self.capacity] = held_uid
  self.capacity = self.capacity - 1

  drop(self.player_uid, held_uid)

  -- disable held entity
  local held = get_entity(held_uid)
  held.flags = set_flag(held.flags, ENT_FLAG.INVISIBLE | ENT_FLAG.PAUSE_AI_AND_PHYSICS)
  move_entity(held_uid, 0, 0, 0, 0)

  -- create pickup visual effect
  local x, y, l = get_position(self.player_uid)
  local fx_uid = spawn_entity(ENT_TYPE.FX_PICKUPEFFECT, x, y, l, 0, 0)
  local fx = get_entity(fx_uid)
  fx:set_texture(held:get_texture())
  fx.animation_frame = held.animation_frame
  generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

  -- play sound effect
  play_sfx(SFX_STORE, 1.1, 1.2)
end

function Pouch:retrieve()
  self.capacity = self.capacity + 1
  local held_uid = table.remove(self.slots, self.selection)
  local held = get_entity(held_uid)
  held.flags = unset_flag(held.flags, ENT_FLAG.INVISIBLE | ENT_FLAG.PAUSE_AI_AND_PHYSICS)

  pick_up(self.player_uid, held_uid)

  generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)
end

--== Business logic --==

-- access through options.pouch_size
register_option_int('pouch_size', 'Pouch capacity', 1, 1, 3)

-- A table mapping player UIDs to their pouch instances
local pouches = {}
local inputs = {}

set_callback(function ()
  for idx, player in ipairs(get_local_players()) do
    pouches[idx] = Pouch:init(player.uid, options.pouch_size)
    inputs[idx] = string.format('player_slot_%d', idx)
  end
end, ON.START)

set_callback(function ()
  for idx, player in ipairs(get_local_players()) do
    local buttons = state.player_inputs[inputs[idx]].buttons
    if player:is_button_pressed(BUTTON.DOOR) and test_flag(buttons, INPUT_FLAG.UP) then
      if player.holding_uid ~= -1 then
        pouches[idx]:store(player.holding_uid)
      else
        pouches[idx]:retrieve()
      end
    end
  end
end, ON.FRAME)