SMODS.SUI = {}

SMODS.SUI.classes = {}

SMODS.SUI.special_config_keys = {
	n = true, -- element type
	config = true, -- element config
	nodes = true, -- element children

	s_config = true, -- internal sui config
	s_hooks = true, -- list of hooks to apply on element creation
	s_init = true, -- init function
	s_class = true, -- css class
}

-- Utilities

-- Formats number from range 0-1 to HEX component 00-FF
function SMODS.SUI.to_hex(v)
	return string.format("%02X", math.floor(v * 255 + 0.5))
end
-- Formats colour from format `{ r, g, b, a }` to `#RRGGBB`.
-- If `a` is less than 1, format to `#RRGGBBAA` instead.
function SMODS.SUI.colour_to_hex(colour)
	colour = colour or { 0, 0, 0, 0 }

	local hex = "#" .. SMODS.SUI.to_hex(colour[1]) .. SMODS.SUI.to_hex(colour[2]) .. SMODS.SUI.to_hex(colour[3])

	if colour[4] < 1 then
		hex = hex .. SMODS.SUI.to_hex(colour[4])
	end

	return hex
end
-- Extended Lua's `type()` function to check is passed input is `Moveable` or can be treated as node definition.
function SMODS.SUI.input_type(input)
	local itype = type(input)
	if itype == "table" then
		if Object.is(input, Moveable) then
			return "moveable"
		end
		if input.n then
			return "node"
		end
	end
	return itype or "nil"
end
-- Easy way to attach multiple hooks to table in bulk. In hook function passed as first argument, all other arguments goes after it.
function SMODS.SUI.attach_hooks(target, hooks)
	if not target or not hooks then
		return target
	end
	for func_key, new_func in pairs(hooks) do
		local old_func = target[func_key] or function() end
		target[func_key] = function(self, ...)
			return new_func(old_func, self, ...)
		end
	end
	return target
end
-- Checks is element's type considered as column element.
function SMODS.SUI.is_column_type(n)
	return n == G.UIT.C or n == G.UIT.B or n == G.UIT.T or n == G.UIT.O
end

-- Storages for keys which needs to be resolved by iterating dictionaries

SMODS.SUI.UIT_STORAGE = {
	buffer = {},
	fallback_to_unknown = false,
	get_tables = function(self)
		return {
			[""] = G.UIT,
		}
	end,
}
SMODS.SUI.DEBUG_UIT_STORAGE = {
	buffer = {},
	fallback_to_unknown = true,
	unknown_next_index = 1,
	unknown_prefix = "?UIT",
	get_tables = function(self)
		return {
			[""] = G.UIT,
		}
	end,
}
SMODS.SUI.DEBUG_CLASS_STORAGE = {
	buffer = {},
	fallback_to_unknown = true,
	unknown_next_index = 1,
	unknown_prefix = "?Class",
	get_tables = function(self)
		return {
			[""] = _G,
			["SMODS."] = SMODS,
			["SMODS.SUI."] = SMODS.SUI,
		}
	end,
}

function SMODS.SUI.create_storage(storage)
	return function(input)
		-- Get value from buffer
		if storage.buffer[input] then
			return storage.buffer[input]
		end
		-- Process all tables looking for input
		for table_key, table_value in pairs(storage:get_tables()) do
			for key, value in pairs(table_value) do
				if value == input then
					local result_key = table_key .. key
					storage.buffer[input] = result_key
					return result_key
				end
			end
		end

		if storage.fallback_to_unknown then
			-- Mark as unknown
			local result_key = storage.unknown_prefix .. storage.unknown_next_index
			storage.unknown_next_index = storage.unknown_next_index + 1
			storage.buffer[input] = result_key
			return result_key
		end

		return nil
	end
end

-- Way to resolve G.UIT values as a key
SMODS.SUI.get_uit_key = SMODS.SUI.create_storage(SMODS.SUI.UIT_STORAGE)
-- Way to resolve G.UIT values as a key for debug purposes, marking unknown ones
SMODS.SUI.get_debug_uit_key = SMODS.SUI.create_storage(SMODS.SUI.DEBUG_UIT_STORAGE)
-- Way to resolve instances of Object as class name for debug purposes, marking unknown ones
SMODS.SUI.get_debug_object_class_name = SMODS.SUI.create_storage(SMODS.SUI.DEBUG_CLASS_STORAGE)

-- Base element behaviour

function SMODS.SUI.config_merge(node, key, value)
	node.config[key] = value
end
function SMODS.SUI.node_merge(node, index, child)
	node.nodes[table.maxn(node.nodes) + 1] = child
end
function SMODS.SUI.extended_process_node(node, index, child)
	local input_type = SMODS.SUI.input_type(child)

	-- Wrap Moveable into G.UIT.O
	if input_type == "moveable" then
		child = SUI.O({ child })
		input_type = "node"
	-- Wrap string and numbers in G.UIT.T
	elseif input_type == "string" or input_type == "number" then
		child = SUI.T({ colour = G.C.UI.TEXT_LIGHT, scale = 0.32, text = child })
		input_type = "node"
	end
	if input_type == "node" then
		-- Perform R/C fix: element behave unpredictably when R/C elements are mixed inside one parent.
		-- if target not specified, first element's type will used as target.
		if node.s_config.rc_fix_target == nil or node.s_config.rc_fix_target == true then
			if SMODS.SUI.is_column_type(child.n) then
				node.s_config.rc_fix_target = "C"
			elseif child.n == G.UIT.R then
				node.s_config.rc_fix_target = "R"
			end
			SMODS.SUI.Node.process_node(node, index, child)
		elseif node.s_config.rc_fix_target == "C" and not SMODS.SUI.is_column_type(child.n) then
			SMODS.SUI.Node.process_node(node, index, SUI.C({ align = node.s_config.rc_fix_align, child }))
		elseif node.s_config.rc_fix_target == "R" and SMODS.SUI.is_column_type(child.n) then
			SMODS.SUI.Node.process_node(node, index, SUI.R({ align = node.s_config.rc_fix_align, child }))
		else
			SMODS.SUI.Node.process_node(node, index, child)
		end
	end
end
function SMODS.SUI.process_node_render(node)
	return node.render and node:render() or node
end
function SMODS.SUI.process_element_created(element)
	if element.input_node then
		SMODS.SUI.attach_hooks(element, element.input_node.s_hooks)
		if element.input_node.s_init then
			element.input_node.s_init(element)
		end
	end
end

-- Topology printing tools

function SMODS.SUI.get_topology(node, options, indent)
	options = options or {}
	indent = indent or ""
	node = SMODS.SUI.process_node_render(node)
	node.config = node.config or {}

	-- Resolve class name & id and format element in tree as `n#id.class1.class2`
	local formatted_class_name = ""
	if node.s_class then
		for word in string.gmatch(node.s_class, "%S+") do
			formatted_class_name = formatted_class_name .. "." .. word
		end
	end
	local formatted_id = ""
	if node.config.id then
		formatted_id = "#" .. node.config.id
	end

	-- Resolve element topology info
	local topology_info
	if not node.topology then
		local uit = SMODS.SUI.get_debug_uit_key(node.n)
		topology_info = (SUI[uit] or SMODS.SUI.Node).topology(node)
	else
		topology_info = node:topology(options)
	end

	local formatted_n = topology_info.n
	local element_line = string.format("%s<%s%s%s", indent, formatted_n, formatted_id, formatted_class_name)

	-- Resolve attributes to display and format them as `attr_1=value_1 attr_2=value_2`
	local additional_attributes = ""
	for k, v in pairs(topology_info.attributes or {}) do
		additional_attributes = additional_attributes .. k .. "=" .. v .. " "
	end
	if additional_attributes ~= "" then
		element_line = element_line .. " " .. additional_attributes
	end

	-- Format children if present
	local with_children = false
	for _, subnode in pairs(topology_info.nodes or {}) do
		if not with_children then
			with_children = true
			element_line = element_line .. ">"
		end
		element_line = element_line .. "\n" .. SMODS.SUI.get_topology(subnode, options, indent .. "    ")
	end

	-- Close element
	if with_children then
		element_line = element_line .. "\n" .. string.format("%s</%s>", indent or "", formatted_n)
	else
		element_line = element_line .. " />"
	end

	return element_line
end
function SMODS.SUI.print_topology(node, options)
	return print("\n" .. SMODS.SUI.get_topology(node, options))
end

-- Base extendable SMODS.SUI node element

SMODS.SUI.Node = Object:extend()
SMODS.SUI.Node.subclasses = {}
function SMODS.SUI.Node:extend(o)
	local cls = Object.extend(self)
	for k, v in pairs(o or {}) do
		cls[k] = v
	end
	self.subclasses[#self.subclasses + 1] = cls
	cls.subclasses = {}
	return cls
end

function SMODS.SUI.Node:init(n, ...)
	assert(n, "Not found node type for SMODS.SUI node")

	self.n = n
	self.config = {}
	self.nodes = {}

	self.s_config = {}
	self.s_hooks = {}
end
function SMODS.SUI.Node:setup() end
function SMODS.SUI.Node:__call(...)
	if self.n then
		self:process_inputs(...)
		return self
	end
	local obj = setmetatable({}, self)
	obj:init(...)
	obj:setup()
	obj:process_inputs(...)
	return obj
end

function SMODS.SUI.Node:process_config(key, value)
	SMODS.SUI.config_merge(self, key, value)
end
function SMODS.SUI.Node:process_node(index, value)
	SMODS.SUI.node_merge(self, index, value)
end
function SMODS.SUI.Node:pre_process_input(input)
	local input_type = SMODS.SUI.input_type(input)
	if input_type == "table" then
		return input
	elseif input_type ~= "nil" then
		return { input }
	end
	return nil
end
function SMODS.SUI.Node:post_process_input(input)
	if input.s_config then
		self.s_config = SMODS.merge_defaults(input.s_config or {}, self.s_config or {}) or {}
	end
	if input.s_hooks then
		self.s_hooks = SMODS.merge_defaults(input.s_hooks or {}, self.s_hooks or {}) or {}
	end
	if input.s_init then
		self.s_init = input.s_init
	end
	if input.s_class then
		self.s_class = input.s_class
	end
end
function SMODS.SUI.Node:process_input(input)
	input = self:pre_process_input(input)
	if not input then
		return
	end

	local children_to_insert = {}
	if input.config then
		for k, v in pairs(input.config) do
			self:process_config(k, v)
		end
	end
	if input.nodes then
		for k, v in pairs(input.nodes) do
			children_to_insert[#children_to_insert + 1] = v
		end
	end
	for k, v in pairs(input) do
		if SMODS.SUI.special_config_keys[k] then
		elseif type(k) == "number" then
			children_to_insert[#children_to_insert + 1] = v
		else
			self:process_config(k, v)
		end
	end

	local child_index = 0
	for _, v in ipairs(children_to_insert) do
		if type(v) == "table" and #v > 0 then
			for _, node in pairs(v) do
				child_index = child_index + 1
				self:process_node(child_index, node)
			end
		else
			child_index = child_index + 1
			self:process_node(child_index, v)
		end
	end

	self:post_process_input(input)
end
function SMODS.SUI.Node:process_inputs(...)
	for _, input in ipairs({ ... }) do
		self:process_input(input)
	end
end

function SMODS.SUI.Node:render()
	-- Propagate CSS stylesheet element uses
	if self.s_config.classes ~= nil then
		for _, child in ipairs(self.nodes) do
			if not child.s_config then
				child.s_config = {}
			end
			if child.s_config.classes == nil then
				child.s_config.classes = self.s_config.classes
			end
		end
	end

	-- Apply CSS classes
	if self.s_class then
		local classes = self.s_config.classes or SMODS.SUI.classes
		local old_config = self.config
		local at_least_one_match = false
		self.config = {}

		for word in string.gmatch(self.s_class, "%S+") do
			if classes[word] then
				at_least_one_match = true
                if type(classes[word]) == "function" then
                    classes[word](self)
                else
                    for k, v in pairs(classes[word]) do
                        self:process_config(k, v)
                    end
                end
			end
		end

		if at_least_one_match then
			for k, v in pairs(old_config) do
				self:process_config(k, v)
			end
		else
			self.config = old_config
		end
	end

	return {
		n = self.n,
		config = self.config,
		nodes = self.nodes,
		T = self.T,

		s_config = self.s_config,
		s_hooks = self.s_hooks,
		s_init = self.s_init,
		s_class = self.s_class,
	}
end
function SMODS.SUI.Node:topology(options)
	self.config = self.config or {}
	return {
		n = SMODS.SUI.get_debug_uit_key(self.n),
		config = self.config or {},
		nodes = self.nodes or {},

		s_config = self.s_config or {},
		s_class = self.s_class,

		attributes = {
			align = self.config.align and string.format('"%s"', self.config.align),
			colour = self.config.colour and string.format("%s", SMODS.SUI.colour_to_hex(self.config.colour)),
			w = self.config.w and string.format("%.2f", self.config.w),
			minw = self.config.minw and string.format("%.2f", self.config.minw),
			maxw = self.config.maxw and string.format("%.2f", self.config.maxw),
			h = self.config.w and string.format("%.2f", self.config.h),
			minh = self.config.minh and string.format("%.2f", self.config.minh),
			maxh = self.config.maxh and string.format("%.2f", self.config.maxh),
		},
	}
end

-- Global SUi table to store all node classes

function SMODS.SUI.extend_uit(n, t)
	t = t or {}
	t.init = t.init or function(self, ...)
		SMODS.SUI.Node.init(self, n, ...)
	end
	return SMODS.SUI.Node:extend(t)
end

SUI = setmetatable({
	padding = G.UIT.padding,
}, {
	__call = function(sui, ...)
		local args = { ... }
		local uit

		local arg = args[1]
		if type(arg) == "table" then
			-- Try to resolve arg.n as n
			uit = arg.n and (G.UIT[arg.n] and arg.n or SMODS.SUI.get_uit_key(arg.n)) or nil
		elseif arg then
			-- Try to resolve arg itself as n
			uit = G.UIT[arg] and arg or SMODS.SUI.get_uit_key(arg)
			if uit then
				table.remove(args, 1)
			end
		end

		if uit then
			return sui[uit](unpack(args))
		end
		error("Not found node type for SMODS.SUI node")
	end,
	__index = function(sui, n)
		if G.UIT[n] then
			sui[n] = SMODS.SUI.extend_uit(G.UIT[n])
			return sui[n]
		end
		error("Not found node type for SMODS.SUI node: " .. tostring(n))
	end,
})

-- Vanilla node elements and their extensions

-- `G.UIT.B` - just a box without any child elements
SUI.B = SMODS.SUI.extend_uit(G.UIT.B, {
	process_node = function(self, index, child) end,
})

-- `G.UIT.ROOT` - starting element of each UIBox
-- Fixes R/C inside, covers text into T, objects into O
SUI.ROOT = SMODS.SUI.extend_uit(G.UIT.ROOT, {
	process_node = SMODS.SUI.extended_process_node,
})

-- `G.UIT.C` - column element
-- Fixes R/C inside, covers text into T, objects into O
SUI.C = SMODS.SUI.extend_uit(G.UIT.C, {
	process_node = SMODS.SUI.extended_process_node,
})

-- `G.UIT.R` - row element
-- Fixes R/C inside, covers text into T, objects into O
SUI.R = SMODS.SUI.extend_uit(G.UIT.R, {
	process_node = SMODS.SUI.extended_process_node,
})

-- `G.UIT.O` - object element
-- Can have only 1 child - object to render; all other removes old and place new
SUI.O = SMODS.SUI.extend_uit(G.UIT.O, {
	process_node = function(self, index, child)
		if self.config.object then
			self.config.object:remove()
		end
		self.config.object = child
	end,
	topology = function(self, options)
		local old_topology = SMODS.SUI.Node.topology(self, options)
		local meta = self.config.object and getmetatable(self.config.object)
		old_topology.attributes.object = "{" .. (meta and SMODS.SUI.get_debug_object_class_name(meta) or "nil") .. "}"
		return old_topology
	end,
	render = function(self)
		local r = SMODS.SUI.Node.render(self)
		if not r.config.object then
			r.config.object = Moveable()
		end
		return r
	end,
})

-- `G.UIT.T` - text element
-- Can have only 1 child - text to render; replaces old text with new one
SUI.T = SMODS.SUI.extend_uit(G.UIT.T, {
	process_node = function(self, index, child)
		self.config.text = child
	end,
	topology = function(self, options)
		local old_topology = SMODS.SUI.Node.topology(self, options)
		old_topology.attributes.text = self.config.text
		if self.config.ref_table and self.config.ref_value then
			old_topology.attributes.text = tostring(self.config.ref_table[self.config.ref_value])
		end
		old_topology.attributes.text = old_topology.attributes.text or "[UI ERROR]"
		old_topology.attributes.scale = self.config.scale and string.format("%.2f", self.config.scale) or "nil"
		return old_topology
	end,
})

-- Useful shortcuts for vanilla elements

-- `SUI.ROOT` with default colour `G.C.CLEAR` instead of `G.C.BLACK`
SUI.CLEAR_ROOT = SUI.ROOT:extend({
	setup = function(self, ...)
		SUI.ROOT.setup(self, ...)
		self:process_input({ colour = G.C.CLEAR })
	end,
})
-- `SUI.C` with default `align = "cm"`
SUI.CENTER_C = SUI.C:extend({
	setup = function(self, ...)
		SUI.C.setup(self, ...)
		self:process_input({ align = "cm" })
	end,
})
-- `SUI.R` with default `align = "cm"`
SUI.CENTER_R = SUI.R:extend({
	setup = function(self, ...)
		SUI.R.setup(self, ...)
		self:process_input({ align = "cm" })
	end,
})
