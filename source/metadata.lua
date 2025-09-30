---@class Metadata
---@field type ENT_TYPE
---@field flags integer
---@field texture TEXTURE
---@field animation_frame integer
---@field health integer?
---@field is_dead boolean
local Metadata = {}
Metadata.__index = Metadata

---@param uid integer
---@return Metadata
function Metadata:from_entity(uid)
  local entity = get_entity(uid)
  return setmetatable({
    type = entity.type.id,
    flags = get_entity(uid):get_metadata(),
    texture = entity:get_texture(),
    animation_frame = entity.animation_frame,
    health = (entity --[[@as Movable]]).health,
    is_dead = test_flag(entity.flags, ENT_FLAG.DEAD),
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