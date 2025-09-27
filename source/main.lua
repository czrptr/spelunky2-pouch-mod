local inspect = require('inspect')

meta.name = 'Pouch'
meta.version = '0.1'
meta.description = 'Store held items and retrieve them later'
meta.author = 'Quasar'

-- TODO: UI, configurable size, configurable what kind of entities are allowed to be stored, memory and callback cleanup

local slot_texture = nil
do
  local texture_def = TextureDefinition.new()

  texture_def.texture_path = 'slot.png'
  texture_def.width = 128
  texture_def.height = 128
  texture_def.tile_width = 128
  texture_def.tile_height = 128
  slot_texture = define_texture(texture_def)
end

local SFX_STORE = get_sound(VANILLA_SOUND.MOUNTS_MOUNT)
local SFX_INVALID = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)

local function play_sfx(sfx, pitch, volume)
  local playing_sound = sfx:play(true)
  playing_sound:set_pitch(pitch)
  playing_sound:set_volume(volume)
  playing_sound:set_pause(false)
end

local function was_just_pressed(current_input, previous_input, input_flag)
  return test_flag(current_input, input_flag) and not test_flag(previous_input, input_flag)
end

--== Pouch ==--

local Pouch = {}
Pouch.__index = Pouch

function Pouch:init(player_uid)
  return setmetatable({
    slots = {},
    player_uid = player_uid
  }, Pouch)
end

function Pouch:store(held_uid)
  print(string.format("Pre store: %d", tostring(#self.slots)))

  if #self.slots >= options.pouch_size then
    play_sfx(SFX_INVALID, 1.3, 0.775)
    return
  end

  table.insert(self.slots, 1, held_uid)

  -- disable held entity
  local held = get_entity(held_uid)
  held.flags = set_flag(held.flags, ENT_FLAG.INVISIBLE)
  held.flags = set_flag(held.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
  drop(self.player_uid, held_uid)

  -- create pickup visual effect
  -- local x, y, l = get_position(self.player_uid)
  -- local fx_uid = spawn_entity(ENT_TYPE.FX_PICKUPEFFECT, x, y, l, 0, 0)
  -- local fx = get_entity(fx_uid)
  -- fx:set_texture(held:get_texture())
  -- fx.animation_frame = held.animation_frame
  -- generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

  -- play sound effect
  play_sfx(SFX_STORE, 1.1, 1.2)
  print(string.format("Post store: %d", tostring(#self.slots)))
end

function Pouch:retrieve()
  print(string.format("Pre retrieve: %d", tostring(#self.slots)))

  if #self.slots == 0 then
    return
  end

  local held_uid = table.remove(self.slots, 1)

  -- local x, y, l = get_position(self.player_uid)
  -- local fx_uid = spawn_entity(ENT_TYPE.FX_PICKUPEFFECT, x, y, l, 0, 0)
  -- local fx = get_entity(fx_uid)
  -- fx:set_texture(metadata.texture)
  -- fx.animation_frame = metadata.animation_frame

  local held = get_entity(held_uid)
  held.flags = clr_flag(held.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
  held.flags = clr_flag(held.flags, ENT_FLAG.INVISIBLE)
  pick_up(self.player_uid, held_uid)

  -- generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)
  print(string.format("Post retrieve: %d", tostring(#self.slots)))
end

--== Business logic ==--

local pouches = {}
local previous_inputs = {}

local function init()
  for idx, player in ipairs(get_local_players()) do
    pouches[idx] = Pouch:init(player.uid)
  end
end

local function update()
  for idx, player in ipairs(get_local_players()) do
    local current_input = player.input.buttons
    local previous_input = previous_inputs[idx]

    if test_flag(current_input, INPUT_FLAG.DOWN) and was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      print(inspect(pouches[idx]))
    end

    if test_flag(current_input, INPUT_FLAG.UP) and was_just_pressed(current_input, previous_input, INPUT_FLAG.DOOR) then
      if player.holding_uid ~= -1 then
        pouches[idx]:store(player.holding_uid)
      else
        pouches[idx]:retrieve()
      end
    end

    previous_inputs[idx] = current_input
  end
end

local function ui(render_ctx)
  local ASPECT_RATIO = 16 / 9
  local UI_WIDTH = 0.05
  local UI_HEIGHT = UI_WIDTH * ASPECT_RATIO
  local UI_X = -0.95
  local UI_Y = 0.7
  local UI_MARGIN = 0.0075

  for idx = 1, options.pouch_size do
    local bounds = AABB:new()
    bounds.left = UI_X + (UI_WIDTH + UI_MARGIN) * (idx - 1)
    bounds.right = bounds.left + UI_WIDTH
    bounds.bottom = UI_Y
    bounds.top = bounds.bottom + UI_HEIGHT

    render_ctx:draw_screen_texture(slot_texture, 0, 0, bounds, Color:new(1, 1, 1, 1))

    local slot_uid = pouches[1].slots[idx]

    if slot_uid ~= nil then
      local slot = get_entity(slot_uid)
      local texture = slot:get_texture()

      local texture_definition = get_texture_definition(texture)
      local columns = texture_definition.width / texture_definition.tile_width
      local rows = texture_definition.height / texture_definition.tile_height
      local sprite_row = math.floor(slot.animation_frame // rows)
      local sprite_column = math.floor(slot.animation_frame % columns)

      render_ctx:draw_screen_texture(texture, sprite_row, sprite_column, bounds, Color:new(1, 1, 1, 1))
    end
  end
end

--== Hooks ==--

register_option_int('pouch_size', 'Pouch capacity', 3, 1, 5)

set_callback(function ()
  init()
  set_callback(update, ON.FRAME)
  set_callback(ui, ON.RENDER_POST_HUD)
end, ON.START)