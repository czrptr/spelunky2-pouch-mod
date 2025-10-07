--- module
local ui = {}

-- forced by the engine
local ASPECT_RATIO <const> = 16 / 9

---@param texture_path string Path to texture file
---@param width integer Texture width in pixels
---@param height integer Texture height in pixels
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

---@param width number Screen-space width
---@param texture_aspect_ratio number Width/height ratio of texture
---@return number height Screen-space height
local function screen_height(width, texture_aspect_ratio)
  return width / texture_aspect_ratio * ASPECT_RATIO
end

local SLOT <const> = (function()
  local TEXTURE_WIDTH = 100
  local TEXTURE_HEIGHT = 100
  local TEXTURE_ASPECT_RATIO = TEXTURE_WIDTH / TEXTURE_HEIGHT
  local WIDTH = 0.035
  local ICON_ZOOM_X = 0.008

  return {
    BASE_X = -0.9625,
    BASE_Y = 0.67,
    PLAYER_STRIDE = 0.32,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    MARGIN = 0.0035,
    BACKGROUND_ALPHA = 0.35,
    ICON_ALPHA = 0.5,
    SELECTED_ICON_ALPHA = 0.75,
    ICON_ZOOM_X = ICON_ZOOM_X,
    ICON_ZOOM_Y = ICON_ZOOM_X * ASPECT_RATIO,
    TEXTURE = create_texture("assets/slot.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
  }
end)()

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

  return {
    BASE_X = POUCH.BASE_X + 0.005,
    BASE_Y = POUCH.BASE_Y + 0.02,
    WIDTH = WIDTH,
    HEIGHT = screen_height(WIDTH, TEXTURE_ASPECT_RATIO),
    TEXTURE = create_texture("assets/canvas.png", TEXTURE_WIDTH, TEXTURE_HEIGHT),
    SLOT_POSITIONS = {
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

-- ==============================================================================

---@param render_context VanillaRenderContext
local function render_slots(render_context)
  for idx, player in ipairs(get_local_players()) do
    for jdx = 1, options.pouch_size do
      local bounds = bounds_from(
        SLOT.BASE_X
        + (SLOT.WIDTH + SLOT.MARGIN) * (jdx - 1)
        + SLOT.PLAYER_STRIDE * (idx - 1),
        SLOT.BASE_Y,
        SLOT.WIDTH,
        SLOT.HEIGHT
      )
      render_context:draw_screen_texture(
        SLOT.TEXTURE, 0, 0, bounds, Color:new(1, 1, 1, SLOT.BACKGROUND_ALPHA))

      local icon_alpha = SLOT.ICON_ALPHA
      if player.user_data.is_retrieving and player.user_data.selected_slot == jdx then
        local zoom = 0.008
        icon_alpha = SLOT.SELECTED_ICON_ALPHA
        bounds = bounds:extrude(zoom, zoom * ASPECT_RATIO)
      end

      local metadata = player.user_data.pouch.slots[jdx]
      if metadata ~= nil then
        bounds = bounds:extrude(
          SLOT.ICON_ZOOM_X, SLOT.ICON_ZOOM_Y)
        render_context:draw_screen_texture(
          metadata.texture, metadata.sprite_row, metadata.sprite_column,
          bounds, Color:new(1, 1, 1, icon_alpha))

        if player.user_data.is_retrieving then
          local SIZE = 0.5
          local OFFSET = 0.7
          local MARGIN = 0.6
          bounds = bounds_from(
            player.x - SIZE / 2 + (jdx - 1) * MARGIN,
            player.y - SIZE / 2 + OFFSET,
            SIZE, SIZE)
          render_context:draw_world_texture(
            SLOT.TEXTURE, 0, 0, bounds, Color:new(1, 1, 1, 0.5))

          if player.user_data.selected_slot == jdx then
            bounds = bounds:extrude(0.2)
          end

          render_context:draw_world_texture(
            metadata.texture, metadata.sprite_row, metadata.sprite_column, bounds, Color:new(1, 1, 1, 0.75))
        end
      end
    end
  end
end

---@param render_context VanillaRenderContext
local function render_cards(render_context)
  for idx, player in ipairs(get_local_players()) do
    local bounds = bounds_from(
      CANVAS.BASE_X
      + POUCH.PLAYER_STRIDE * (idx - 1),
      CANVAS.BASE_Y,
      CANVAS.WIDTH,
      CANVAS.HEIGHT
    )
    render_context:draw_screen_texture(
      CANVAS.TEXTURE, 0, 0, bounds, Color:white())

    bounds = bounds_from(
      POUCH.BASE_X
      + POUCH.PLAYER_STRIDE * (idx - 1),
      POUCH.BASE_Y,
      POUCH.WIDTH,
      POUCH.HEIGHT
    )
    render_context:draw_screen_texture(
      POUCH.TEXTURE, 0, 0, bounds, Color:white())

    local zoom = -0.002
    bounds = bounds:extrude(zoom, zoom * ASPECT_RATIO):offset(-0.025, 0.01)
    render_context:draw_screen_texture(
      player:get_texture(), 9, 14, bounds, Color:white(), -0.2, 0, 0)

    for jdx, metadata in ipairs(player.user_data.pouch.slots) do
      bounds = bounds_from(
        CANVAS.BASE_X
        + POUCH.PLAYER_STRIDE * (idx - 1)
        + CANVAS.SLOT_POSITIONS[jdx].X,
        CANVAS.BASE_Y
        + CANVAS.SLOT_POSITIONS[jdx].Y,
        SLOT.WIDTH,
        SLOT.HEIGHT
      )
      zoom = 0.015
      bounds = bounds:extrude(zoom, zoom * ASPECT_RATIO)
      render_context:draw_screen_texture(
        metadata.texture, metadata.sprite_row, metadata.sprite_column, bounds, Color:white())
    end
  end
end

-- ==============================================================================

---@param get_is_in_transition fun(): boolean
function ui.using(get_is_in_transition)
  ---@param render_context VanillaRenderContext
  local function render(render_context)
    if get_is_in_transition() then
      render_cards(render_context)
    elseif pause:get_pause() == PAUSE_TYPE.NONE then
      render_slots(render_context)
    end
  end

  -- resulting module
  return {
    render = render
  }
end

return ui
