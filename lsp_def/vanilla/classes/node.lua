---@meta

---@class Node: Object
---@overload fun(args: {T: table, container: Node}): Node
Node = {}
Node.__index = Node
Node.super = Object

---@param self Node
---@param args {T: table, container: Node}
---@return Node
function Node:__call(args) end

---@param self Node
---@param args {T: table, container: Node}
function Node:init(args) end

---@param self Node
--- Draw a bounding rectangle representing the transform of this node. Used in debugging.
function Node:draw_boundinrect() end

---@param self Node
--- Draws Node. 
function Node:draw() end

---@param self Node
---@param point {x: number, y: number} The coordinates of the cursor transformed into game units
---@return boolean
--- Determines if this node collides with some point. Applies any container translations and rotations, then\
--- applies translations and rotations specific to this node. This means the collision detection effectively\
--- determines if some point intersects this node regargless of rotation.
function Node:collides_with_point(point) end

---@param self Node
---@param point {x: number, y: number} The coordinates of the cursor transformed into game units
---@param type string The type of offset to set for this Node, either 'Click' or 'Hover'
--- Sets the offset of passed point in terms of this nodes T.x and T.y
function Node:set_offset(point, type) end

---@param self Node
--- If the current container is being 'Dragged', usually by a cursor, determine if any drag popups need to be generated and do so
function Node:drag() end

---@param self Node
---@return Node?
--- Determines if this Node can be dragged. This is a simple function but more complex objects may redefine this to return a parent\
--- if the parent needs to drag other children with it
function Node:can_drag() end

---@param self Node
--- Called by the CONTROLLER when this node is no longer being dragged, removes any d_popups
function Node:stop_drag() end

---@param self Node
--- If the current container is being 'Hovered', usually by a cursor, determine if any hover popups need to be generated and do so
function Node:hover() end

---@param self Node
--- Called by the CONTROLLER when this node is no longer being hovered, removes any h_popups
function Node:stop_hover() end

---@param self Node
---@return number x
---@return number y
--- Called by the CONTROLLER to determine the position the cursor should be set to for this node
function Node:put_focused_cursor() end

---@param self Node
---@param container Node The new node that will behave as this nodes container
--- Sets the container of this node and all child nodes to be a new container node
function Node:set_container(container) end

---@param self Node
--- Translation function used before any draw calls, translates this node according to the transform of the container node
function Node:translate_container() end

---@param self Node
--- When this Node needs to be deleted, removes self from any tables it may have been added to to destroy any weak references\
--- Also calls the remove method of all children to have them do the same
function Node:remove() end

---@param self Node
---@param other_node Node to measure the distance from
---@return number
--- returns the squared(fast) distance in game units from the center of this node to the center of another node
function Node:fast_mid_dist(other_node) end

---@param self Node
---@param dragged table
--- Prototype for a click release function, when the cursor is released on this node
function Node:release(dragged) end

---@param self Node
--- Prototype for a click function
function Node:click() end

---@param self Node
--- Prototype animation function for any frame manipulation needed 
function Node:animate() end

---@param self Node
---@param dt number
--- Prototype update function for any object specific logic that needs to occur every frame
function Node:update(dt) end