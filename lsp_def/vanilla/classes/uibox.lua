---@meta

---@class UIBox: Moveable
---@overload fun(args: {T: table, definition: table, config: table}): UIBox
UIBox = {}
UIBox.__index = UIBox
UIBox.super = Moveable

---@param self UIBox
---@param args {T: table, definition: table, config: table}
---@return UIBox
function UIBox:__call(args) end

---@param self UIBox
---@param args {T: table, definition: table, config: table}
---The base level and container of a graph of 1 or more UIElements. These UIEs are\
---essentially a node based UI implementation. As the root node of the graph, this\
---node is the first called for any movement, updates, or changes to ensure that all child\
---nodes are updated and modified in the correct order.\\
---The UI_definitions file houses the majority of the definition tables needed for UIBox initialization.
---
---**T** A standard transform in game units describing the inital position and size of the object with x, y, w, h\
---ex - {x = 1, y = 5, w = 2, h = 2, r = 0}
---
---**definition** A table containing a valid UIBox definition. These are mostly generated from UI_definitions
---
---**config** A configuration table for the UIBox
---ex - { align = 'cm', offset = {x = 1, y = 1}, parent_rect = A, attach_rect = B, can_collide = true }
function UIBox:init(args) end

---@param self UIBox
---@param id string UIElement ID
---@param node UIElement
---@return UIElement? 
--- Returns a child UIElement with an ID matching `ID` arg.
function UIBox:get_UIE_by_ID(id, node) end

---@param self UIBox
---@param node UIElement
---@param _T {x: number, y: number, h: number, w: number}
---@param recalculate true?
---@param _scale number?
---@return number _nt.h
---@return number _nt.w
--- Calculates UIBox X, Y, width, and height.
function UIBox:calculate_xywh(node, _T, recalculate, _scale) end

---@param self UIBox
---@param node? UIElement
---@param group number
--- Removes the group from the provided UIElement.
function UIBox:remove_group(node, group) end

---@param self UIBox
---@param node UIElement
---@param group number
---@param ingroup? UIElement[]
---@return UIElement[] ingroup
--- Returns a table of all UIElements a part of provided `group`.
function UIBox:get_group(node, group, ingroup) end

---@param self UIBox
---@param node UINode
---@param parent? UIElement
--- Sets provided `node` to be a child of `parent`, or UIBox.
function UIBox:set_parent_child(node, parent) end

---@param self UIBox
--- Removes the UIBox.
function UIBox:remove() end

---@param self UIBox
--- Draws the UIBox.
function UIBox:draw() end

---@param self UIBox
--- Recalculates UIBox position and size.
function UIBox:recalculate() end

---@param self UIBox
---@param dt number
--- Moves the UIBox.
function UIBox:move(dt) end

---@param self UIBox
---@param offset? {x: number, y: number}
--- Drags the UIBox.
function UIBox:drag(offset) end

---@param self UIBox
---@param node UINode
---@param parent? UIElement
--- Adds a child UIElement to provided `parent`, or UIBox.
function UIBox:add_child(node, parent) end

---@param self UIBox
---@param container Node The new node that will behave as this nodes container.
--- Sets the UIBox and all child UIBoxes and UIElements to be a new container node.
function UIBox:set_container(container) end

---@param self UIBox
---@param indent? number
---@return string
--- Returns a string to print with top-level UIBox info.
function UIBox:print_topology(indent) end


---@class UIElement: Moveable
---@overload fun(parent: UIElement, new_UIBox: UIBox, new_UIT: table, config: table): UIElement
UIElement = {}
UIElement.__index = UIElement
UIElement.super = Moveable

---@param self UIElement
---@param parent UIElement
---@param new_UIBox UIBox
---@param new_UIT table
---@param config table
---@return UIElement
function UIElement:__call(parent, new_UIBox, new_UIT, config) end

---@param self UIElement
---@param parent UIElement
---@param new_UIBox UIBox
---@param new_UIT table
---@param config table
function UIElement:init(parent, new_UIBox, new_UIT, config) end

---@param self UIElement
---@param _T {x: number, y: number, h: number, w: number}
---@param recalculate? true
--- Sets UIElement position and size based on `_T`.
function UIElement:set_values(_T, recalculate) end

---@param self UIElement
---@param indent? number
---@return string 
--- Returns a string to print with UIElement information. 
function UIElement:print_topology(indent) end

---@param self UIElement
--- Updates the VT of this UIElement and it's children.
function UIElement:initialize_VT() end

---@param self UIElement
---@param amount number
---@param rot_amt number
--- Controls juice amount for the UIElement. 
function UIElement:juice_up(amount, rot_amt) end

---@param self UIElement
---@return UIElement|UIBox?
--- Checks if the UIElement can be dragged.
function UIElement:can_drag() end

---@param self UIElement
---@param layer? any Unused by default.
--- Draws the children of this UIElement.
function UIElement:draw_children(layer) end

---@param self UIElement
---@return number width
---@return number height
--- Sets and returns the width and height of the UIElement.
function UIElement:set_wh() end

---@param self UIElement
---@param x number
---@param y number
--- Aligns the UIElement.
function UIElement:align(x, y) end

---@param self UIElement
--- Sets UIElement alignment.
function UIElement:set_alignments() end

---@param self UIElement
--- Updates text within the UIElement.
function UIElement:update_text() end

---@param self UIElement
--- Updates the Object inside the UIElement.
function UIElement:update_object() end

---@param self UIElement
--- Draws the UIElement.
function UIElement:draw_self() end

---@param self UIElement
---@param _type string
---@param _parallax number
---@param _emboss? true
---@param _progress? number
--- Draws the `pixellated_rect` of the UIElement.
function UIElement:draw_pixellated_rect(_type, _parallax, _emboss, _progress) end

---@param self UIElement
---@param dt number
--- Updates the UIElement.
function UIElement:update(dt) end

---@param self UIElement
--- Handles button presses attached to this UIElement.
function UIElement:click() end

---@param self UIElement
---@return number x
---@return number y
--- Called by the CONTROLLER to determine the position the cursor should be set to for this UIElement.
function UIElement:put_focused_cursor() end

---@param self UIElement
--- Removes the UIElement.
function UIElement:remove() end

---@param self UIElement
--- Handles tooltips when the UIElemet is hovered.
function UIElement:hover() end

---@param self UIElement
--- Called by the CONTROLLER when this UIElement is no longer being hovered, removes any h_popups
function UIElement:stop_hover() end

---@param self UIElement
--- Handles when the cursor is released on this UIElement.
function UIElement:release(other) end

---@param node UIElement
---@return boolean
--- Return `true` if passed UIElement is a "container" node (`G.UIT.C`, `G.UIT.R`, `G.UIT.ROOT`)
function is_UI_containter(node) end