---@meta

---Add an integer option that the user can change in the UI. Read with `options.name`, `value` is the default. Keep in mind these are just soft
---limits, you can override them in the UI with double click.
---@param name string
---@param desc string
---@param value integer
---@param min integer
---@param max integer
function register_option_int(name, desc, value, min, max) end

---Add a boolean option that the user can change in the UI. Read with `options.name`, `value` is the default.
---@param name string
---@param desc string
---@param value boolean
function register_option_bool(name, desc, value) end

---@class TextureDefinition
TextureDefinition = nil

---@return TextureDefinition
function TextureDefinition.new() end

---@param particle_emitter_id PARTICLEEMITTER
---@param uid integer
function generate_particles(particle_emitter_id, uid) end