--- STEAMODDED CORE
--- OVERRIDES

--#region blind UI
-- Recreate all lines of the blind description.
-- This callback is called each frame.
---@param e {}
--**e** Is the UIE that called this function
G.FUNCS.HUD_blind_debuff = function(e)
	local scale = 0.4
	local num_lines = #G.GAME.blind.loc_debuff_lines
	while G.GAME.blind.loc_debuff_lines[num_lines] == '' do
		num_lines = num_lines - 1
	end
	local padding = 0.05
	if num_lines > 5 then
		local excess_height = (0.3 + padding)*(num_lines - 5)
		padding = padding - excess_height / (num_lines + 1)
	end
	e.config.padding = padding
	if num_lines > #e.children then
		for i = #e.children+1, num_lines do
			local node_def = {n = G.UIT.R, config = {align = "cm", minh = 0.3, maxw = 4.2}, nodes = {
				{n = G.UIT.T, config = {ref_table = G.GAME.blind.loc_debuff_lines, ref_value = i, scale = scale * 0.9, colour = G.C.UI.TEXT_LIGHT}}}}
			e.UIBox:set_parent_child(node_def, e)
		end
	elseif num_lines < #e.children then
		for i = num_lines+1, #e.children do
			e.children[i]:remove()
			e.children[i] = nil
		end
	end
	e.UIBox:recalculate()
	assert(G.HUD_blind == e.UIBox)
end

function create_UIBox_your_collection_blinds(exit)
	local min_ante = 1
	local max_ante = 16
	local spacing = 1 - 15*0.06
	if G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante then
		local current_ante = G.GAME.round_resets.ante

		if current_ante > 8 then
			min_ante = current_ante - 8 + 1
			max_ante = current_ante + 8
		end
	end
	local ante_amounts = {}
	for i = min_ante, max_ante do
		if i > 1 then
			ante_amounts[#ante_amounts + 1] = { n = G.UIT.R, config = { minh = spacing }, nodes = {} }
		end
		local blind_chip = Sprite(0, 0, 0.2, 0.2, G.ASSET_ATLAS["ui_" .. (G.SETTINGS.colourblind_option and 2 or 1)],
			{ x = 0, y = 0 })
		blind_chip.states.drag.can = false
		ante_amounts[#ante_amounts + 1] = {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.03 },
			nodes = {
				{
					n = G.UIT.C,
					config = { align = "cm", minw = 0.7 },
					nodes = {
						{ n = G.UIT.T, config = { text = i, scale = 0.4, colour = G.C.FILTER, shadow = true } },
					}
				},
				{
					n = G.UIT.C,
					config = { align = "cr", minw = 2.8 },
					nodes = {
						{ n = G.UIT.O, config = { object = blind_chip } },
						{ n = G.UIT.C, config = { align = "cm", minw = 0.03, minh = 0.01 },                                                                                                                                  nodes = {} },
						{ n = G.UIT.T, config = { text = number_format(get_blind_amount(i)), scale = 0.4, colour = i <= G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt and G.C.RED or G.C.JOKER_GREY, shadow = true } },
					}
				}
			}
		}
	end

	local rows = 6
	local cols = 5
	local page = 1
	local deck_tables = {}

	G.your_collection = {}
	for j = 1, rows do
		G.your_collection[j] = CardArea(
			G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
			cols * 1.55,
			0.95 * 1.33,
			{ card_limit = cols, type = 'title_2', highlight_limit = 0, collection = true })
		table.insert(deck_tables,
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0, no_fill = true },
				nodes = {
					j%2 == 0 and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or nil,
					{ n = G.UIT.O, config = { object = G.your_collection[j] } },
					j%2 == 1 and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or nil,
				}
			}
		)
	end

	local blind_tab = SMODS.collection_pool(G.P_BLINDS)
	local blinds_amt = #blind_tab

	local this_page = {}
	for i, v in ipairs(blind_tab) do
		if i > rows*cols*(page-1) and i <= rows*cols*page then
			table.insert(this_page, v)
		elseif i > rows*cols*page then
			break
		end
	end
	blind_tab = this_page

	local blinds_to_be_alerted = {}
	local row, col = 1, 1
	for k, v in ipairs(blind_tab) do
		local temp_blind = AnimatedSprite(G.your_collection[row].T.x + G.your_collection[row].T.w/2, G.your_collection[row].T.y, 1.3, 1.3, G.ANIMATION_ATLAS[v.discovered and v.atlas or 'blind_chips'],
			v.discovered and v.pos or G.b_undiscovered.pos)
		temp_blind.states.click.can = false
		temp_blind.states.drag.can = false
		temp_blind.states.hover.can = true
		local card = Card(G.your_collection[row].T.x + G.your_collection[row].T.w/2, G.your_collection[row].T.y, 1.3, 1.3, G.P_CARDS.empty, G.P_CENTERS.c_base)
		temp_blind.states.click.can = false
		card.states.drag.can = false
		card.states.hover.can = true
		card.children.center = temp_blind
		temp_blind:set_role({major = card, role_type = 'Glued', draw_major = card})
		card.set_sprites = function(...)
			local args = {...}
			if not args[1].animation then return end -- fix for debug unlock
			local c = card.children.center
			Card.set_sprites(...)
			card.children.center = c
		end
		temp_blind:define_draw_steps({
			{ shader = 'dissolve', shadow_height = 0.05 },
			{ shader = 'dissolve' }
		})
		temp_blind.float = true
		card.states.collide.can = true
		card.config.blind = v
		card.config.force_focus = true
		if v.discovered and not v.alerted then
			blinds_to_be_alerted[#blinds_to_be_alerted + 1] = card
		end
		card.hover = function()
			if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
				if not card.hovering and card.states.visible then
					card.hovering = true
					card.hover_tilt = 3
					card:juice_up(0.05, 0.02)
					play_sound('chips1', math.random() * 0.1 + 0.55, 0.12)
					card.config.h_popup = create_UIBox_blind_popup(v, card.config.blind.discovered)
					card.config.h_popup_config = card:align_h_popup()
					Node.hover(card)
					if card.children.alert then
						card.children.alert:remove()
						card.children.alert = nil
						card.config.blind.alerted = true
						G:save_progress()
					end
				end
			end
			card.stop_hover = function()
				card.hovering = false; Node.stop_hover(card); card.hover_tilt = 0
			end
		end
		G.your_collection[row]:emplace(card)
		col = col + 1
		if col > cols then col = 1; row = row + 1 end
	end

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = (function()
			for _, v in ipairs(blinds_to_be_alerted) do
				v.children.alert = UIBox {
					definition = create_UIBox_card_alert(),
					config = { align = "tri", offset = { x = 0.1, y = 0.1 }, parent = v }
				}
				v.children.alert.states.collide.can = false
			end
			return true
		end)
	}))

	local page_options = {}
	for i = 1, math.ceil(blinds_amt/(rows*cols)) do
		table.insert(page_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(blinds_amt/(rows*cols))))
	end

	local extras = nil
    local t = create_UIBox_generic_options({
		colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).colour) or nil,
        bg_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour) or nil,
        back_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).back_colour) or nil,
		back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or exit or 'your_collection',
		contents = {
			{
				n = G.UIT.C,
				config = { align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, padding = 0.1, force_focus = true, focus_args = { nav = 'tall' } },
						nodes = {
							{
								n = G.UIT.R,
								config = { align = "cm", padding = 0.05 },
								nodes = {
									{
										n = G.UIT.C,
										config = { align = "cm", minw = 0.7 },
										nodes = {
											{ n = G.UIT.T, config = { text = localize('k_ante_cap'), scale = 0.4, colour = lighten(G.C.FILTER, 0.2), shadow = true } },
										}
									},
									{
										n = G.UIT.C,
										config = { align = "cr", minw = 2.8 },
										nodes = {
											{ n = G.UIT.T, config = { text = localize('k_base_cap'), scale = 0.4, colour = lighten(G.C.RED, 0.2), shadow = true } },
										}
									}
								}
							},
							{ n = G.UIT.R, config = { align = "cm" }, nodes = ante_amounts }
						}
					},
					{
						n = G.UIT.C,
						config = { align = 'cm' },
						nodes = {
							{
								n = G.UIT.R,
								config = { align = 'cm', padding = 0.15 },
								nodes = {}
							},
							{
								n= G.UIT.R,
								config = {align = 'cm' },
								nodes = {
									{
										n = G.UIT.C,
										config = {
											align = 'cm',
										},
										nodes = deck_tables,
									}
								}
							},
							{
								n = G.UIT.R,
								config = { align = 'cm', padding = 0.1 },
								nodes = {}
							},
							create_option_cycle({
								options = page_options,
								w = 4.5,
								cycle_shoulders = true,
								opt_callback = 'your_collection_blinds_page',
								focus_args = {snap_to = true, nav = 'wide'},
								current_option = page,
								colour = G.ACTIVE_MOD_UI and (G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED,
								no_pips = true
							})
						},
					},
				}
			}
		}
	})
	return t
end

function G.FUNCS.your_collection_blinds_page(args)
	if not args or not args.cycle_config then return end
	for j = 1, #G.your_collection do
		for i = #G.your_collection[j].cards, 1, -1 do
			local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
			c:remove()
			c = nil
		end
	end

	local cols = 5
	local rows = 6
	local page = args.cycle_config.current_option
	local blind_tab = SMODS.collection_pool(G.P_BLINDS)

	local this_page = {}
	for i, v in ipairs(blind_tab) do
		if i > rows*cols*(page-1) and i <= rows*cols*page then
			table.insert(this_page, v)
		elseif i > rows*cols*page then
			break
		end
	end
	blind_tab = this_page

	local blinds_to_be_alerted = {}
	local row, col = 1, 1
	for k, v in ipairs(blind_tab) do
		local temp_blind = AnimatedSprite(G.your_collection[row].T.x + G.your_collection[row].T.w/2, G.your_collection[row].T.y, 1.3, 1.3, G.ANIMATION_ATLAS[v.discovered and v.atlas or 'blind_chips'],
			v.discovered and v.pos or G.b_undiscovered.pos)
		temp_blind.states.click.can = false
		temp_blind.states.drag.can = false
		temp_blind.states.hover.can = true
		local card = Card(G.your_collection[row].T.x + G.your_collection[row].T.w/2, G.your_collection[row].T.y, 1.3, 1.3, G.P_CARDS.empty, G.P_CENTERS.c_base)
		temp_blind.states.click.can = false
		card.states.drag.can = false
		card.states.hover.can = true
		card.children.center = temp_blind
		temp_blind:set_role({major = card, role_type = 'Glued', draw_major = card})
		card.set_sprites = function(...)
			local args = {...}
			if not args[1].animation then return end -- fix for debug unlock
			local c = card.children.center
			Card.set_sprites(...)
			card.children.center = c
		end
		temp_blind:define_draw_steps({
			{ shader = 'dissolve', shadow_height = 0.05 },
			{ shader = 'dissolve' }
		})
		temp_blind.float = true
		card.states.collide.can = true
		card.config.blind = v
		card.config.force_focus = true
		if v.discovered and not v.alerted then
			blinds_to_be_alerted[#blinds_to_be_alerted + 1] = card
		end
		card.hover = function()
			if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
				if not card.hovering and card.states.visible then
					card.hovering = true
					card.hover_tilt = 3
					card:juice_up(0.05, 0.02)
					play_sound('chips1', math.random() * 0.1 + 0.55, 0.12)
					card.config.h_popup = create_UIBox_blind_popup(v, card.config.blind.discovered)
					card.config.h_popup_config = card:align_h_popup()
					Node.hover(card)
					if card.children.alert then
						card.children.alert:remove()
						card.children.alert = nil
						card.config.blind.alerted = true
						G:save_progress()
					end
				end
			end
			card.stop_hover = function()
				card.hovering = false; Node.stop_hover(card); card.hover_tilt = 0
			end
		end
		G.your_collection[row]:emplace(card)
		col = col + 1
		if col > cols then col = 1; row = row + 1 end
	end
	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = (function()
			for _, v in ipairs(blinds_to_be_alerted) do
			  v.children.alert = UIBox{
				definition = create_UIBox_card_alert(),
				config = { align="tri", offset = {x = 0.1, y = 0.1}, parent = v}
			  }
			  v.children.alert.states.collide.can = false
			end
			return true
		end)
	}))
end
--#endregion
--#region tag collections
function create_UIBox_your_collection_tags()
	G.E_MANAGER:add_event(Event({
		func = function()
			G.FUNCS.your_collection_tags_page({ cycle_config = {}})
			return true
		end
	}))
	return {
		n = G.UIT.O,
		config = { object = UIBox{
			definition = create_UIBox_your_collection_tags_content(),
			config = { offset = {x=0, y=0}, align = 'cm' }
		}, id = 'your_collection_tags_contents', align = 'cm' },
	}
end

function create_UIBox_your_collection_tags_content(page)
	page = page or 1
	local tag_matrix = {}
	local rows = 4
	local cols = 6
	local tag_tab = SMODS.collection_pool(G.P_TAGS)
	for i = 1, math.ceil(rows) do
		table.insert(tag_matrix, {})
	end

	local tags_to_be_alerted = {}
	local row, col = 1, 1
	for k, v in ipairs(tag_tab) do
		if k <= cols*rows*(page-1) then elseif k > cols*rows*page then break else
			local discovered = v.discovered
			local temp_tag = Tag(v.key, true)
			if not v.discovered then temp_tag.hide_ability = true end
			local temp_tag_ui, temp_tag_sprite = temp_tag:generate_UI()
			tag_matrix[row][col] = {
				n = G.UIT.C,
				config = { align = "cm", padding = 0.1 },
				nodes = {
					temp_tag_ui,
				}
			}
			col = col + 1
			if col > cols then col = 1; row = row + 1 end
			if discovered and not v.alerted then
				tags_to_be_alerted[#tags_to_be_alerted + 1] = temp_tag_sprite
			end
		end
	end

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = (function()
			for _, v in ipairs(tags_to_be_alerted) do
				v.children.alert = UIBox {
					definition = create_UIBox_card_alert(),
					config = { align = "tri", offset = { x = 0.1, y = 0.1 }, parent = v }
				}
				v.children.alert.states.collide.can = false
			end
			return true
		end)
	}))


	local table_nodes = {}
	for i = 1, rows do
		table.insert(table_nodes, { n = G.UIT.R, config = { align = "cm", minh = 1 }, nodes = tag_matrix[i] })
	end
	local page_options = {}
	for i = 1, math.ceil(#tag_tab/(rows*cols)) do
		table.insert(page_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#tag_tab/(rows*cols))))
	end
    local t = create_UIBox_generic_options({
		colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).colour) or nil,
        bg_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour) or nil,
        back_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or
            (G.ACTIVE_MOD_UI.ui_config or {}).back_colour) or nil,
		back_func = G.ACTIVE_MOD_UI and "openModUI_" .. G.ACTIVE_MOD_UI.id or 'your_collection',
		contents = {
			{
				n = G.UIT.R,
				config = { align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm" },
						nodes = {
							{ n = G.UIT.R, config = { align = "cm" }, nodes = table_nodes },
						}
					},
				}
			},
			{
				n = G.UIT.R,
				config = { align = 'cm' },
				nodes = {
					create_option_cycle({
						options = page_options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback = 'your_collection_tags_page',
						focus_args = { snap_to = true, nav = 'wide' },
						current_option = page,
						colour = G.ACTIVE_MOD_UI and (G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED,
						no_pips = true
					})
				}
			}
		}
	})
	return t
end

G.FUNCS.your_collection_tags_page = function(args)
	local page = args.cycle_config.current_option or 1
	local t = create_UIBox_your_collection_tags_content(page)
	local e = G.OVERLAY_MENU:get_UIE_by_ID('your_collection_tags_contents')
	if e.config.object then e.config.object:remove() end
    e.config.object = UIBox{
      definition = t,
      config = {offset = {x=0,y=0}, align = 'cm', parent = e}
    }
end
--#endregion
--#region stakes UI
function SMODS.applied_stakes_UI(i, stake_desc_rows, num_added)
	if num_added == nil then num_added = { val = 0 } end
	if G.P_CENTER_POOLS['Stake'][i].applied_stakes then
		for _, v in pairs(G.P_CENTER_POOLS['Stake'][i].applied_stakes) do
			if v ~= "white" then
				--todo: manage this with pages
				if num_added.val < 8 then
					local i = G.P_STAKES[v].stake_level
					local _stake_desc = {}
					local _stake_center = G.P_CENTER_POOLS.Stake[i]
					localize { type = 'descriptions', key = _stake_center.key, set = _stake_center.set, nodes = _stake_desc }
					local _full_desc = {}
					for k, v in ipairs(_stake_desc) do
						_full_desc[#_full_desc + 1] = {n = G.UIT.R, config = {align = "cm"}, nodes = v}
					end
					_full_desc[#_full_desc] = nil
					stake_desc_rows[#stake_desc_rows + 1] = {n = G.UIT.R, config = {align = "cm" }, nodes = {
						{n = G.UIT.C, config = {align = 'cm'}, nodes = {
							{n = G.UIT.C, config = {align = "cm", colour = get_stake_col(i), r = 0.1, minh = 0.35, minw = 0.35, emboss = 0.05 }, nodes = {}},
							{n = G.UIT.B, config = {w = 0.1, h = 0.1}}}},
						{n = G.UIT.C, config = {align = "cm", padding = 0.03, colour = G.C.WHITE, r = 0.1, minh = 0.7, minw = 4.8 }, nodes =
							_full_desc},}}
				end
				num_added.val = num_added.val + 1
				num_added.val = SMODS.applied_stakes_UI(G.P_STAKES[v].stake_level, stake_desc_rows,
					num_added)
			end
		end
	end
end

-- We're overwriting so much that it's better to just remake this
function G.UIDEF.deck_stake_column(_deck_key)
	local deck_usage = G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key]
	local stake_col = {}
	local valid_option = nil
	local num_stakes = #G.P_CENTER_POOLS['Stake']
	for i = #G.P_CENTER_POOLS['Stake'], 1, -1 do
		local _wins = deck_usage and deck_usage.wins[i] or 0
		if (deck_usage and deck_usage.wins[i - 1]) or i == 1 or G.PROFILES[G.SETTINGS.profile].all_unlocked then valid_option = true end
		stake_col[#stake_col + 1] = {n = G.UIT.R, config = {id = i, align = "cm", colour = _wins > 0 and G.C.GREY or G.C.CLEAR, outline = 0, outline_colour = G.C.WHITE, r = 0.1, minh = 2 / num_stakes, minw = valid_option and 0.45 or 0.25, func = 'RUN_SETUP_check_back_stake_highlight'}, nodes = {
			{n = G.UIT.R, config = {align = "cm", minh = valid_option and 1.36 / num_stakes or 1.04 / num_stakes, minw = valid_option and 0.37 or 0.13, colour = _wins > 0 and get_stake_col(i) or G.C.UI.TRANSPARENT_LIGHT, r = 0.1}, nodes = {}}}}
		if i > 1 then stake_col[#stake_col + 1] = {n = G.UIT.R, config = {align = "cm", minh = 0.8 / num_stakes, minw = 0.04 }, nodes = {} } end
	end
	return {n = G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes = stake_col}
end

--#endregion
--#region straights and view deck UI

function get_straight(hand, min_length, skip, wrap)
    min_length = min_length or 5
    if min_length < 2 then min_length = 2 end
    if #hand < min_length then return {} end
    local ranks = {}
    for k,_ in pairs(SMODS.Ranks) do ranks[k] = {} end
    for _,card in ipairs(hand) do
        local id = card:get_id()
        if id > 0 then
            for k,v in pairs(SMODS.Ranks) do
                if v.id == id then table.insert(ranks[k], card); break end
            end
        end
    end
    local function next_ranks(key, start)
        local rank = SMODS.Ranks[key]
        local ret = {}
		if not start and not wrap and rank.straight_edge then return ret end
        for _,v in ipairs(rank.next) do
            ret[#ret+1] = v
            if skip and (wrap or not SMODS.Ranks[v].straight_edge) then
                for _,w in ipairs(SMODS.Ranks[v].next) do
                    ret[#ret+1] = w
                end
            end
        end
        return ret
    end
    local tuples = {}
    local ret = {}
    for _,k in ipairs(SMODS.Rank.obj_buffer) do
        if next(ranks[k]) then
            tuples[#tuples+1] = {k}
        end
    end
    for i = 2, #hand+1 do
        local new_tuples = {}
        for _, tuple in ipairs(tuples) do
            local any_tuple
            if i ~= #hand+1 then
                for _,l in ipairs(next_ranks(tuple[i-1], i == 2)) do
                    if next(ranks[l]) then
                        local new_tuple = {}
                        for _,v in ipairs(tuple) do new_tuple[#new_tuple+1] = v end
                        new_tuple[#new_tuple+1] = l
                        new_tuples[#new_tuples+1] = new_tuple
                        any_tuple = true
                    end
                end
            end
            if i > min_length and not any_tuple then
                local straight = {}
                for _,v in ipairs(tuple) do
                    for _,card in ipairs(ranks[v]) do
                        straight[#straight+1] = card
                    end
                end
                ret[#ret+1] = straight
            end
        end
        tuples = new_tuples
    end
    table.sort(ret, function(a,b) return #a > #b end)
    return ret
end

function G.UIDEF.deck_preview(args)
	local _minh, _minw = 0.35, 0.5
	local suit_labels = {}
	local suit_counts = {}
	local mod_suit_counts = {}
	for _, v in ipairs(SMODS.Suit.obj_buffer) do
		suit_counts[v] = 0
		mod_suit_counts[v] = 0
	end
	local mod_suit_diff = false
	local wheel_flipped, wheel_flipped_text = 0, nil
	local flip_col = G.C.WHITE
	local rank_counts = {}
	local deck_tables = {}
	remove_nils(G.playing_cards)
	table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
	local SUITS = {}
	for _, suit in ipairs(SMODS.Suit.obj_buffer) do
		SUITS[suit] = {}
		for _, rank in ipairs(SMODS.Rank.obj_buffer) do
			SUITS[suit][rank] = {}
		end
	end
	local stones = nil
	local suit_map = {}
	for i = #SMODS.Suit.obj_buffer, 1, -1 do
		suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
	end
	local rank_name_mapping = {}
	for i = #SMODS.Rank.obj_buffer, 1, -1 do
		rank_name_mapping[#rank_name_mapping + 1] = SMODS.Rank.obj_buffer[i]
	end
	for k, v in ipairs(G.playing_cards) do
		if v.ability.effect == 'Stone Card' then
			stones = stones or 0
		end
		if (v.area and v.area == G.deck) or v.ability.wheel_flipped then
			if v.ability.wheel_flipped and not (v.area and v.area == G.deck) then wheel_flipped = wheel_flipped + 1 end
			if v.ability.effect == 'Stone Card' then
				stones = stones + 1
			end
			local v_nr, v_ns = SMODS.has_no_rank(v), SMODS.has_no_suit(v)
			for kk, vv in pairs(suit_counts) do
				if v.base.suit == kk and not v_ns then suit_counts[kk] = suit_counts[kk] + 1 end
				if v:is_suit(kk) then mod_suit_counts[kk] = mod_suit_counts[kk] + 1 end
			end
			if SUITS[v.base.suit][v.base.value] and not v_nr and not v_ns then
				table.insert(SUITS[v.base.suit][v.base.value], v)
			end
			if not v_nr then
				rank_counts[v.base.value] = (rank_counts[v.base.value] or 0) + 1
			end
		end
	end

	wheel_flipped_text = (wheel_flipped > 0) and
		{n = G.UIT.T, config = {text = '?', colour = G.C.FILTER, scale = 0.25, shadow = true}}
	or nil
	flip_col = wheel_flipped_text and mix_colours(G.C.FILTER, G.C.WHITE, 0.7) or G.C.WHITE

	suit_labels[#suit_labels + 1] = {n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.04, minw = _minw, minh = 2 * _minh + 0.25}, nodes = {
		stones and {n = G.UIT.T, config = {text = localize('ph_deck_preview_stones') .. ': ', colour = G.C.WHITE, scale = 0.25, shadow = true}}
		or nil,
		stones and {n = G.UIT.T, config = {text = '' .. stones, colour = (stones > 0 and G.C.WHITE or G.C.UI.TRANSPARENT_LIGHT), scale = 0.4, shadow = true}}
		or nil,}}
	local hidden_ranks = {}
	for _, rank in ipairs(rank_name_mapping) do
		local count = 0
		for _, suit in ipairs(suit_map) do
			count = count + #SUITS[suit][rank]
		end
		if count == 0 and SMODS.Ranks[rank].in_pool and not SMODS.Ranks[rank]:in_pool({suit=''}) then
			hidden_ranks[rank] = true
		end
	end
	local hidden_suits = {}
	for _, suit in ipairs(suit_map) do
		if suit_counts[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.Suits[suit]:in_pool({rank=''}) then
			hidden_suits[suit] = true
		end
	end
	local _row = {}
	local _bg_col = G.C.JOKER_GREY
	for k, v in ipairs(rank_name_mapping) do
		local _tscale = 0.3
		local _colour = G.C.BLACK
		local rank_col = SMODS.Ranks[v].face and G.C.WHITE or _bg_col
		rank_col = mix_colours(rank_col, _bg_col, 0.8)

		local _col = {n = G.UIT.C, config = {align = "cm" }, nodes = {
			{n = G.UIT.C, config = {align = "cm", r = 0.1, minw = _minw, minh = _minh, colour = rank_col, emboss = 0.04, padding = 0.03 }, nodes = {
				{n = G.UIT.R, config = {align = "cm" }, nodes = {
					{n = G.UIT.T, config = {text = '' .. SMODS.Ranks[v].shorthand, colour = _colour, scale = 1.6 * _tscale } },}},
				{n = G.UIT.R, config = {align = "cm", minw = _minw + 0.04, minh = _minh, colour = G.C.L_BLACK, r = 0.1 }, nodes = {
					{n = G.UIT.T, config = {text = '' .. (rank_counts[v] or 0), colour = flip_col, scale = _tscale, shadow = true } }}}}}}}
		if not hidden_ranks[v] then table.insert(_row, _col) end
	end
	table.insert(deck_tables, {n = G.UIT.R, config = {align = "cm", padding = 0.04 }, nodes = _row })

	for _, suit in ipairs(suit_map) do
		if not hidden_suits[suit] then
			_row = {}
			_bg_col = mix_colours(G.C.SUITS[suit], G.C.L_BLACK, 0.7)
			for _, rank in ipairs(rank_name_mapping) do
				local _tscale = #SUITS[suit][rank] > 0 and 0.3 or 0.25
				local _colour = #SUITS[suit][rank] > 0 and flip_col or G.C.UI.TRANSPARENT_LIGHT

				local _col = {n = G.UIT.C, config = {align = "cm", padding = 0.05, minw = _minw + 0.098, minh = _minh }, nodes = {
					{n = G.UIT.T, config = {text = '' .. #SUITS[suit][rank], colour = _colour, scale = _tscale, shadow = true, lang = G.LANGUAGES['en-us'] } },}}
				if not hidden_ranks[rank] then table.insert(_row, _col) end
			end
			table.insert(deck_tables,
				{n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.04, minh = 0.4, colour = _bg_col }, nodes =
					_row})
		end
	end

	for k, v in ipairs(suit_map) do
		if not hidden_suits[v] then
			local deckskin = SMODS.DeckSkins[G.SETTINGS.CUSTOM_DECK.Collabs[v]]
			local palette = deckskin.palette_map and deckskin.palette_map[G.SETTINGS.colour_palettes[v] or ''] or (deckskin.palettes or {})[1]
			local t_s
			if palette and palette.suit_icon and palette.suit_icon.atlas then
				local _x = (v == 'Spades' and 3) or (v == 'Hearts' and 0) or (v == 'Clubs' and 2) or (v == 'Diamonds' and 1)
				t_s = Sprite(0,0,0.3,0.3,G.ASSET_ATLAS[palette.suit_icon.atlas or 'ui_1'], (type(palette.suit_icon.pos) == "number" and {x=_x, y=palette.suit_icon.pos}) or palette.suit_icon.pos or {x=_x, y=0})
			elseif G.SETTINGS.colour_palettes[v] == 'lc' or G.SETTINGS.colour_palettes[v] == 'hc' then
				t_s = Sprite(0, 0, 0.3, 0.3,
						G.ASSET_ATLAS[SMODS.Suits[v][G.SETTINGS.colour_palettes[v] == 'hc' and "hc_ui_atlas" or G.SETTINGS.colour_palettes[v] == 'lc' and "lc_ui_atlas"]] or
						G.ASSET_ATLAS[("ui_" .. (G.SETTINGS.colourblind_option and "2" or "1"))], SMODS.Suits[v].ui_pos)
			else
				local atlas = G.SETTINGS.colour_palettes[v] == "hc" and SMODS.Suits[v].hc_ui_atlas or SMODS.Suits[v].lc_ui_atlas
				t_s = Sprite(0, 0, 0.3, 0.3, G.ASSET_ATLAS[atlas and atlas or ("ui_" .. (G.SETTINGS.colourblind_option and "2" or "1"))], SMODS.Suits[v].ui_pos)
			end

			t_s.states.drag.can = false
			t_s.states.hover.can = false
			t_s.states.collide.can = false

			if mod_suit_counts[v] ~= suit_counts[v] then mod_suit_diff = true end

			suit_labels[#suit_labels + 1] =
			{n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.03, colour = G.C.JOKER_GREY }, nodes = {
				{n = G.UIT.C, config = {align = "cm", minw = _minw, minh = _minh }, nodes = {
					{n = G.UIT.O, config = {can_collide = false, object = t_s } }}},
				{n = G.UIT.C, config = {align = "cm", minw = _minw * 2.4, minh = _minh, colour = G.C.L_BLACK, r = 0.1 }, nodes = {
					{n = G.UIT.T, config = {text = '' .. suit_counts[v], colour = flip_col, scale = 0.3, shadow = true, lang = G.LANGUAGES['en-us'] } },
					mod_suit_counts[v] ~= suit_counts[v] and {n = G.UIT.T, config = {text = ' (' .. mod_suit_counts[v] .. ')', colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7), scale = 0.28, shadow = true, lang = G.LANGUAGES['en-us'] } }
					or nil,}}}}
		end
	end


	local t = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.JOKER_GREY, r = 0.1, emboss = 0.05, padding = 0.07}, nodes = {
		{n = G.UIT.R, config = {align = "cm", r = 0.1, emboss = 0.05, colour = G.C.BLACK, padding = 0.1}, nodes = {
			{n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {align = "cm", padding = 0.04}, nodes = suit_labels },
				{n = G.UIT.C, config = {align = "cm", padding = 0.02}, nodes = deck_tables }}},
			mod_suit_diff and {n = G.UIT.R, config = {align = "cm" }, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7) }, nodes = {} },
				{n = G.UIT.T, config = {text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3 } },}}
			or nil,
			wheel_flipped_text and {n = G.UIT.R, config = {align = "cm" }, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = flip_col }, nodes = {} },
				{n = G.UIT.T, config = {
						text = ' ' .. (wheel_flipped > 1 and
							localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
							localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
						colour = G.C.WHITE,
						scale = 0.3}},}}
			or nil,}}}}
	return t
end

function tally_sprite(pos, value, tooltip, suit)
	local text_colour = G.C.BLACK
	if type(value) == "table" and value[1].string==value[2].string then
		text_colour = value[1].colour or G.C.WHITE
		value = value[1].string
	end
	local deckskin = suit and SMODS.DeckSkins[G.SETTINGS.CUSTOM_DECK.Collabs[suit]]
	local palette = deckskin and (deckskin.palette_map and deckskin.palette_map[G.SETTINGS.colour_palettes[suit] or ''] or (deckskin.palettes or {})[1])
	local t_s
	if palette and palette.suit_icon and palette.suit_icon.atlas then
		local _x = (suit == 'Spades' and 3) or (suit == 'Hearts' and 0) or (suit == 'Clubs' and 2) or (suit == 'Diamonds' and 1)
		t_s = Sprite(0,0,0.3,0.3,G.ASSET_ATLAS[palette.suit_icon.atlas or 'ui_1'], (type(palette.suit_icon.pos) == "number" and {x=_x, y=palette.suit_icon.pos}) or palette.suit_icon.pos or {x=_x, y=0})
	elseif suit and (G.SETTINGS.colour_palettes[suit] == 'lc' or G.SETTINGS.colour_palettes[suit] == 'hc') then
		t_s = Sprite(0, 0, 0.3, 0.3,
				G.ASSET_ATLAS[SMODS.Suits[suit][G.SETTINGS.colour_palettes[suit] == 'hc' and "hc_ui_atlas" or G.SETTINGS.colour_palettes[suit] == 'lc' and "lc_ui_atlas"]] or
				G.ASSET_ATLAS[("ui_" .. (G.SETTINGS.colourblind_option and "2" or "1"))], SMODS.Suits[suit].ui_pos)
	else
		t_s = Sprite(0,0,0.5,0.5, suit and G.ASSET_ATLAS[SMODS.Suits[suit][G.SETTINGS.colourblind_option and "hc_ui_atlas" or "lc_ui_atlas"]] or G.ASSET_ATLAS[("ui_"..(G.SETTINGS.colourblind_option and "2" or "1"))], {x=pos.x or 0, y=pos.y or 0})
	end
	t_s.states.drag.can = false
	t_s.states.hover.can = false
	t_s.states.collide.can = false
	return
	{n=G.UIT.C, config={align = "cm", padding = 0.07,force_focus = true,  focus_args = {type = 'tally_sprite'}, tooltip = {text = tooltip}}, nodes={
		{n=G.UIT.R, config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.05, colour = G.C.JOKER_GREY}, nodes={
			{n=G.UIT.O, config={w=0.5,h=0.5 ,can_collide = false, object = t_s, tooltip = {text = tooltip}}}
		}},
		{n=G.UIT.R, config={align = "cm"}, nodes={
			type(value) == "table" and {n=G.UIT.O, config={object = DynaText({string = value, colours = {G.C.RED}, scale = 0.4, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4})}} or
					{n=G.UIT.T, config={text = value or 'NIL',colour = text_colour, scale = 0.4, shadow = true}},
		}},
	}}
end

local view_deck_unplayed_only = nil
function G.UIDEF.view_deck(unplayed_only)
	local deck_tables = {}
	remove_nils(G.playing_cards)
	G.VIEWING_DECK = true
	view_deck_unplayed_only = unplayed_only
	table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
	local SUITS = {}
	local suit_map = {}
	for i = #SMODS.Suit.obj_buffer, 1, -1 do
		SUITS[SMODS.Suit.obj_buffer[i]] = {}
		suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
	end
	for k, v in ipairs(G.playing_cards) do
		if v.base.suit then table.insert(SUITS[v.base.suit], v) end
	end
	local num_suits = 0
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
	end

	local visible_suit = {}
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then
			table.insert(visible_suit, suit_map[j])
		end
	end

	for j = 1, #visible_suit do
		if (j >= 1 and j <= 4) or num_suits <= 4 then
			if SUITS[visible_suit[j]][1] then
				local view_deck = CardArea(
					G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
					6.5 * G.CARD_W,
					(0.6) * G.CARD_H,
					{
						card_limit = #SUITS[visible_suit[j]],
						type = 'title',
						view_deck = true,
						highlight_limit = 0,
						card_w = G
							.CARD_W * 0.7,
						draw_layers = { 'card' }
					})
				table.insert(deck_tables,
					{n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
						{n = G.UIT.O, config = {object = view_deck}}}}
				)
				for i = 1, #SUITS[visible_suit[j]] do
					if SUITS[visible_suit[j]][i] then
						local greyed, _scale = nil, 0.7
						if unplayed_only and not ((SUITS[visible_suit[j]][i].area and SUITS[visible_suit[j]][i].area == G.deck) or SUITS[visible_suit[j]][i].ability.wheel_flipped) then
							greyed = true
						end
						local copy = copy_card(SUITS[visible_suit[j]][i], nil, _scale)
						copy.greyed = greyed
						copy.T.x = view_deck.T.x + view_deck.T.w / 2
						copy.T.y = view_deck.T.y

						copy:hard_set_T()
						view_deck:emplace(copy)
					end
				end
			end
		end
	end

	if not next(deck_tables) then
		local view_deck = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			6.5*G.CARD_W,
			0.6*G.CARD_H,
			{card_limit = 1, type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.7, draw_layers = {'card'}})
		table.insert(
			deck_tables,
			{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
				{n=G.UIT.O, config={object = view_deck}}
			}}
		)
	end

	local flip_col = G.C.WHITE

	local suit_tallies = {}
	local mod_suit_tallies = {}
	for _, v in ipairs(suit_map) do
		suit_tallies[v] = 0
		mod_suit_tallies[v] = 0
	end
	local rank_tallies = {}
	local mod_rank_tallies = {}
	local rank_name_mapping = SMODS.Rank.obj_buffer
	for _, v in ipairs(rank_name_mapping) do
		rank_tallies[v] = 0
		mod_rank_tallies[v] = 0
	end
	local face_tally = 0
	local mod_face_tally = 0
	local num_tally = 0
	local mod_num_tally = 0
	local ace_tally = 0
	local mod_ace_tally = 0
	local wheel_flipped = 0

	for k, v in ipairs(G.playing_cards) do
		if v.ability.name ~= 'Stone Card' and (not unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
			if v.ability.wheel_flipped and not (v.area and v.area == G.deck) and unplayed_only then wheel_flipped = wheel_flipped + 1 end
			local v_nr, v_ns = SMODS.has_no_rank(v), SMODS.has_no_suit(v)
			--For the suits
			if v.base.suit and not v_ns then suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1 end
			for kk, vv in pairs(mod_suit_tallies) do
				mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
			end

			--for face cards/numbered cards/aces
			local card_id = v:get_id()
			if v.base.value and not v_nr then face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0) end
			mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
			if v.base.value and not v_nr and not SMODS.Ranks[v.base.value].face and card_id ~= 14 then
				num_tally = num_tally + 1
				if not v.debuff then mod_num_tally = mod_num_tally + 1 end
			end
			if card_id == 14 then
				ace_tally = ace_tally + 1
				if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
			end

			--ranks
			if v.base.value and not v_nr then rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1 end
			if v.base.value and not v_nr and not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end
		end
	end
	local modded = face_tally ~= mod_face_tally
	for kk, vv in pairs(mod_suit_tallies) do
		modded = modded or (vv ~= suit_tallies[kk])
		if modded then break end
	end

	if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE, 0.7) end

	local rank_cols = {}
	for i = #rank_name_mapping, 1, -1 do
		if rank_tallies[rank_name_mapping[i]] ~= 0 or not SMODS.Ranks[rank_name_mapping[i]].in_pool or SMODS.Ranks[rank_name_mapping[i]]:in_pool({suit=''}) then
			local mod_delta = mod_rank_tallies[rank_name_mapping[i]] ~= rank_tallies[rank_name_mapping[i]]
			rank_cols[#rank_cols + 1] = {n = G.UIT.R, config = {align = "cm", padding = 0.07}, nodes = {
				{n = G.UIT.C, config = {align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK}, nodes = {
					{n = G.UIT.T, config = {text = SMODS.Ranks[rank_name_mapping[i]].shorthand, colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},}},
				{n = G.UIT.C, config = {align = "cr", minw = 0.4}, nodes = {
					mod_delta and {n = G.UIT.O, config = {
							object = DynaText({
								string = { { string = '' .. rank_tallies[rank_name_mapping[i]], colour = flip_col }, { string = '' .. mod_rank_tallies[rank_name_mapping[i]], colour = G.C.BLUE } },
								colours = { G.C.RED }, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4
							})}}
					or {n = G.UIT.T, config = {text = rank_tallies[rank_name_mapping[i]], colour = flip_col, scale = 0.45, shadow = true } },}}}}
		end
	end

	local tally_ui = {
		-- base cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.07}, nodes = {
			{n = G.UIT.O, config = {
					object = DynaText({
						string = {
							{ string = localize('k_base_cards'), colour = G.C.RED },
							modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil
						},
						colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4
					})
				}}}},
		-- aces, faces and numbered cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.1}, nodes = {
			tally_sprite(
				{ x = 1, y = 0 },
				{ { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } },
				{ localize('k_aces') }
			), --Aces
			tally_sprite(
				{ x = 2, y = 0 },
				{ { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } },
				{ localize('k_face_cards') }
			), --Face
			tally_sprite(
				{ x = 3, y = 0 },
				{ { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } },
				{ localize('k_numbered_cards') }
			), --Numbers
		}},
	}
	-- add suit tallies
	local hidden_suits = {}
	for _, suit in ipairs(suit_map) do
		if suit_tallies[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.Suits[suit]:in_pool({rank=''}) then
			hidden_suits[suit] = true
		end
	end
	local i = 1
	local num_suits_shown = 0
	for i = 1, #suit_map do
		if not hidden_suits[suit_map[i]] then
			num_suits_shown = num_suits_shown+1
		end
	end
	local suits_per_row = 2
	local n_nodes = {}
	local visible_suits = {}
	local temp_list = {}
	while i <= math.min(4, #visible_suit) do
		if not hidden_suits[visible_suit[i]] then
			table.insert(n_nodes, tally_sprite(
				SMODS.Suits[visible_suit[i]].ui_pos,
				{
					{ string = '' .. suit_tallies[visible_suit[i]], colour = flip_col },
					{ string = '' .. mod_suit_tallies[visible_suit[i]], colour = G.C.BLUE }
				},
				{ localize(visible_suit[i], 'suits_plural') },
				visible_suit[i]
			))
			table.insert(visible_suits, i)
		end
		if #n_nodes == suits_per_row then
			table.insert(temp_list, n_nodes)
			n_nodes = {}
		end
		i = i + 1
	end
	if #n_nodes > 0 then
		table.insert(temp_list, n_nodes)
	end

	local index = 0
	local second_temp_list = {}
	for _, v in ipairs(temp_list) do
		local n = {n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.05}, nodes = v}
		table.insert(tally_ui, n)
	end

	local suit_options = {}
	for i = 1, math.ceil(#visible_suit / 4) do
		table.insert(suit_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_suit / 4)))
	end

	local object = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {}},
		{n = G.UIT.R, config = {align = "cm"}, nodes = {
			{n = G.UIT.C, config = {align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = {
				{n = G.UIT.C, config = {align = "tm", padding = 0.1}, nodes = {
					{n = G.UIT.R, config = {align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.O, config = {
									object = DynaText({ string = G.GAME.selected_back.loc_name, colours = {G.C.WHITE}, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(G.GAME.selected_back.loc_name) * 0.01 })
								}},
						}},
						{n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05}, nodes = {
							{n = G.UIT.O, config = {
									object = UIBox {
										definition = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge), config = {offset = { x = 0, y = 0 } }
									}
								}}
						}}
					}},
					{n = G.UIT.R, config = {align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5}, nodes = tally_ui}
				}},
				{n = G.UIT.C, config = {align = "cm"}, nodes = rank_cols},
				{n = G.UIT.B, config = {w = 0.1, h = 0.1}},
			}},
			{n = G.UIT.B, config = {w = 0.2, h = 0.1}},
			{n = G.UIT.C, config = {align = "cm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = deck_tables}
		}},
		#visible_suit > 4 and {n = G.UIT.R, config = {align = "cm", padding = 0 }, nodes = {
			create_option_cycle({
				options = suit_options,
				w = 4.5,
				cycle_shoulders = true,
				opt_callback =
				'your_suits_page',
				focus_args = { snap_to = true, nav = 'wide' },
				current_option = 1,
				colour = G.C.RED,
				no_pips = true,
			})
		}} or nil,
		{n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
			modded and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7)}, nodes = {}},
				{n = G.UIT.T, config = {text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3}},}}
			or nil,
			wheel_flipped > 0 and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = flip_col}, nodes = {}},
				{n = G.UIT.T, config = {
						text = ' ' .. (wheel_flipped > 1 and
							localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
							localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
						colour = G.C.WHITE, scale = 0.3
					}},}}
			or nil,}}}}
	local t = {n = G.UIT.ROOT, config = {align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.O, config = {
				id = 'suit_list',
				object = UIBox {
					definition = object, config = {offset = { x = 0, y = 0 }, align = 'cm'}
				}
			}}}}
	return t
end

G.FUNCS.your_suits_page = function(args)
	if not args or not args.cycle_config then return end
	local deck_tables = {}
	remove_nils(G.playing_cards)
	G.VIEWING_DECK = true
	table.sort(G.playing_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
	local SUITS = {}
	local suit_map = {} 
	for i = #SMODS.Suit.obj_buffer, 1, -1 do
		SUITS[SMODS.Suit.obj_buffer[i]] = {}
		suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
	end
	for k, v in ipairs(G.playing_cards) do
		if v.base.suit then table.insert(SUITS[v.base.suit], v) end
	end
	local num_suits = 0
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
	end

	local visible_suit = {}
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then
			table.insert(visible_suit, suit_map[j])
		end
	end

	local deck_start_index = (args.cycle_config.current_option - 1) * 4 + 1
	local deck_end_index = math.min(deck_start_index + 4 - 1, #visible_suit)
	for j = 1, #visible_suit do
		if SUITS[visible_suit[j]][1] and (j >= deck_start_index and j <= deck_end_index) then
			local view_deck = CardArea(
				G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
				6.5 * G.CARD_W,
				(0.6) * G.CARD_H,
				{
					card_limit = #SUITS[visible_suit[j]],
					type = 'title',
					view_deck = true,
					highlight_limit = 0,
					card_w = G
						.CARD_W * 0.7,
					draw_layers = { 'card' }
				})
			table.insert(deck_tables,
				{n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
					{n = G.UIT.O, config = {object = view_deck}}}}
			)
			for i = 1, #SUITS[visible_suit[j]] do
				if SUITS[visible_suit[j]][i] then
					local greyed, _scale = nil, 0.7
					if view_deck_unplayed_only and not ((SUITS[visible_suit[j]][i].area and SUITS[visible_suit[j]][i].area == G.deck) or SUITS[visible_suit[j]][i].ability.wheel_flipped) then
						greyed = true
					end
					local copy = copy_card(SUITS[visible_suit[j]][i], nil, _scale)
					copy.greyed = greyed
					copy.T.x = view_deck.T.x + view_deck.T.w / 2
					copy.T.y = view_deck.T.y

					copy:hard_set_T()
					view_deck:emplace(copy)
				end
			end
		end
	end

	if not next(deck_tables) then
		local view_deck = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			6.5*G.CARD_W,
			0.6*G.CARD_H,
			{card_limit = 1, type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.7, draw_layers = {'card'}})
		table.insert(
			deck_tables,
			{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
				{n=G.UIT.O, config={object = view_deck}}
			}}
		)
	end

	local flip_col = G.C.WHITE

	local suit_tallies = {}
	local mod_suit_tallies = {}
	for _, v in ipairs(suit_map) do
		suit_tallies[v] = 0
		mod_suit_tallies[v] = 0
	end
	local rank_tallies = {}
	local mod_rank_tallies = {}
	local rank_name_mapping = SMODS.Rank.obj_buffer
	for _, v in ipairs(rank_name_mapping) do
		rank_tallies[v] = 0
		mod_rank_tallies[v] = 0
	end
	local face_tally = 0
	local mod_face_tally = 0
	local num_tally = 0
	local mod_num_tally = 0
	local ace_tally = 0
	local mod_ace_tally = 0
	local wheel_flipped = 0

	for k, v in ipairs(G.playing_cards) do
		if v.ability.name ~= 'Stone Card' and (not view_deck_unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
			if v.ability.wheel_flipped and not (v.area and v.area == G.deck) and view_deck_unplayed_only then wheel_flipped = wheel_flipped + 1 end
			--For the suits
			if v.base.suit then suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1 end
			for kk, vv in pairs(mod_suit_tallies) do
				mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
			end

			--for face cards/numbered cards/aces
			local card_id = v:get_id()
			if v.base.value then face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0) end
			mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
			if v.base.value and not SMODS.Ranks[v.base.value].face and card_id ~= 14 then
				num_tally = num_tally + 1
				if not v.debuff then mod_num_tally = mod_num_tally + 1 end
			end
			if card_id == 14 then
				ace_tally = ace_tally + 1
				if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
			end

			--ranks
			if v.base.value then rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1 end
			if v.base.value and not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end
		end
	end
	local modded = face_tally ~= mod_face_tally
	for kk, vv in pairs(mod_suit_tallies) do
		modded = modded or (vv ~= suit_tallies[kk])
		if modded then break end
	end

	if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE, 0.7) end

	local rank_cols = {}
	for i = #rank_name_mapping, 1, -1 do
		if rank_tallies[rank_name_mapping[i]] ~= 0 or not SMODS.Ranks[rank_name_mapping[i]].in_pool or SMODS.Ranks[rank_name_mapping[i]]:in_pool({suit=''}) then
			local mod_delta = mod_rank_tallies[rank_name_mapping[i]] ~= rank_tallies[rank_name_mapping[i]]
			rank_cols[#rank_cols + 1] = {n = G.UIT.R, config = {align = "cm", padding = 0.07}, nodes = {
				{n = G.UIT.C, config = {align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK}, nodes = {
					{n = G.UIT.T, config = {text = SMODS.Ranks[rank_name_mapping[i]].shorthand, colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},}},
				{n = G.UIT.C, config = {align = "cr", minw = 0.4}, nodes = {
					mod_delta and {n = G.UIT.O, config = {
							object = DynaText({
								string = { { string = '' .. rank_tallies[rank_name_mapping[i]], colour = flip_col }, { string = '' .. mod_rank_tallies[rank_name_mapping[i]], colour = G.C.BLUE } },
								colours = { G.C.RED }, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4
							})}}
					or {n = G.UIT.T, config = {text = rank_tallies[rank_name_mapping[i]], colour = flip_col, scale = 0.45, shadow = true } },}}}}
		end
	end

	local tally_ui = {
		-- base cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.07}, nodes = {
			{n = G.UIT.O, config = {
					object = DynaText({
						string = {
							{ string = localize('k_base_cards'), colour = G.C.RED },
							modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil
						},
						colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4
					})
				}}}},
		-- aces, faces and numbered cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.1}, nodes = {
			tally_sprite(
				{ x = 1, y = 0 },
				{ { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } },
				{ localize('k_aces') }
			), --Aces
			tally_sprite(
				{ x = 2, y = 0 },
				{ { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } },
				{ localize('k_face_cards') }
			), --Face
			tally_sprite(
				{ x = 3, y = 0 },
				{ { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } },
				{ localize('k_numbered_cards') }
			), --Numbers
		}},
	}
	-- add suit tallies
	local hidden_suits = {}
	for _, suit in ipairs(suit_map) do
		if suit_tallies[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.Suits[suit]:in_pool({rank=''}) then
			hidden_suits[suit] = true
		end
	end
	local i = deck_start_index
	local num_suits_shown = 0
	for i = 1, #visible_suit do
		if not hidden_suits[visible_suit[i]] then
			num_suits_shown = num_suits_shown+1
		end
	end
	local suits_per_row = 2
	local n_nodes = {}
	local visible_suits = {}
	local temp_list = {}
	while i <= deck_end_index do
		if not hidden_suits[visible_suit[i]] then
			table.insert(n_nodes, tally_sprite(
				SMODS.Suits[visible_suit[i]].ui_pos,
				{
					{ string = '' .. suit_tallies[visible_suit[i]], colour = flip_col },
					{ string = '' .. mod_suit_tallies[visible_suit[i]], colour = G.C.BLUE }
				},
				{ localize(visible_suit[i], 'suits_plural') },
				visible_suit[i]
			))
			table.insert(visible_suits, i)
		end
		if #n_nodes == suits_per_row then
			table.insert(temp_list, n_nodes)
			n_nodes = {}
		end
		i = i + 1
	end
	if #n_nodes > 0 then
		table.insert(temp_list, n_nodes)
	end

	local index = 0
	local second_temp_list = {}
	for _, v in ipairs(temp_list) do
		local n = {n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.05}, nodes = v}
		table.insert(tally_ui, n)
	end

	local suit_options = {}
	for i = 1, math.ceil(#visible_suit / 4) do
		table.insert(suit_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_suit / 4)))
	end

	local object = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {}},
		{n = G.UIT.R, config = {align = "cm"}, nodes = {
			{n = G.UIT.C, config = {align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = {
				{n = G.UIT.C, config = {align = "tm", padding = 0.1}, nodes = {
					{n = G.UIT.R, config = {align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.O, config = {
									object = DynaText({ string = G.GAME.selected_back.loc_name, colours = {G.C.WHITE}, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(G.GAME.selected_back.loc_name) * 0.01 })
								}},}},
						{n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05}, nodes = {
							{n = G.UIT.O, config = {
									object = UIBox {
										definition = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge), config = {offset = { x = 0, y = 0 } }
									}
								}}}}}},
					{n = G.UIT.R, config = {align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5}, nodes =
						tally_ui}}},
				{n = G.UIT.C, config = {align = "cm"}, nodes = rank_cols},
				{n = G.UIT.B, config = {w = 0.1, h = 0.1}},}},
			{n = G.UIT.B, config = {w = 0.2, h = 0.1}},
			{n = G.UIT.C, config = {align = "cm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes =
				deck_tables}}},
		{n = G.UIT.R, config = {align = "cm", padding = 0 }, nodes = {
				create_option_cycle({
					options = suit_options,
					w = 4.5,
					cycle_shoulders = true,
					opt_callback =
					'your_suits_page',
					focus_args = { snap_to = true, nav = 'wide' },
					current_option = args.cycle_config.current_option,
					colour = G.C.RED,
					no_pips = true,
				})
			}
		},
		{n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
			modded and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7)}, nodes = {}},
				{n = G.UIT.T, config = {text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3}},}}
			or nil,
			wheel_flipped > 0 and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = flip_col}, nodes = {}},
				{n = G.UIT.T, config = {
						text = ' ' .. (wheel_flipped > 1 and
							localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
							localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
						colour = G.C.WHITE, scale = 0.3
					}},}}
			or nil,}}}}

	local suit_list = G.OVERLAY_MENU:get_UIE_by_ID('suit_list')
	if suit_list then
		if suit_list.config.object then
			suit_list.config.object:remove()
		end
		suit_list.config.object = UIBox {
			definition = object, config = {offset = { x = 0, y = 0 }, align = 'cm', parent = suit_list }
		}
	end
end

--#endregion
--#region poker hands
local init_game_object_ref = Game.init_game_object
function Game:init_game_object()
	local t = init_game_object_ref(self)
	for _, key in ipairs(SMODS.PokerHand.obj_buffer) do
		t.hands[key] = {}
		for k, v in pairs(SMODS.PokerHands[key]) do
			-- G.GAME needs to be able to be serialized
            -- TODO this is too specific; ex. nested tables with simple keys
            -- are fine.
            -- In fact, the check should just warn you if you have a key that
            -- can't be serialized.
			if type(v) == 'number' or type(v) == 'boolean' or k == 'example' then
				t.hands[key][k] = v
			end
		end
	end
	return t
end

-- why bother patching when i basically change everything
function G.FUNCS.get_poker_hand_info(_cards)
	local poker_hands = evaluate_poker_hand(_cards)
	local scoring_hand = {}
	local text, disp_text, loc_disp_text = 'NULL', 'NULL', 'NULL'
	for _, v in ipairs(G.handlist) do
		if next(poker_hands[v]) then
			text = v
			scoring_hand = poker_hands[v][1]
			break
		end
	end
	disp_text = text
	local _hand = SMODS.PokerHands[text]
    if text == 'Straight Flush' then
        local royal = true
        for j = 1, #scoring_hand do
            local rank = SMODS.Ranks[scoring_hand[j].base.value]
            royal = royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
        end
        if royal then
            disp_text = 'Royal Flush'
        end
    elseif _hand and _hand.modify_display_text and type(_hand.modify_display_text) == 'function' then
        disp_text = _hand:modify_display_text(_cards, scoring_hand) or disp_text
    end
    local flags = SMODS.calculate_context({ evaluate_poker_hand = true, full_hand = _cards, scoring_hand = scoring_hand, scoring_name =
    text, poker_hands = poker_hands, display_name = disp_text })
    text = flags.replace_scoring_name or text
    disp_text = flags.replace_display_name or flags.replace_scoring_name or disp_text
	poker_hands = flags.replace_poker_hands or poker_hands
	loc_disp_text = localize(disp_text, 'poker_hands')
	loc_disp_text = loc_disp_text == 'ERROR' and disp_text or loc_disp_text
	return text, loc_disp_text, poker_hands, scoring_hand, disp_text
end

function create_UIBox_current_hands(simple)
	G.current_hands = {}
	local index = 0
	for _, v in ipairs(G.handlist) do
		local ui_element = create_UIBox_current_hand_row(v, simple)
		G.current_hands[index + 1] = ui_element
		if ui_element then
			index = index + 1
		end
		if index >= 10 then
			break
		end
	end

	local visible_hands = {}
	for _, v in ipairs(G.handlist) do
		if SMODS.is_poker_hand_visible(v) then
			table.insert(visible_hands, v)
		end
	end

	local hand_options = {}
	for i = 1, math.ceil(#visible_hands / 10) do
		table.insert(hand_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_hands / 10)))
	end

	local object = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.R, config = {align = "cm", padding = 0.04}, nodes =
			G.current_hands},
		{n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
			create_option_cycle({
				options = hand_options,
				w = 4.5,
				cycle_shoulders = true,
				opt_callback = 'your_hands_page',
				focus_args = { snap_to = true, nav = 'wide' },
				current_option = 1,
				colour = G.C.RED,
				no_pips = true
			})}}}}

	local t = {n = G.UIT.ROOT, config = {align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.O, config = {
				id = 'hand_list',
				object = UIBox {
					definition = object, config = {offset = { x = 0, y = 0 }, align = 'cm'}
				}
			}}}}
	return t
end

G.FUNCS.your_hands_page = function(args)
	if not args or not args.cycle_config then return end
	G.current_hands = {}


	local index = 0
	for _, v in ipairs(G.handlist) do
		local ui_element = create_UIBox_current_hand_row(v, simple)
		if index >= (0 + 10 * (args.cycle_config.current_option - 1)) and index < 10 * args.cycle_config.current_option then
			G.current_hands[index - (10 * (args.cycle_config.current_option - 1)) + 1] = ui_element
		end

		if ui_element then
			index = index + 1
		end

		if index >= 10 * args.cycle_config.current_option then
			break
		end
	end

	local visible_hands = {}
	for _, v in ipairs(G.handlist) do
		if SMODS.is_poker_hand_visible(v) then
			table.insert(visible_hands, v)
		end
	end

	local hand_options = {}
	for i = 1, math.ceil(#visible_hands / 10) do
		table.insert(hand_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_hands / 10)))
	end

	local object = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR }, nodes = {
			{n = G.UIT.R, config = {align = "cm", padding = 0.04 }, nodes = G.current_hands
			},
			{n = G.UIT.R, config = {align = "cm", padding = 0 }, nodes = {
					create_option_cycle({
						options = hand_options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback =
						'your_hands_page',
						focus_args = { snap_to = true, nav = 'wide' },
						current_option = args.cycle_config.current_option,
						colour = G
							.C.RED,
						no_pips = true
					})
				}
			}
		}
	}

	local hand_list = G.OVERLAY_MENU:get_UIE_by_ID('hand_list')
	if hand_list then
		if hand_list.config.object then
			hand_list.config.object:remove()
		end
		hand_list.config.object = UIBox {
			definition = object, config = {offset = { x = 0, y = 0 }, align = 'cm', parent = hand_list }
		}
	end
end

function evaluate_poker_hand(hand)
	local results = {}
	local parts = {}
	for _, v in ipairs(SMODS.PokerHandPart.obj_buffer) do
		parts[v] = SMODS.PokerHandParts[v].func(hand) or {}
	end
	for k, _hand in pairs(SMODS.PokerHands) do
		results[k] = _hand.evaluate(parts, hand) or {}
	end
	for _, v in ipairs(G.handlist) do
		if not results.top and results[v] then
			results.top = results[v]
			break
		end
	end
	return results
end
--#endregion

function Card:set_sprites(_center, _front)
    if _front then
        local _atlas, _pos = get_front_spriteinfo(_front)
        if self.children.front then self.children.front:remove() end
		self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, _atlas, _pos)
		self.children.front.states.hover = self.states.hover
		self.children.front.states.click = self.states.click
		self.children.front.states.drag = self.states.drag
		self.children.front.states.collide.can = false
		self.children.front:set_role({major = self, role_type = 'Glued', draw_major = self})
    end
    if _center then
        if _center.set then
            if self.children.center then self.children.center:remove() end
			if _center.set == 'Joker' and not _center.unlocked and not self.params.bypass_discovery_center then
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["Joker"], G.j_locked.pos)
			elseif self.config.center.set == 'Voucher' and not self.config.center.unlocked and not self.params.bypass_discovery_center then
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["Voucher"], G.v_locked.pos)
			elseif self.config.center.consumeable and self.config.center.demo then
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["Tarot"], G.c_locked.pos)
			elseif not self.params.bypass_discovery_center and (_center.set == 'Edition' or _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' or _center.set == 'Booster') and not _center.discovered then
				local atlas = G.ASSET_ATLAS[
					(_center.undiscovered and
						(_center.undiscovered[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or
						_center.undiscovered.atlas)
					) or
					(
						SMODS.UndiscoveredSprites[_center.set] and
						(SMODS.UndiscoveredSprites[_center.set][G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or
						SMODS.UndiscoveredSprites[_center.set].atlas)
					) or
					_center.set
				] or G.ASSET_ATLAS["Joker"]
				local pos = (_center.undiscovered and _center.undiscovered.pos) or
					(SMODS.UndiscoveredSprites[_center.set] and SMODS.UndiscoveredSprites[_center.set].pos) or
					G.j_undiscovered.pos
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, pos)
			elseif _center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher' then
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or _center.atlas or _center.set], self.config.center.pos)
			else
				self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center.atlas or 'centers'], _center.pos)
			end
			self.children.center.states.hover = self.states.hover
			self.children.center.states.click = self.states.click
			self.children.center.states.drag = self.states.drag
			self.children.center.states.collide.can = false
			self.children.center:set_role({major = self, role_type = 'Glued', draw_major = self})
            if _center.name == 'Half Joker' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.y/1.7
            end
            if _center.name == 'Photograph' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.y/1.2
            end
            if _center.name == 'Square Joker' and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.x
            end
            if _center.pixel_size and _center.pixel_size.h and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.y = self.children.center.scale.y*(_center.pixel_size.h/95)
            end
            if _center.pixel_size and _center.pixel_size.w and (_center.discovered or self.bypass_discovery_center) then
                self.children.center.scale.x = self.children.center.scale.x*(_center.pixel_size.w/71)
            end
        end

        if _center.soul_pos then
			if self.children.floating_sprite then self.children.floating_sprite:remove() end
            self.children.floating_sprite = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[_center[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or _center.atlas or _center.set], self.config.center.soul_pos)
            self.children.floating_sprite.role.draw_major = self
            self.children.floating_sprite.states.hover.can = false
            self.children.floating_sprite.states.click.can = false
        end

        if self.children.back then self.children.back:remove() end
		self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[(G.GAME.viewed_back or G.GAME.selected_back) and ((G.GAME.viewed_back or G.GAME.selected_back)[G.SETTINGS.colourblind_option and 'hc_atlas' or 'lc_atlas'] or (G.GAME.viewed_back or G.GAME.selected_back).atlas) or 'centers'], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
		self.children.back.states.hover = self.states.hover
		self.children.back.states.click = self.states.click
		self.children.back.states.drag = self.states.drag
		self.children.back.states.collide.can = false
		self.children.back:set_role({major = self, role_type = 'Glued', draw_major = self})
		if _center.set_sprites and type(_center.set_sprites) == 'function' then
            _center:set_sprites(self, _front)
        end
    end
end

-- Init custom card parameters.
local card_init = Card.init
function Card:init(X, Y, W, H, card, center, params)
	card_init(self, X, Y, W, H, card, center, params)

	-- This table contains object keys for layers (e.g. edition)
	-- that dont want base layer to be drawn.
	-- When layer is removed, layer's value should be set to nil.
	self.ignore_base_shader = self.ignore_base_shader or {}
	-- This table contains object keys for layers (e.g. edition)
	-- that dont want shadow to be drawn.
	-- When layer is removed, layer's value should be set to nil.
	self.ignore_shadow = self.ignore_shadow or {}
end

function Card:should_draw_base_shader()
	return not next(self.ignore_base_shader or {})
end

function Card:should_draw_shadow()
	return not next(self.ignore_shadow or {})
end

local smods_card_load = Card.load
--
function Card:load(cardTable, other_card)
	local ret = smods_card_load(self, cardTable, other_card)
	local on_edition_loaded = self.edition and self.edition.key and G.P_CENTERS[self.edition.key].on_load
	if type(on_edition_loaded) == "function" then
		on_edition_loaded(self)
	end

	return ret
end

-- self = pass the card
-- edition =
-- nil (removes edition)
-- OR key as string
-- OR { name_of_edition = true } (key without e_). This is from the base game, prefer using a string.
-- OR another card's self.edition table
-- immediate = boolean value
-- silent = boolean value
function Card:set_edition(edition, immediate, silent, delay)
	SMODS.enh_cache:write(self, nil)
	-- Check to see if negative is being removed and reduce card_limit accordingly
	if (self.added_to_deck or self.joker_added_to_deck_but_debuffed or (self.area == G.hand and not self.debuff)) and self.edition and self.edition.card_limit then
		if self.ability.consumeable and self.area == G.consumeables then
			G.consumeables.config.card_limit = G.consumeables.config.card_limit - self.edition.card_limit
		elseif self.ability.set == 'Joker' and self.area == G.jokers then
			G.jokers.config.card_limit = G.jokers.config.card_limit - self.edition.card_limit
		elseif self.area == G.hand then
			if G.hand.config.real_card_limit then
				G.hand.config.real_card_limit = G.hand.config.real_card_limit - self.edition.card_limit
			end
			G.hand.config.card_limit = G.hand.config.card_limit - self.edition.card_limit
		end
	end

	local old_edition = self.edition and self.edition.key
	if old_edition then
		self.ignore_base_shader[old_edition] = nil
		self.ignore_shadow[old_edition] = nil

		local on_old_edition_removed = G.P_CENTERS[old_edition] and G.P_CENTERS[old_edition].on_remove
		if type(on_old_edition_removed) == "function" then
			on_old_edition_removed(self)
		end
	end

	local edition_type = nil
	if type(edition) == 'string' then
		assert(string.sub(edition, 1, 2) == 'e_', ("Edition \"%s\" is missing \"e_\" prefix."):format(edition))
		edition_type = string.sub(edition, 3)
	elseif type(edition) == 'table' then
		if edition.type then
			edition_type = edition.type
		else
			for k, v in pairs(edition) do
				if v then
					assert(not edition_type, "Tried to apply more than one edition.")
					edition_type = k
				end
			end
		end
	end

	if not edition_type or edition_type == 'base' then
		if self.edition == nil then -- early exit
			return
		end
		self.edition = nil -- remove edition from card
		self:set_cost()
		if not silent then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = not immediate and 0.2 or 0,
				blockable = not immediate,
				func = function()
					self:juice_up(1, 0.5)
					play_sound('whoosh2', 1.2, 0.6)
					return true
				end
			}))
		end
		return
	end

	self.edition = {}
	self.edition[edition_type] = true
	self.edition.type = edition_type
	self.edition.key = 'e_' .. edition_type

	local p_edition = G.P_CENTERS['e_' .. edition_type]

	if p_edition.override_base_shader or p_edition.disable_base_shader then
		self.ignore_base_shader[self.edition.key] = true
	end
	if p_edition.no_shadow or p_edition.disable_shadow then
		self.ignore_shadow[self.edition.key] = true
	end

	for k, v in pairs(p_edition.config) do
		if type(v) == 'table' then
			self.edition[k] = copy_table(v)
		else
			self.edition[k] = v
		end
	end

	local on_edition_applied = p_edition.on_apply
	if type(on_edition_applied) == "function" then
		on_edition_applied(self)
	end


	if self.edition.card_limit then
		if (self.added_to_deck or self.joker_added_to_deck_but_debuffed or (self.area == G.hand and not self.debuff)) and G.jokers and G.consumeables then
			if self.ability.consumeable then
				G.consumeables.config.card_limit = G.consumeables.config.card_limit + self.edition.card_limit
			elseif self.ability.set == 'Joker' then
				G.jokers.config.card_limit = G.jokers.config.card_limit + self.edition.card_limit
			elseif self.area == G.hand then
				local is_in_pack = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or (G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER.config.center.draw_hand))
				G.E_MANAGER:add_event(Event({
					trigger = 'immediate',
					func = function()
						if G.hand.config.real_card_limit then
							G.hand.config.real_card_limit = G.hand.config.real_card_limit + self.edition.card_limit
						end
						G.hand.config.card_limit = G.hand.config.card_limit + self.edition.card_limit
						if not is_in_pack and G.GAME.blind.in_blind then
							G.FUNCS.draw_from_deck_to_hand(self.edition.card_limit)
						end
						return true
					end
				}))
			end
		end
	end

	if self.area and self.area == G.jokers then
		if self.edition then
			if not G.P_CENTERS['e_' .. (self.edition.type)].discovered then
				discover_card(G.P_CENTERS['e_' .. (self.edition.type)])
			end
		else
			if not G.P_CENTERS['e_base'].discovered then
				discover_card(G.P_CENTERS['e_base'])
			end
		end
	end

	if self.edition and not silent then
		local ed = G.P_CENTERS['e_' .. (self.edition.type)]
		G.CONTROLLER.locks.edition = true
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = not immediate and 0.2 or 0,
			blockable = not immediate,
			func = function()
				if self.edition then
					self:juice_up(1, 0.5)
					play_sound(ed.sound.sound, ed.sound.per, ed.sound.vol)
				end
				return true
			end
		}))
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.1,
			func = function()
				G.CONTROLLER.locks.edition = false
				return true
			end
		}))
	end

	if delay then
		self.delay_edition = true
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				self.delay_edition = nil
				return true
			end
		}))
	end

	if G.jokers and self.area == G.jokers then
		check_for_unlock({ type = 'modify_jokers' })
	end

	self:set_cost()
end

-- _key = key value for random seed
-- _mod = scale of chance against base card (does not change guaranteed weights)
-- _no_neg = boolean value to disable negative edition
-- _guaranteed = boolean value to determine whether an edition is guaranteed
-- _options = list of keys of editions to include in the poll
-- OR list of tables { name = key, weight = number }
function poll_edition(_key, _mod, _no_neg, _guaranteed, _options)
	local _modifier = 1
	local edition_poll = pseudorandom(pseudoseed(_key or 'edition_generic')) -- Generate the poll value
	local available_editions = {}                                          -- Table containing a list of editions and their weights

	if not _options then
		if _key == "wheel_of_fortune" or _key == "aura" then -- set base game edition polling
			_options = { 'e_negative', 'e_polychrome', 'e_holo', 'e_foil' }
		else
			local unordered_options = get_current_pool("Edition", nil, nil, _key or 'edition_generic')
			_options = {}
			for _, edition in ipairs(unordered_options) do -- Flip the order of vanilla editions
				if G.P_CENTERS[edition] and G.P_CENTERS[edition].vanilla then
					table.insert(_options, 1, edition)
				else
					table.insert(_options, edition)
				end
			end
		end
	end
    for _, v in ipairs(_options) do
        local edition_option = {}
        if type(v) == 'string' then
            if v ~= 'UNAVAILABLE' then
                assert(string.sub(v, 1, 2) == 'e_', ("Edition \"%s\" is missing \"e_\" prefix."):format(v))
                edition_option = { name = v, weight = G.P_CENTERS[v].weight }
        		table.insert(available_editions, edition_option)
            end
        elseif type(v) == 'table' then
            assert(string.sub(v.name, 1, 2) == 'e_', ("Edition \"%s\" is missing \"e_\" prefix."):format(v.name))
            edition_option = { name = v.name, weight = v.weight }
        	table.insert(available_editions, edition_option)
        end
    end

	-- Calculate total weight of editions
	local total_weight = 0
	for _, v in ipairs(available_editions) do
		total_weight = total_weight + (v.weight) -- total all the weights of the polled editions
	end
	-- sendDebugMessage("Edition weights: "..total_weight, "EditionAPI")
	-- If not guaranteed, calculate the base card rate to maintain base 4% chance of editions
	if not _guaranteed then
		_modifier = _mod or 1
		total_weight = total_weight + (total_weight / 4 * 96) -- Find total weight with base_card_rate as 96%
		for _, v in ipairs(available_editions) do
			v.weight = G.P_CENTERS[v.name]:get_weight()   -- Apply game modifiers where appropriate (defined in edition declaration)
		end
	end
	-- sendDebugMessage("Total weight: "..total_weight, "EditionAPI")
	-- sendDebugMessage("Editions: "..#available_editions, "EditionAPI")
	-- sendDebugMessage("Poll: "..edition_poll, "EditionAPI")

	-- Calculate whether edition is selected
	local weight_i = 0
	for _, v in ipairs(available_editions) do
		weight_i = weight_i + v.weight * _modifier
		-- sendDebugMessage(v.name.." weight is "..v.weight*_modifier, "EditionAPI")
		-- sendDebugMessage("Checking for "..v.name.." at "..(1 - (weight_i)/total_weight), "EditionAPI")
		if edition_poll > 1 - (weight_i) / total_weight then
			if not (v.name == 'e_negative' and _no_neg) then -- skip return if negative is selected and _no_neg is true
				-- sendDebugMessage("Matched edition: "..v.name, "EditionAPI")
				return v.name
			end
		end
	end

	return nil
end

-- local cge = Card.get_edition
-- function Card:get_edition()
-- 	if self.ability.extra_enhancement then return end
-- 	local ret = cge(self)
-- 	if self.edition and self.edition.key then
-- 		local ed = SMODS.Centers[self.edition.key]
-- 		if ed.calculate and type(ed.calculate) == 'function' then
-- 			ed:calculate(self, {edition_main = true, edition_val = ret})
-- 		end
-- 	end
-- 	return ret
-- end

function get_joker_win_sticker(_center, index)
	local joker_usage = G.PROFILES[G.SETTINGS.profile].joker_usage[_center.key] or {}
	if joker_usage.wins then
		local applied = {}
		local _count = 0
		local _stake = nil
		for k, v in pairs(joker_usage.wins_by_key or {}) do
			SMODS.build_stake_chain(G.P_STAKES[k], applied)
		end
		for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
			if applied[v.order] then
				_count = _count+1
				if (v.stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) then
					_stake = v.key
				end
			end
		end
		if index then return _count end
		if _count > 0 then return G.sticker_map[_stake] end
	end
	if index then return 0 end
end

function get_deck_win_stake(_deck_key)
	if not _deck_key then
		local _stake, _stake_low = nil, nil
		local deck_count = 0
		for _, deck in pairs(G.PROFILES[G.SETTINGS.profile].deck_usage) do
			local deck_won_with = false
			for key, _ in pairs(deck.wins_by_key or {}) do
				deck_won_with = true
				if (G.P_STAKES[key] and G.P_STAKES[key].stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) then
					_stake = key
				end
			end
			if deck_won_with then deck_count = deck_count + 1 end
			if not _stake_low then _stake_low = _stake end
			if (_stake and G.P_STAKES[_stake] and G.P_STAKES[_stake].stake_level or 0) < (_stake_low and G.P_STAKES[_stake_low].stake_level or 0) then
				_stake_low = _stake
			end
		end
		return _stake and G.P_STAKES[_stake].order or 0, (deck_count >= #G.P_CENTER_POOLS.Back and G.P_STAKES[_stake_low].order or 0)
	end
	if G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key] and G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key].wins_by_key then
		local _stake = nil
		for key, _ in pairs(G.PROFILES[G.SETTINGS.profile].deck_usage[_deck_key].wins_by_key) do
			if (G.P_STAKES[key] and G.P_STAKES[key].stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) then
				_stake = key
			end
		end
		if _stake then return G.P_STAKES[_stake].order end
	end
	return 0
end

function get_deck_win_sticker(_center)
	if G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key] and
	G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key].wins_by_key then
		local _stake = nil
		for key, _ in pairs(G.PROFILES[G.SETTINGS.profile].deck_usage[_center.key].wins_by_key) do
			if (G.P_STAKES[key] and G.P_STAKES[key].stake_level or 0) > (_stake and G.P_STAKES[_stake].stake_level or 0) then
				_stake = key
			end
		end
		if _stake then return G.sticker_map[_stake] end
	end
end

function set_deck_win()
	if G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.center and G.GAME.selected_back.effect.center.key then
		local deck_key = G.GAME.selected_back.effect.center.key
		local deck_usage = G.PROFILES[G.SETTINGS.profile].deck_usage[deck_key]
		if not deck_usage then deck_usage = { count = 1, order =
			G.GAME.selected_back.effect.center.order, wins = {}, losses = {}, wins_by_key = {}, losses_by_key = {} } end
		if deck_usage then
			deck_usage.wins[G.GAME.stake] = (deck_usage.wins[G.GAME.stake] or 0) + 1
			deck_usage.wins_by_key[SMODS.stake_from_index(G.GAME.stake)] = (deck_usage.wins_by_key[SMODS.stake_from_index(G.GAME.stake)] or 0) + 1
			local applied = SMODS.build_stake_chain(G.P_STAKES[SMODS.stake_from_index(G.GAME.stake)]) or {}
			for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
				if applied[i] then
					deck_usage.wins[i] = math.max(deck_usage.wins[i] or 0, 1)
					deck_usage.wins_by_key[SMODS.stake_from_index(i)] = math.max(deck_usage.wins_by_key[SMODS.stake_from_index(i)] or 0, 1)
				end
			end
		end
		set_challenge_unlock()
		G:save_settings()
		G.PROFILES[G.SETTINGS.profile].deck_usage[deck_key] = deck_usage
	end
end

function Card:align_h_popup()
	local focused_ui = self.children.focused_ui and true or false
	local popup_direction = (self.children.buy_button or (self.area and self.area.config.view_deck) or (self.area and self.area.config.type == 'shop')) and 'cl' or
							(self.T.y > G.CARD_H*0.8 and self.T.y < G.CARD_H*1.8) and ((self.T.x > G.ROOM.T.w*0.4) and "cl" or "cr") or
							(self.T.y < G.CARD_H*0.8) and 'bm' or
							'tm'
	local sign = 1
	if popup_direction == 'cl' and self.T.x <= G.ROOM.T.w*0.4 then
		popup_direction = 'cr'
		sign = -1
	end
	return {
		major = self.children.focused_ui or self,
		parent = self,
		xy_bond = 'Strong',
		r_bond = 'Weak',
		wh_bond = 'Weak',
		offset = {
			x = popup_direction ~= 'cl' and popup_direction ~= 'cr' and 0 or
				focused_ui and sign*-0.05 or
				(self.ability.consumeable and 0.0) or
				(self.ability.set == 'Voucher' and 0.0) or
				sign*-0.05,
			y = focused_ui and (
						popup_direction == 'tm' and (self.area and self.area == G.hand and -0.08 or-0.15) or
						popup_direction == 'bm' and 0.12 or
						0
					) or
				popup_direction == 'tm' and -0.13 or
				popup_direction == 'bm' and 0.1 or
				0
		},
		type = popup_direction,
		--lr_clamp = true
	}
end

function get_pack(_key, _type)
    if not G.GAME.first_shop_buffoon and not G.GAME.banned_keys['p_buffoon_normal_1'] then
        G.GAME.first_shop_buffoon = true
        return G.P_CENTERS['p_buffoon_normal_'..(math.random(1, 2))]
    end
    local cume, it, center = 0, 0, nil
	local temp_in_pool = {}
    for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
		local add
		v.current_weight = v.get_weight and v:get_weight() or v.weight or 1
        if (not _type or _type == v.kind) then add = true end
		if v.in_pool and type(v.in_pool) == 'function' then
			local res, pool_opts = v:in_pool()
			pool_opts = pool_opts or {}
			add = res and (add or pool_opts.override_base_checks)
		end
		if add and not G.GAME.banned_keys[v.key] then cume = cume + (v.current_weight or 1); temp_in_pool[v.key] = true end
    end
    local poll = pseudorandom(pseudoseed((_key or 'pack_generic')..G.GAME.round_resets.ante))*cume
    for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
        if temp_in_pool[v.key] then
            it = it + (v.current_weight or 1)
            if it >= poll and it - (v.current_weight or 1) <= poll then center = v; break end
        end
    end
   if not center then center = G.P_CENTERS['p_buffoon_normal_1'] end  return center
end

function playing_card_joker_effects(cards)
	SMODS.calculate_context({playing_card_added = true, cards = cards})
end

G.FUNCS.change_collab = function(args)
	G.SETTINGS.CUSTOM_DECK.Collabs[args.cycle_config.curr_suit] = G.COLLABS.options[args.cycle_config.curr_suit][args.to_key] or 'default'
	local deckskin_key = G.COLLABS.options[args.cycle_config.curr_suit][args.to_key]
	local palette_loc_options = SMODS.DeckSkin.get_palette_loc_options(args.to_key, args.cycle_config.curr_suit)
	local swap_node = G.OVERLAY_MENU:get_UIE_by_ID('palette_selector')
	local selected_palette = 1
	for i, v in ipairs(G.COLLABS.colour_palettes[deckskin_key]) do
		if G.SETTINGS.colour_palettes[args.cycle_config.curr_suit] == v then
			selected_palette = i
		end
	end
	G.FUNCS.update_suit_colours(args.cycle_config.curr_suit, deckskin_key, selected_palette)
	G.FUNCS.update_collab_cards(args.to_key, args.cycle_config.curr_suit)
	if swap_node then
		for i=1, #swap_node.children do
			swap_node.children[i]:remove()
			swap_node.children[i] = nil
		end
		local new_palette_selector = {n=G.UIT.R, config={align = "cm", id = 'palette_selector'}, nodes={
			create_option_cycle({options = palette_loc_options, w = 5.5, cycle_shoulders = false, curr_suit = args.cycle_config.curr_suit, curr_skin = deckskin_key, opt_callback = 'change_colour_palette', current_option = selected_palette, colour = G.C.ORANGE, focus_args = {snap_to = true, nav = 'wide'}}),
		}}
		swap_node.UIBox:add_child(new_palette_selector, swap_node)
	end
	for k, v in pairs(G.I.CARD) do
		if v.config and v.config.card and v.children.front and v.ability.effect ~= 'Stone Card' then
			v:set_sprites(nil, v.config.card)
		end
	end
	G:save_settings()
end

G.FUNCS.change_colour_palette = function(args)
	G.SETTINGS.colour_palettes[args.cycle_config.curr_suit] = G.COLLABS.colour_palettes[args.cycle_config.curr_skin][args.to_key]
	G.FUNCS.update_suit_colours(args.cycle_config.curr_suit, args.cycle_config.curr_skin)
	G.FUNCS.update_collab_cards(args.cycle_config.curr_skin, args.cycle_config.curr_suit)
	for k, v in pairs(G.I.CARD) do
		if v.config and v.config.card and v.children.front and v.ability.effect ~= 'Stone Card' then
			v:set_sprites(nil, v.config.card)
		end
	end
	G:save_settings()
end

-- blind calc contexts
local disable = Blind.disable
function Blind:disable()
	disable(self)
	SMODS.calculate_context({ blind_disabled = true })
end

local defeat = Blind.defeat
function Blind:defeat(silent)
	defeat(self, silent)
	SMODS.calculate_context({ blind_defeated = true })
end

local press_play = Blind.press_play
function Blind:press_play()
	local ret = press_play(self)
	SMODS.calculate_context({ press_play = true })
	return ret
end

local debuff_card = Blind.debuff_card
function Blind:debuff_card(card, from_blind)
	local flags = SMODS.calculate_context({ debuff_card = card, ignore_debuff = true })
	if flags.prevent_debuff then 
		if card.debuff then card:set_debuff(false) end
		return
	elseif flags.debuff then
		if not card.debuff then card:set_debuff(true) end
		return
	end
	debuff_card(self, card, from_blind)
end

local debuff_hand = Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
	SMODS.hand_debuff_source = nil
	local ret = debuff_hand(self, cards, hand, handname, check)
	local _, _, _, scoring_hand = G.FUNCS.get_poker_hand_info(cards)
	local final_scoring_hand = {}
    for i=1, #cards do
        local splashed = SMODS.always_scores(cards[i]) or next(find_joker('Splash'))
        local unsplashed = SMODS.never_scores(cards[i])
        if not splashed then
            for _, card in pairs(scoring_hand) do
                if card == cards[i] then splashed = true end
            end
        end
        local effects = {}
        SMODS.calculate_context({modify_scoring_hand = true, other_card =  cards[i], full_hand = cards, scoring_hand = scoring_hand}, effects)
        local flags = SMODS.trigger_effects(effects, cards[i])
		if flags.add_to_hand then splashed = true end
		if flags.remove_from_hand then unsplashed = true end
        if splashed and not unsplashed then table.insert(final_scoring_hand, G.play.cards[i]) end
    end
	local flags = SMODS.calculate_context({ debuff_hand = true, full_hand = cards, scoring_hand = final_scoring_hand, poker_hands = hand, scoring_name = handname, check = check })
	if flags.prevent_debuff then return false end
	if flags.debuff then
		SMODS.debuff_text = flags.debuff_text
		SMODS.hand_debuff_source = flags.debuff_source
		return true
	end
	SMODS.debuff_text = nil
	return ret
end

local stay_flipped = Blind.stay_flipped
function Blind:stay_flipped(to_area, card, from_area)
	local ret = stay_flipped(self, to_area, card, from_area)
	local flags = SMODS.calculate_context({ to_area = to_area, from_area = from_area, other_card = card, stay_flipped = true })
	local self_eval, self_post = eval_card(card, { to_area = to_area, from_area = from_area, other_card = card, stay_flipped = true })
	local self_flags = SMODS.trigger_effects({ self_eval, self_post })
	for k,v in pairs(self_flags) do flags[k] = flags[k] or v end
	if flags.prevent_stay_flipped then return false end
	if flags.stay_flipped then return true end
	return ret
end

local modify_hand = Blind.modify_hand
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips, scoring_hand)
	local modded
	_G.mult, _G.hand_chips, modded = modify_hand(self, cards, poker_hands, text, mult, hand_chips, scoring_hand)
	local flags = SMODS.calculate_context({ modify_hand = true, poker_hands = poker_hands, scoring_name = text, scoring_hand = scoring_hand, full_hand = cards })
	return _G.mult, _G.hand_chips, modded or flags.calculated
end

local use_consumeable = Card.use_consumeable
function Card:use_consumeable(area, copier)
	local ret = use_consumeable(self, area, copier)
	if SMODS.post_prob and next(SMODS.post_prob) then
        local prob_tables = SMODS.post_prob
        SMODS.post_prob = {}
        for i, v in ipairs(prob_tables) do
            v.pseudorandom_result = true
            SMODS.calculate_context(v)
        end
    end
	return ret
end