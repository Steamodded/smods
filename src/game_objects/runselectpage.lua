SMODS.RunSelectPage = SMODS.GameObject:extend({
    obj_table = SMODS.RunSelect.Pages,
    set = 'RunSelectPages',
    obj_buffer = {},
    disable_mipmap = false,
    required_params = {
        'key',
    },
    amount = 10,
    selection_limit = 1,
    stack_size = 1,
    silent = false,
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        self.name = self.name or self.key
        SMODS.RunSelectPage.super.register(self)
    end,
    inject = function(self)
        self.page = self.page or (#SMODS.RunSelect.Internals.pages + 1)
        self.grid_size = self.grid_size or {2, 5}
        self.amount = self.grid_size[1] * self.grid_size[2] 
        if self.generate_pool then
            self.pool = self:generate_pool()
        end
        if not self.injected then
            if self.quick_start_text then
                table.insert(SMODS.RunSelect.Internals.quick_start_text_functions, self.quick_start_text)
            end
            table.insert(SMODS.RunSelect.Internals.pages, self.page, self.key)
            for i = self.page + 1, #SMODS.RunSelect.Internals.pages do
                SMODS.RunSelect.Pages[SMODS.RunSelect.Internals.pages[i]].page = SMODS.RunSelect.Pages[SMODS.RunSelect.Internals.pages[i]].page + 1
            end
            self.injected = true
        end
    end,
    process_loc_text = function() end,
    handle_choice = function(self, choice, remove)
        SMODS.RunSelect.Setup.choices[self.key] = SMODS.RunSelect.Setup.choices[self.key] or {}
        if not remove then
            if self.selection_limit > 1 then
                if SMODS.table_size(SMODS.RunSelect.Setup.choices[self.key]) < self.selection_limit and not SMODS.RunSelect.Setup.choices[self.key][choice.config.center.key] then
                    SMODS.RunSelect.Setup.choices[self.key][choice.config.center.key] = true
                else
                    if choice.juice_up then choice:juice_up() end
                    return
                end
            else
                SMODS.RunSelect.Setup.choices[self.key] = choice.config.center.key
            end
            if SMODS.RunSelect.Internals.preview_area then SMODS.RunSelect.Functions.populate_preview_ui(self.key, choice.config.center.key, self.silent) end
        else
            if self.selection_limit == 1 then
                SMODS.RunSelect.Setup.choices[self.key] = nil
            else
                SMODS.RunSelect.Setup.choices[self.key][choice.config.center.key] = nil
            end
            if SMODS.RunSelect.Internals.preview_area then SMODS.RunSelect.Functions.populate_preview_ui(self.key, choice, self.silent, true) end
        end
    end,
    set_default = function(self, choice)
        if self.selection_limit > 1 then
            if type(choice) ~= 'table' then choice = {choice} end
            local final = {}
            for i, k in ipairs(choice) do
                if G.P_CENTERS[k] then final[#final+1] = k end
            end
            return final
        end
        return G.P_CENTERS[choice] and choice
    end,
    selected_text = function(self, selection)
        if not selection then return end
        return localize({set = self.type, key = selection, type = 'name_text'})
    end,
    choose_random = function(self)
        local options = {}
        for i=1, #self.pool do
            if self.pool[i].unlocked then
                options[#options + 1] = self.pool[i].key
            end
        end
        if self.selection_limit > 1 then
            for k,_ in pairs(SMODS.RunSelect.Setup.choices[self.key]) do
                SMODS.RunSelect.Setup.choices[self.key][k] = nil
                SMODS.RunSelect.Functions.populate_preview_ui(self.key, SMODS.RunSelect.Internals.preview_area.cards[1], self.silent, true)
            end
        end
        for i=1, self.selection_limit do
            local selected = false
            while not selected do
                selected = pseudorandom_element(options, pseudoseed(os.time()))
                if (selected == SMODS.RunSelect.Setup.choices[self.key] or SMODS.RunSelect.Setup.choices[self.key][selected]) and #options > 1 then selected = false end
            end
            play_sound('whoosh1', math.random()*0.2 + 0.99, 0.35)
            self:handle_choice({config = {center = {key = selected}}})
        end
    end
})

local function stick(card)
    card.children.back.states.hover = card.states.hover
    card.children.back.states.click = card.states.click
    card.children.back.states.drag = card.states.drag
    card.children.back.states.collide.can = false
    card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})
end

SMODS.RunSelectPage({
    key = 'deck_choice',
    type = 'Back',
    area_type = 'deck',
    automatic_preview = true,
    random_select = true,
    pool = G.P_CENTER_POOLS.Back,
    stack_size = 10,
    preview_size = 52,
    quick_start_text = function()
        if not G.P_CENTERS[G.PROFILES[G.SETTINGS.profile].last_choices.deck_choice] then G.PROFILES[G.SETTINGS.profile].last_choices.deck_choice = 'b_red' end
        return localize({type = 'name_text', set = 'Back', key = G.PROFILES[G.SETTINGS.profile].last_choices.deck_choice})
    end,
    set_default = function(self, choice)
        return G.P_CENTERS[choice] and choice or 'b_red'
    end,
    create_selection_card = function(self, card_key, card_number, area)
        local card = Card(area.T.x, area.T.y, G.CARD_W, G.CARD_H, nil, G.P_CENTERS[card_key] or G.P_CENTERS.b_red)
        card.sprite_facing = 'back'
        card.facing = 'back'
        card.children.back:remove()
        card.children.back = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[card.config.center.unlocked and card.config.center.atlas or 'centers'], card.config.center.unlocked and card.config.center.pos or {x = 4, y = 0})
        stick(card)
        if card_number == self.stack_size then
            card.sticker = get_deck_win_sticker(card.config.center)
        end
        return card
    end
})

SMODS.RunSelectPage({
    key = 'stake_choice',
    include_deck_preview = true,
    include_stake_tower = true,
    area_type = 'deck',
    grid_size = {4, 8},
    random_select = true,
    type = 'Stake',
    generate_pool = function(self)
        return G.P_CENTER_POOLS.Stake
    end,
    sprite_size = {w = 0.99, h = 0.99},
    quick_start_text = function()
        if (G.PROFILES[G.SETTINGS.profile].last_choices.stake_choice or 1) > #G.P_CENTER_POOLS.Stake then G.PROFILES[G.SETTINGS.profile].last_choices.stake_choice = 1 end
        return localize({type = 'name_text', set = 'Stake', key = G.P_CENTER_POOLS.Stake[(G.PROFILES[G.SETTINGS.profile].last_choices.stake_choice or 1)].key})
    end,
    set_default = function(self, choice)
        if not choice or choice > #G.P_CENTER_POOLS.Stake then return 1 else return self.is_stake_unlocked(G.P_CENTER_POOLS.Stake[choice]) and choice or 1 end
    end,
    handle_choice = function(self, choice, remove)
        SMODS.RunSelect.Setup.choices[self.key] = choice
        G.E_MANAGER:clear_queue('run_select')
        SMODS.RunSelect.Functions.populate_stake_tower(choice)
    end,
    is_stake_unlocked = function(stake)
        local unlocked = true
        local save_data = G.PROFILES[G.SETTINGS.profile].deck_usage[SMODS.RunSelect.Setup.choices.deck_choice] and G.PROFILES[G.SETTINGS.profile].deck_usage[SMODS.RunSelect.Setup.choices.deck_choice].wins_by_key or {}
        for _,v in ipairs(stake.applied_stakes or {}) do
            if not G.PROFILES[G.SETTINGS.profile].all_unlocked and (not save_data or (save_data and not save_data[v])) then
                unlocked = false
            end
        end
        if save_data and save_data[stake.key] then
            return true, true
        end
        return unlocked
    end,
    create_selection_card = function(self, stake_key, card_number, area)
        local card = Card(area.T.x, area.T.y, self.sprite_size.w, self.sprite_size.h, nil, G.P_CENTERS.j_joker, {stake = stake_key})
        card.no_shadow = true
        card.facing = 'back'
        card.sprite_facing = 'back'
        card.config.center = G.P_STAKES[stake_key]

        local unlocked, won = self.is_stake_unlocked(G.P_STAKES[stake_key])
        -- TODO: check this with new save strucutre
        

        if not unlocked then
            card.params.stake_chip_locked = true
        end
        card.children.back:remove()
        card.children.back = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, unlocked and G.P_STAKES[stake_key].atlas or 'locked_stake', unlocked and G.P_STAKES[stake_key].pos or {x=0, y=0})
        card.children.back.draw = function(_sprite)
            _sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
            _sprite.ARGS.send_to_shader[1] = math.min(_sprite.VT.r*3, 1) + G.TIMERS.REAL/(18) + (_sprite.juice and _sprite.juice.r*20 or 0) + 1
            _sprite.ARGS.send_to_shader[2] = G.TIMERS.REAL

            if won or area == SMODS.RunSelect.Internals.stake_tower_holding then
                Sprite.draw_shader(_sprite, 'dissolve')
                if card.config.center.shiny then Sprite.draw_shader(_sprite, 'voucher', nil, _sprite.ARGS.send_to_shader) end
            else
                Sprite.draw_shader(_sprite, 'played') 
                G.BRUTE_OVERLAY = {0.4, 0.4, 0.4, 0.4}
                if card.config.center.shiny then Sprite.draw_shader(_sprite, 'negative_shine', nil, _sprite.ARGS.send_to_shader) end
                G.BRUTE_OVERLAY = nil
            end
        end

        stick(card)
        return card
    end,
    choose_random = function(self)
        local selected = false
        local options = {}
        for i=1, #self.pool do
            local unlocked = self.is_stake_unlocked(G.P_CENTER_POOLS.Stake[i])
            -- TODO: check this with new save strucutre
            
            if unlocked then
                options[#options + 1] = i
            end
        end
        while not selected do
            selected = pseudorandom_element(options, pseudoseed(os.time()))
            if selected == SMODS.RunSelect.Setup.choices[self.key] and #options > 1 then selected = false end
        end
        play_sound('whoosh1', math.random()*0.2 + 0.99, 0.35)
        self:handle_choice(selected)
    end
})

SMODS.Atlas({ -- art by nekojoe
    key = 'locked_stake',
    path = 'locked_stake.png',
    px = 29,
    py = 29
})