function SMODS.create_bg_canvasses()
    if SMODS.BG_CANVAS_1 then SMODS.BG_CANVAS_1:remove(); SMODS.BG_CANVAS_1 = nil end
    if SMODS.BG_CANVAS_2 then SMODS.BG_CANVAS_2:remove(); SMODS.BG_CANVAS_2 = nil end

    local w, h = G.CANVAS:getDimensions()
    SMODS.BG_CANVAS_1 = SMODS.BackgroundCanvas(-30, -13, w, h, SMODS.Background:get_current_background())
    SMODS.BG_CANVAS_2 = SMODS.BackgroundCanvas(-30, -13, w, h, nil, 0)

    SMODS.PRIMARY_BG_CANVAS = SMODS.BG_CANVAS_1
end

SMODS.PRIMARY_BG_CANVAS = SMODS.BG_CANVAS_1

function SMODS.switch_background(bg)
    local w, h = G.CANVAS:getDimensions()
    SMODS.BG_CANVAS_1 = SMODS.BG_CANVAS_1 or SMODS.BackgroundCanvas(-30, -13, w, h)
    SMODS.BG_CANVAS_2 = SMODS.BG_CANVAS_2 or SMODS.BackgroundCanvas(-30, -13, w, h)

    local new_canvas = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_2 or SMODS.BG_CANVAS_1
    local old_canvas = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_1 or SMODS.BG_CANVAS_2

    -- set new canvas
    SMODS.PRIMARY_BG_CANVAS = new_canvas
    new_canvas:set_active_bg(bg)

    -- fade out old canvas
    old_canvas:ease_alpha(0, 2)
    new_canvas.alpha = 1
end

function SMODS.draw_background()
    local primary_canvas = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_1 or SMODS.BG_CANVAS_2
    local secondary_canvas = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_2 or SMODS.BG_CANVAS_1

    primary_canvas:draw()
    secondary_canvas:draw()
end