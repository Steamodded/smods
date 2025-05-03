---@meta

---@class Card: Moveable
---@field ability? table
---@field ignore_base_shader? table
---@field ignore_shadow? table
---@overload fun(X: number, Y: number, W: number, H: number, card: table, center: table, params?: table): Card
Card = {}
Card.__index = Card
Card.super = Moveable

---@param self Card
---@param X number
---@param Y number
---@param W number
---@param H number
---@param card table
---@param center table
---@param params table
---@return Card
function Card:__call(X, Y, W, H, card, center, params) end

---@param self Card
---@param X number
---@param Y number
---@param W number
---@param H number
---@param card table
---@param center table
---@param params table
function Card:init(X, Y, W, H, card, center, params) end

---@param self Card
--- Update the alert UIBox on this card.
function Card:update_alert() end

---@param self Card
---@param card? table 
---@param initial? boolean
--- Sets the `base` table for this Card.
function Card:set_base(card, initial) end

---@param self Card
---@param _center? table
---@param _front? table
--- Sets the sprites for this Card.
function Card:set_sprites(_center, _front) end

---@param self Card
---@param center table
---@param initial? boolean
---@param delay_sprites? boolean
--- Sets the `ability` table for this Card.
function Card:set_ability(center, initial, delay_sprites) end

---@param self Card
--- Sets the Card's cost, sell cost, and associated labels.
function Card:set_cost() end

---@param self Card|table
---@param edition string|{[string]: true}? Both `string` values are the key of the edition to apply. 
---@param immediate? boolean
---@param silent? boolean 
---@param delay? boolean
--- Sets the card's edition. 
function Card:set_edition(edition, immediate, silent, delay) end

---@param self Card
---@param _seal string Key to the Seal
---@param silent? boolean
---@param immediate? boolean
--- Sets the seal of the Card
function Card:set_seal(_seal, silent, immediate) end

---@param self Card
---@param bypass_debuff? boolean 
---@return string?
--- Gets the seal of this Card.
function Card:get_seal(bypass_debuff) end

---@param self Card
---@param _eternal boolean
--- Sets if the Card has the "Eternal" sticker.
function Card:set_eternal(_eternal) end

---@param self Card
---@param _perishable? boolean Unused in vanilla
--- Sets the card to have the "Perishable" sticker.
function Card:set_perishable(_perishable) end

---@param self Card
---@param _rental boolean
--- Sets if the Card has the "Rental" sticker.
function Card:set_rental(_rental) end

---@param self Card
---@param should_debuff? boolean
--- Sets if the card should be debuffed.
function Card:set_debuff(should_debuff) end

---@param self Card
--- Removes all UI elements from the Card.
function Card:remove_UI() end

---@param self Card
---@param new_suit string
--- Changes the suit of the Card.
function Card:change_suit(new_suit) end

---@param self Card
---@param from_debuff? boolean
--- Adds the Card to the run and their respective CardArea.
function Card:add_to_deck(from_debuff) end

---@param self Card
---@param from_debuff? boolean
--- Removes the Card from the run and their respective CardArea.
function Card:remove_from_deck(from_debuff) end

---@param self Card
---@param hidden? boolean Hides the description.
--- Handles the hover UI for the Card's unlock.
function Card:generate_UIBox_unlock_table(hidden) end

---@param self Card
---@param vars_only? boolean Only return description values
---@return table # Becomes `loc_vars` if `vars_only` is `true`.
---@return table? man_start Only returns if `vars_only` is `true`.
---@return table? main_end Only returns if `vars_only` is `true`.
--- Handles the hover UI for the Card.
--- Wrapper over `generate_card_ui()`. 
function Card:generate_UIBox_ability_table(vars_only) end

---@param self Card
---@param mod? string 
---@return number
--- Returns the nominal of the Card.
function Card:get_nominal(mod) end

---@param self Card
---@return number
--- Returns the ID of the Card.
function Card:get_id() end

---@param self Card
---@param from_boss? boolean
---@return boolean
--- Returns `true` if the Card is considered a "Face" card.
function Card:is_face(from_boss) end

---@param self Card
---@return number
--- Returns the original rank of the Card.
function Card:get_original_rank() end

---@param self Card
---@return number
--- Returns card Mult.
function Card:get_chip_mult() end

---@param self Card
---@return number
--- Returns card XMult.
function Card:get_chip_x_mult() end

---@param self Card
---@return number
--- Returns card hand Mult.
function Card:get_chip_h_mult() end

---@param self Card
---@return number
--- Returns card hand XMult.
function Card:get_chip_h_x_mult() end

---@param self Card
---@return number
--- Returns card XChips.
function Card:get_chip_x_bonus() end

---@param self Card
---@return number
--- Returns card hand Chips.
function Card:get_chip_h_bonus() end

---@param self Card
---@return number
--- Returns card hand XChips.
function Card:get_chip_h_x_bonus() end

---@param self Card
---@return number
--- Returns card dollars.
function Card:get_p_dollars() end

---@param self Card
---@return number
--- Returns card hand dollars.
function Card:get_h_dollars() end

---@deprecated
---@param self Card
---@return table
--- Gets the edition values of the Card.
--- Unused after the introduction of BetterCalc.
function Card:get_edition() end

---@param self Card
---@param context CalcContext
---@return table
--- Returns the end of round effects for playing cards.
function Card:get_end_of_round_effect(context) end

---@param self Card
---@param area CardArea Unused in vanilla
---@param copier? Card Unused in vanilla
--- Handles logic when a consumable is used.
function Card:use_consumeable(area, copier) end

---@param self Card
---@param any_state? boolean
---@param skip_check? boolean
---@return boolean 
--- Checks if the consumable can be used.
function Card:can_use_consumeable(any_state, skip_check) end

---@param self Card
---@return boolean?
--- Checks if the card could not be used (e.x. Ankh).
function Card:check_use() end

---@param self Card
--- Sells the Card.
function Card:sell_card() end

---@param self Card
---@param context? any Unused in vanilla.
---@return boolean
--- Checks if the Card can be sold.
function Card:can_sell_card(context) end

---@param self Card
---@return number
--- Calculates how much money this Joker will earn at end of round.
function Card:calculate_dollar_bonus() end

---@param self Card
--- Handles the opening of this Booster Pack.
function Card:open() end

---@param self Card
--- Redeems this Voucher.
function Card:redeem() end

---@param self Card
---@param center? table
--- Applies the Voucher to this run.
function Card:apply_to_run(center) end

---@param self Card
---@param dissolve_colours? table
---@param explode_time_fac? number
--- Destroys the Card with an explosion animation.
function Card:explode(dissolve_colours, explode_time_fac) end

---@param self Card
--- Destroys the Card and plays a shatter animation.
function Card:shatter() end

---@param self Card
---@param dissolve_colours Color[]
---@param silent? boolean
---@param dissolve_time_fac? number
---@param no_juice? boolean
--- Destroys the Card with a dissolve animation.
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice) end

---@param self Card
---@param dissolve_colours? Color[]
---@param silent? boolean
---@param timefac? number
--- Starts the materialization animation for the Card.
function Card:start_materialize(dissolve_colours, silent, timefac) end

---@param self Card
---@param context CalcContext
---@return table?
--- Calculates the seal.
function Card:calculate_seal(context) end

---@param self Card
--- calculates the Rental sticker's effect.
function Card:calculate_rental() end

---@param self Card
--- Calculates the Perishable sticker's effect.
function Card:calculate_perishable() end

---@param self Card|table
---@param context CalcContext|table
---@return table? effect
---@return boolean? # Return `true` if the Joker was calculated but no effect was provided. 
--- Calculates Jokers. 
function Card:calculate_joker(context) end

---@param self Card
---@param suit string Suit to check
---@param bypass_debuff? boolean 
---@param flush_calc? boolean 
---@return boolean
--- Checks if the Card is of provided `suit`.
function Card:is_suit(suit, bypass_debuff, flush_calc) end

---@param self Card
---@param area CardArea
--- Sets the Card's area. 
function Card:set_card_area(area) end

---@param self Card
--- Removes the Card from it's current CardArea.
function Card:remove_from_area() end

---@param self Card
--- Aligns the floating sprite and any focused UI elements to this card.
function Card:align() end

---@param self Card
--- Flips the Card.
function Card:flip() end

---@param self Card
---@param dt number
--- Updates the Card.
function Card:update(dt) end

---@param self Card
---@param X number
---@param Y number
---@param W number
---@param H number
--- Hard sets the Card's transform.
function Card:hard_set_T(X, Y, W, H) end

---@param self Card
---@param dt number
--- Moves the Card.
function Card:move(dt) end

---@param self Card
--- Align the hover popup from this Card/
function Card:align_h_popup() end

---@param self Card
--- Handles hover logic for this Card.
function Card:hover() end

---@param self Card
--- Handles logic when the Card stops being hovered.
function Card:stop_hover() end

---@param self Card
---@param layer? string
--- Handles draw logic for this Card.
function Card:draw(layer) end

---@param self Card
---@param dragged table
--- Handles logic for when the Card is released.
function Card:release(dragged) end

---@param self Card
---@param is_higlighted boolean
--- Handles logic when the Card is highlighted, or has stopped being highlighted.
function Card:highlight(is_higlighted) end

---@param self Card
--- Handles logic when the card is being clicked.
function Card:click() end

---@param self Card
---@return table
--- Returns a table representing this card to be saved.
function Card:save() end

---@param self Card
---@param cardTable table
---@param other_card? any Unused in vanilla.
--- Loads a card based on `cardTable`.
function Card:load(cardTable, other_card) end

---@param self Card
--- Removes the card.
function Card:remove() end
