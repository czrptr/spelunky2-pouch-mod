---@meta

---@param name string
---@param desc string
---@param value integer
---@param min integer
---@param max integer
---@return nil
function register_option_int(name, desc, value, min, max) end

---@class TextureDefinition
TextureDefinition = nil

---@return TextureDefinition
function TextureDefinition.new() end

---@param particle_emitter_id PARTICLEEMITTER
---@param uid integer
function generate_particles(particle_emitter_id, uid) end