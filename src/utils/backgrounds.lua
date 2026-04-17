function SMODS.create_bg_canvasses()
    if SMODS.BG_CANVAS_1 then SMODS.BG_CANVAS_1:remove(); SMODS.BG_CANVAS_1 = nil end
    if SMODS.BG_CANVAS_2 then SMODS.BG_CANVAS_2:remove(); SMODS.BG_CANVAS_2 = nil end
    SMODS.background_queue = {}

    local w, h = G.CANVAS:getDimensions()
    SMODS.BG_CANVAS_1 = SMODS.BackgroundCanvas(-30, -13, w, h, SMODS.Background:get_current_background())
    SMODS.BG_CANVAS_2 = SMODS.BackgroundCanvas(-30, -13, w, h, nil, 0)

    SMODS.PRIMARY_BG_CANVAS = SMODS.BG_CANVAS_1
end

function SMODS.draw_background()
    local primary_canvas   = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_1 or SMODS.BG_CANVAS_2
    local secondary_canvas = SMODS.PRIMARY_BG_CANVAS == SMODS.BG_CANVAS_1 and SMODS.BG_CANVAS_2 or SMODS.BG_CANVAS_1

    primary_canvas:draw()
    secondary_canvas:draw()
end

SMODS.background_queue = {}
SMODS.is_bg_fading = false

function SMODS.update_background()
    -- queue bg fades
    local cur_bg = SMODS.Background:get_current_background()
    if
        SMODS.PRIMARY_BG_CANVAS and SMODS.PRIMARY_BG_CANVAS.prototype and SMODS.PRIMARY_BG_CANVAS.prototype.key ~= cur_bg.key
        and SMODS.background_queue[#SMODS.background_queue] ~= cur_bg.key
    then
        SMODS.background_queue[#SMODS.background_queue+1] = cur_bg.key
    end

    -- handle fade queue
    if not SMODS.is_bg_fading and #SMODS.background_queue > 0 then
        local bg = SMODS.Backgrounds[table.remove(SMODS.background_queue, 1)]
        SMODS.switch_background(bg)
    end
end

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
    old_canvas:ease_alpha(0, bg.fade_time, bg.fade_ease)
    new_canvas.alpha = 1
end
