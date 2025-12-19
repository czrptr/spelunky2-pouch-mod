---@class Metadata
---@field type ENT_TYPE
---@field flags integer
---@field animation_frame integer
---@field health integer?
---@field is_dead boolean
---@field texture TEXTURE
---@field sprite_row integer
---@field sprite_column integer
local Metadata = {}
Metadata.__index = Metadata

---@param uid integer
---@return Metadata
function Metadata.init(uid)
  local entity = get_entity(uid)
  local texture = entity:get_texture()
  local texture_definition = get_texture_definition(texture)
  local columns = texture_definition.width / texture_definition.tile_width
  local rows = texture_definition.height / texture_definition.tile_height
  local sprite_row = math.floor(entity.animation_frame // rows)
  local sprite_column = math.floor(entity.animation_frame % columns)

  return setmetatable({
    type = entity.type.id,
    flags = get_entity(uid):get_metadata(),
    animation_frame = entity.animation_frame,
    ---@diagnostic disable-next-line: undefined-field
    health = entity.health,
    is_dead = test_flag(entity.flags, ENT_FLAG.DEAD),
    texture = texture,
    sprite_row = sprite_row,
    sprite_column = sprite_column,
  }, Metadata)
end

---@param entity Entity
---@return boolean
function Metadata.is_player(entity)
  ---@diagnostic disable-next-line undefined-field
  return entity ~= nil and entity.get_short_name ~= nil
end

---@param entity Entity
---@return boolean
function Metadata.is_backpack(entity)
  ---@diagnostic disable-next-line undefined-field
  return entity ~= nil and entity.explosion_trigger ~= nil
end

---@param layer LAYER
---@return integer
function Metadata:spawn(layer)
  local entity_uid = spawn_entity(self.type, 0, 0, layer, 0, 0)
  local entity = get_entity(entity_uid)
  entity:apply_metadata(self.flags)
  entity.animation_frame = self.animation_frame

  if self.health ~= nil then
    (entity --[[@as Movable]]).health = self.health
  end
  if self.is_dead then
    kill_entity(entity_uid, false)
  end

  return entity_uid
end

return Metadata
