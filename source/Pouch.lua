---@alias StorableEntityMap table<ENT_TYPE, boolean>

---Items that can always be stored in the pouch
---@type StorableEntityMap
local STORABLE_ALWAYS <const> = {
  -- Weapons
  [ENT_TYPE.ITEM_WEBGUN] = true,
  [ENT_TYPE.ITEM_SHOTGUN] = true,
  [ENT_TYPE.ITEM_FREEZERAY] = true,
  [ENT_TYPE.ITEM_PLASMACANNON] = true,
  [ENT_TYPE.ITEM_CLONEGUN] = true,
  [ENT_TYPE.ITEM_CROSSBOW] = true,
  [ENT_TYPE.ITEM_CAMERA] = true,
  [ENT_TYPE.ITEM_TELEPORTER] = true,
  [ENT_TYPE.ITEM_HOUYIBOW] = true,

  -- Melee weapons
  [ENT_TYPE.ITEM_MATTOCK] = true,
  [ENT_TYPE.ITEM_BROKEN_MATTOCK] = true,
  [ENT_TYPE.ITEM_MACHETE] = true,
  [ENT_TYPE.ITEM_BOOMERANG] = true,
  [ENT_TYPE.ITEM_SCEPTER] = true,
  [ENT_TYPE.ITEM_EXCALIBUR] = true,
  [ENT_TYPE.ITEM_BROKENEXCALIBUR] = true,

  -- Shields
  [ENT_TYPE.ITEM_WOODEN_SHIELD] = true,
  [ENT_TYPE.ITEM_METAL_SHIELD] = true,

  -- Backpacks
  [ENT_TYPE.ITEM_CAPE] = true,
  [ENT_TYPE.ITEM_VLADS_CAPE] = true,
  [ENT_TYPE.ITEM_JETPACK] = true,
  [ENT_TYPE.ITEM_HOVERPACK] = true,
  [ENT_TYPE.ITEM_TELEPORTER_BACKPACK] = true,
  [ENT_TYPE.ITEM_POWERPACK] = true,

  -- Projectiles
  [ENT_TYPE.ITEM_WOODEN_ARROW] = true,
  [ENT_TYPE.ITEM_BROKEN_ARROW] = true,
  [ENT_TYPE.ITEM_LIGHT_ARROW] = true,
  [ENT_TYPE.ITEM_METAL_ARROW] = true,

  -- Keys
  [ENT_TYPE.ITEM_KEY] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST_KEY] = true,

  -- Containers
  [ENT_TYPE.ITEM_CRATE] = true,
  [ENT_TYPE.ITEM_CHEST] = true,
  [ENT_TYPE.ITEM_LOCKEDCHEST] = true,
  [ENT_TYPE.ITEM_POT] = true,
  [ENT_TYPE.ITEM_POTOFGOLD] = true,
  [ENT_TYPE.ITEM_VAULTCHEST] = true,
  [ENT_TYPE.ITEM_LAVAPOT] = true,
  [ENT_TYPE.ITEM_PRESENT] = true,

  -- Miscellaneous items
  [ENT_TYPE.ITEM_ROCK] = true,
  [ENT_TYPE.ITEM_SKULL] = true,
  [ENT_TYPE.ITEM_DIE] = true,
  [ENT_TYPE.ITEM_TORCH] = true,
  [ENT_TYPE.ITEM_EGGPLANT] = true,
  [ENT_TYPE.ITEM_CRABMAN_CLAW] = true,

  -- Critters (easter egg)
  [ENT_TYPE.MONS_CRITTERSNAIL] = true,
  [ENT_TYPE.MONS_CRITTERDUNGBEETLE] = true,
  [ENT_TYPE.MONS_CRITTERBUTTERFLY] = true,
  [ENT_TYPE.MONS_CRITTERFISH] = true,
  [ENT_TYPE.MONS_CRITTERCRAB] = true,
  [ENT_TYPE.MONS_CRITTERLOCUST] = true,
  [ENT_TYPE.MONS_CRITTERPENGUIN] = true,
  [ENT_TYPE.MONS_CRITTERFIREFLY] = true,
  [ENT_TYPE.MONS_CRITTERDRONE] = true,
  [ENT_TYPE.MONS_CRITTERSLIME] = true,
  [ENT_TYPE.MONS_CRITTERANCHOVY] = true,
}

---Idols that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_IDOLS <const> = {
  [ENT_TYPE.ITEM_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOL] = true,
  [ENT_TYPE.ITEM_MADAMETUSK_IDOLNOTE] = true,
  [ENT_TYPE.ITEM_USHABTI] = true,
}

---Pets that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_PETS <const> = {
  [ENT_TYPE.MONS_PET_DOG] = true,
  [ENT_TYPE.MONS_PET_CAT] = true,
  [ENT_TYPE.MONS_PET_HAMSTER] = true,
}

---Mounts that can be stored (based on settings)
---@type StorableEntityMap
local STORABLE_MOUNTS <const> = {
  [ENT_TYPE.MOUNT_TURKEY] = true,
  [ENT_TYPE.MOUNT_ROCKDOG] = true,
  [ENT_TYPE.MOUNT_AXOLOTL] = true,
  [ENT_TYPE.MOUNT_QILIN] = true,
}

---@class Sfx
---@field sound CustomSound
---@field pitch number
---@field volume number

---@type Sfx
local STORE <const> = {
  sound = (get_sound(VANILLA_SOUND.MOUNTS_MOUNT) --[[@as CustomSound]]),
  pitch = 1.1,
  volume = 1.2,
}

---@type Sfx
local INVALID <const> = {
  sound = (get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE) --[[@as CustomSound]]),
  pitch = 1.3,
  volume = 0.775,
}

---@param sfx Sfx
local function play_sfx(sfx)
  local playing_sound = sfx.sound:play(true)
  playing_sound:set_pitch(sfx.pitch)
  playing_sound:set_volume(sfx.volume)
  playing_sound:set_pause(false)
end

---@param uid integer
---@return boolean
local function is_storable(uid)
  local entity = get_entity(uid)
  local type = entity.type.id
  ---@diagnostic disable-next-line undefined-field
  if entity.get_short_name ~= nil then
    return false --is player
  end
  if STORABLE_ALWAYS[type] then
    return true
  end
  if STORABLE_IDOLS[type] and options.idols_are_storable then
    return true
  end
  if test_flag(entity.flags, ENT_FLAG.DEAD) and options.monsters_are_storable then
    return true
  end
  if STORABLE_PETS[type] and options.pets_are_storable then
    return true
  end
  if STORABLE_MOUNTS[type] and options.mounts_are_storable then
    return (entity --[[@as Mount]]).tamed
  end
  return false
end

local Metadata = require("Metadata")

-- ==============================================================================

---@class Pouch
---@field max_size integer
---@field slots Metadata[]
local Pouch = {}
Pouch.__index = Pouch

---@param max_size integer
---@return Pouch
function Pouch.init(max_size)
  return setmetatable({
    max_size = max_size,
    slots = {},
  }, Pouch)
end

---@param player_uid integer
---@param held_uid integer
function Pouch:store(player_uid, held_uid)
  if #self.slots >= self.max_size or not is_storable(held_uid) then
    play_sfx(INVALID)
    return
  end

  table.insert(self.slots, 1, Metadata.init(held_uid))

  -- create pickup visual effect
  generate_particles(PARTICLEEMITTER.ITEMDUST, held_uid)

  -- play sound effect
  play_sfx(STORE)

  drop(player_uid, held_uid)
  get_entity(held_uid):destroy()
end

function Pouch:can_retrieve()
  if #self.slots == 0 then
    -- play sound effect
    play_sfx(INVALID)
    return false
  end
  return true
end

---@param player_uid integer
---@param slot_index integer?
function Pouch:retrieve(player_uid, slot_index)
  if not self:can_retrieve() then
    return
  end

  slot_index = slot_index ~= nil and slot_index or 1

  local _, _, layer = get_position(player_uid)
  local held_uid = table.remove(self.slots, slot_index):spawn(layer)
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
    local x, y, layer = get_position(player_uid)
    local entity_id = table.remove(self.slots, 1):spawn(layer)
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

-- ==============================================================================

return Pouch
