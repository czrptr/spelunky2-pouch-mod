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
function Metadata:from_entity(uid)
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
    health = (entity --[[@as Movable]]).health,
    is_dead = test_flag(entity.flags, ENT_FLAG.DEAD),
    texture = texture,
    sprite_row = sprite_row,
    sprite_column = sprite_column,
  }, Metadata)
end

---@param uid integer
---@param velocity_x? number
---@param velocity_y? number
---@return integer
function Metadata:spawn_at(uid, velocity_x, velocity_y)
  local x, y, l = get_position(uid)
  local entity_uid = spawn_entity(self.type, x, y, l, velocity_x or 0, velocity_y or 0)
  local entity = get_entity(entity_uid)
  entity:apply_metadata(self.flags)
  entity.animation_frame = self.animation_frame
  if self.health ~= nil then
    (entity --[[@as Movable]]).health = self.health
  end
  if self.is_dead then
    entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
  end
  return entity_uid
end

return Metadata
