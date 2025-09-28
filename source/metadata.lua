---@class Metadata
---@field type ENT_TYPE
---@field flags integer
---@field texture TEXTURE
---@field animation_frame integer
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
  }, Metadata)
end

---@param uid integer
---@return integer
function Metadata:spawn_at(uid)
  local x, y, l = get_position(uid)
  local entity_uid = spawn_entity(self.type, x, y, l, 0, 0)
  local entity = get_entity(entity_uid)
  entity:apply_metadata(self.flags)
  entity.animation_frame = self.animation_frame
  return entity_uid
end

return Metadata