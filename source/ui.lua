--- module
local ui = {}

-- forced by the engine
local ASPECT_RATIO <const> = 16 / 9

---@param texture_path string
---@param width integer
---@param height integer
---@return TEXTURE
local function create_texture(texture_path, width, height)
  local texture_def = TextureDefinition.new()
  texture_def.texture_path = texture_path
  texture_def.width = width
  texture_def.height = height
  texture_def.tile_width = width
  texture_def.tile_height = height
  return define_texture(texture_def)
end

---@param width number
---@param texture_aspect_ratio number
---@return number
local function screen_height(width, texture_aspect_ratio)
  return width / texture_aspect_ratio * ASPECT_RATIO
end

local SLOT <const> = (function()
  local TEXTURE_WIDTH = 100
  local TEXTURE_HEIGHT = 100
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.035
  local ICON_ZOOM_X = 0.01

  return {
    BASE_X = -0.9625,
    BASE_Y = 0.67,
    PLAYER_STRIDE = 0.32,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    MARGIN = 0.0035,
    BACKGROUND_ALPHA = 0.35,
    ICON_ALPHA = 0.5,
    ICON_ZOOM = Vec2:new(ICON_ZOOM_X, ICON_ZOOM_X * ASPECT_RATIO),
    TEXTURE = create_texture("assets/slot.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
  }
end)()

local FLOATING_SLOT <const> = {
  SIZE = 0.5,
  MARGIN = 0.6,
  OFFSET = 0.7,
  ICON_ZOOM = 0.05,
  SELECTED_ZOOM = 0.2,
  ICON_ALPHA = 0.75,
  BACKGROUND_ALPHA = 0.5,
}

function FLOATING_SLOT.total_width(slot_count)
  return slot_count * FLOATING_SLOT.SIZE + (slot_count - 1) * (FLOATING_SLOT.MARGIN - FLOATING_SLOT.SIZE)
end

local POUCH <const> = (function()
  local TEXTURE_WIDTH = 251
  local TEXTURE_HEIGHT = 233
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.07

  return {
    BASE_X = -0.89,
    BASE_Y = -0.98,
    PLAYER_STRIDE = 0.32,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    TEXTURE = create_texture("assets/pouch.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
  }
end)()

local CANVAS <const> = (function()
  local TEXTURE_WIDTH = 313
  local TEXTURE_HEIGHT = 157
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.233
  local ICON_ZOOM_X = -0.002
  local SLOT_ZOOM_X = 0.015

  return {
    BASE_X = POUCH.BASE_X + 0.005,
    BASE_Y = POUCH.BASE_Y + 0.02,
    WIDTH = WIDTH,
    ICON_ANGLE = -0.2,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    ICON_ZOOM = Vec2:new(ICON_ZOOM_X, ICON_ZOOM_X * ASPECT_RATIO),
    SLOT_ZOOM = Vec2:new(SLOT_ZOOM_X, SLOT_ZOOM_X * ASPECT_RATIO),
    ICON_OFFSET = Vec2:new(-0.025, 0.01),
    TEXTURE = create_texture("assets/canvas.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
    SLOT_OFFSET = {
      { X = 0.025, Y = 0.113 },
      { X = 0.075, Y = 0.028 },
      { X = 0.075, Y = 0.113 },
      { X = 0.125, Y = 0.028 },
      { X = 0.125, Y = 0.113 },
      { X = 0.175, Y = 0.028 },
      { X = 0.175, Y = 0.113 },
    },
  }
end)()

---@param left number
---@param bottom number
---@param width number
---@param height number
---@return AABB
local function bounds_from(left, bottom, width, height)
  return AABB:new(left, bottom + height, left + width, bottom)
end

---@param render_context VanillaRenderContext
---@param texture_id integer
---@param bounds AABB
---@param alpha number
local function draw_screen_texture(render_context, texture_id, bounds, alpha)
  render_context:draw_screen_texture(
    texture_id, 0, 0, bounds, Color:new(1, 1, 1, alpha))
end

---@param render_context VanillaRenderContext
---@param metadata Metadata
---@param bounds AABB
---@param alpha number
---@param zoom Vec2
local function draw_screen_metadata(render_context, metadata, bounds, alpha, zoom)
  render_context:draw_screen_texture(
    metadata.texture, metadata.sprite_row, metadata.sprite_column,
    bounds:extrude(zoom.x, zoom.y), Color:new(1, 1, 1, alpha))
end

---@param render_context VanillaRenderContext
---@param texture_id integer
---@param bounds AABB
---@param alpha number
local function draw_world_texture(render_context, texture_id, bounds, alpha)
  render_context:draw_world_texture(
    texture_id, 0, 0, bounds, Color:new(1, 1, 1, alpha))
end

---@param render_context VanillaRenderContext
---@param metadata Metadata
---@param bounds AABB
---@param alpha number
---@param zoom number
local function draw_world_metadata(render_context, metadata, bounds, alpha, zoom)
  render_context:draw_world_texture(
    metadata.texture, metadata.sprite_row, metadata.sprite_column,
    bounds:extrude(zoom), Color:new(1, 1, 1, alpha))
end
-- ==============================================================================

---@param render_context VanillaRenderContext
function ui.render_slots(render_context)
  if pause:get_pause() ~= PAUSE_TYPE.NONE then
    return
  end

  for pdx, player in ipairs(get_local_players()) do
    local player_offset = SLOT.PLAYER_STRIDE * (pdx - 1)
    local total_width = FLOATING_SLOT.total_width(#player.user_data.pouch.slots)
    for sdx = 1, player.user_data.pouch.max_size do
      local slot_offset = (SLOT.WIDTH + SLOT.MARGIN) * (sdx - 1)
      local base_x = SLOT.BASE_X + slot_offset + player_offset
      local bounds = bounds_from(base_x, SLOT.BASE_Y, SLOT.WIDTH, SLOT.HEIGHT)
      draw_screen_texture(render_context, SLOT.TEXTURE, bounds, SLOT.BACKGROUND_ALPHA)

      local metadata = player.user_data.pouch.slots[sdx]
      if metadata ~= nil then
        draw_screen_metadata(render_context, metadata, bounds, SLOT.ICON_ALPHA, SLOT.ICON_ZOOM)

        if player.user_data.is_retrieving then
          local bounds = bounds_from(
            player.x - total_width / 2 + FLOATING_SLOT.MARGIN * (sdx - 1),
            player.y - FLOATING_SLOT.SIZE / 2 + FLOATING_SLOT.OFFSET,
            FLOATING_SLOT.SIZE, FLOATING_SLOT.SIZE)
          local zoom =
              (player.user_data.selected_slot == sdx)
              and FLOATING_SLOT.SELECTED_ZOOM or FLOATING_SLOT.ICON_ZOOM

          draw_world_texture(render_context, SLOT.TEXTURE, bounds, FLOATING_SLOT.BACKGROUND_ALPHA)
          draw_world_metadata(render_context, metadata, bounds, FLOATING_SLOT.ICON_ALPHA, zoom)
        end
      end
    end
  end
end

---@param render_context VanillaRenderContext
function ui.render_cards(render_context)
  for pdx, player in ipairs(get_local_players()) do
    local player_offset = SLOT.PLAYER_STRIDE * (pdx - 1)
    local bounds = bounds_from(CANVAS.BASE_X + player_offset, CANVAS.BASE_Y, CANVAS.WIDTH, CANVAS.HEIGHT)
    draw_screen_texture(render_context, CANVAS.TEXTURE, bounds, 1)

    bounds = bounds_from(POUCH.BASE_X + player_offset, POUCH.BASE_Y, POUCH.WIDTH, POUCH.HEIGHT)
    draw_screen_texture(render_context, POUCH.TEXTURE, bounds, 1)

    bounds = bounds:extrude(CANVAS.ICON_ZOOM.x, CANVAS.ICON_ZOOM.y):offset(CANVAS.ICON_OFFSET.x, CANVAS.ICON_OFFSET.y)
    render_context:draw_screen_texture(player:get_texture(), 9, 14, bounds, Color:white(), CANVAS.ICON_ANGLE, 0, 0)

    for sdx, metadata in ipairs(player.user_data.pouch.slots) do
      bounds = bounds_from(
        CANVAS.BASE_X + player_offset + CANVAS.SLOT_OFFSET[sdx].X,
        CANVAS.BASE_Y + CANVAS.SLOT_OFFSET[sdx].Y,
        SLOT.WIDTH, SLOT.HEIGHT)
      draw_screen_metadata(render_context, metadata, bounds, 1, CANVAS.SLOT_ZOOM)
    end
  end
end

-- ==============================================================================

return ui
