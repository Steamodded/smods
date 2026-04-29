SMODS.SUI = {}

SMODS.SUI.CSS = {}

SMODS.SUI.special_config_keys = {
	n = true, -- element type
	config = true, -- element config
	nodes = true, -- element children

	s_config = true, -- internal sui config
	s_hooks = true, -- list of hooks to apply on element creation
	s_init = true, -- init function
}

-- Utilities

function SMODS.SUI.to_hex(v)
	return string.format("%02X", math.floor(v * 255 + 0.5))
end
function SMODS.SUI.colour_to_hex(colour)
	colour = colour or { 0, 0, 0, 0 }

	local hex = "#" .. SMODS.SUI.to_hex(colour[1]) .. SMODS.SUI.to_hex(colour[2]) .. SMODS.SUI.to_hex(colour[3])

	if colour[4] < 1 then
		hex = hex .. SMODS.SUI.to_hex(colour[4])
	end

	return hex
end
function SMODS.SUI.input_type(i)
	local itype = type(i)
	if itype == "table" then
		if Object.is(i, Moveable) then
			return "moveable"
		end
		if i.n then
			return "node"
		end
	end
	return itype or "nil"
end
function SMODS.SUI.attach_hooks(target, hooks)
	if not target or not hooks then
		return
	end
	for _, func_key in pairs(hooks) do
		local new_func = hooks[func_key]
		local old_func = target[func_key] or function() end
		target[func_key] = function(self, ...)
			return new_func(self, old_func, ...)
		end
	end
	return target
end

-- Storages for keys which needs to be resolved by iterating dictionaries

SMODS.SUI.UIT_STORAGE = {
	buffer = {},
	fallback_to_unknown = false,
	get_tables = function()
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
	get_tables = function()
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
	get_tables = function()
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
		for _k, _v in pairs(storage.get_tables()) do
			for k, v in pairs(_v) do
				if v == input then
					local result_key = _k .. k
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
function SMODS.SUI.node_merge(node, index, value)
	node.nodes[table.maxn(node.nodes) + 1] = value
end
function SMODS.SUI.extended_process_node(node, index, v)
	local input_type = SMODS.SUI.input_type(v)
	if input_type == "moveable" then
		v = SUI.O({ v })
		input_type = "node"
	elseif input_type == "string" or input_type == "number" then
		v = SUI.T({ colour = G.C.UI.TEXT_LIGHT, scale = 0.32, v })
		input_type = "node"
	end
	if input_type == "node" then
		if node.s_config.rc_fix_target == nil then
			if v.n == G.UIT.C or v.n == G.UIT.O then
				node.s_config.rc_fix_target = "C"
			elseif v.n == G.UIT.R then
				node.s_config.rc_fix_target = "R"
			end
			SMODS.SUI.Node.process_node(node, index, v)
		elseif node.s_config.rc_fix_target == "C" and v.n == G.UIT.R then
			SMODS.SUI.Node.process_node(node, index, SUI.C({ v }))
		elseif node.s_config.rc_fix_target == "R'" and (v.n == G.UIT.C or v.n == G.UIT.O) then
			SMODS.SUI.Node.process_node(node, index, SUI.R({ v }))
		else
			SMODS.SUI.Node.process_node(node, index, v)
		end
	end
end
function SMODS.SUI.process_node_render(node)
	return node.render and node:render() or node
end
function SMODS.SUI.process_element_created(element)
	SMODS.SUI.attach_hooks(element, element.input_node.s_hooks)
	if element.input_node.s_init then
		element.input_node.s_init(element)
	end
end

-- Topology printing tools

function SMODS.SUI.get_topology(node, options, indent)
	options = options or {}
	indent = indent or ""
	if node.render then
		node = node:render()
	end
	local formatted_class_name = ""
	node.config = node.config or {}
	if node.s_config and node.s_config.class then
		for word in string.gmatch(node.s_config.class, "%S+") do
			formatted_class_name = formatted_class_name .. "." .. word
		end
	end
	local formatted_id = ""
	if node.config.id then
		formatted_id = "#" .. node.config.id
	end
	local topology_info
	if not node.topology then
		local uit = SMODS.SUI.get_debug_uit_key(node.n)
		topology_info = (SUI[uit] or SMODS.SUI.Node).topology(node)
	else
		topology_info = node:topology()
	end
	local formatted_n = topology_info.n
	local element_line = string.format("%s<%s%s%s", indent, formatted_n, formatted_id, formatted_class_name)
	local additional_attributes = ""
	for _, v in pairs(topology_info.attributes or {}) do
		additional_attributes = additional_attributes .. v .. " "
	end
	if additional_attributes ~= "" then
		element_line = element_line .. " " .. additional_attributes
	end
	local with_children = false
	for _, subnode in pairs(topology_info.nodes or {}) do
		if not with_children then
			with_children = true
			element_line = element_line .. ">"
		end
		element_line = element_line .. "\n" .. SMODS.SUI.get_topology(subnode, options, indent .. "    ")
	end
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
end
function SMODS.SUI.Node:process_node(index, value)
	SMODS.SUI.node_merge(self, index, value)
end
function SMODS.SUI.Node:process_input(input)
	local input_type = SMODS.SUI.input_type(input)
	if input_type ~= "table" and input_type ~= "nil" then
		input = { input }
		input_type = "table"
	end
	if input_type == "table" then
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

		self:post_process_config(input)

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
	end
end
function SMODS.SUI.Node:process_inputs(...)
	for _, input in ipairs({ ... }) do
		self:process_input(input)
	end
end

function SMODS.SUI.Node:render()
	if self.s_config.css ~= nil then
		for _, child in ipairs(self.nodes) do
			if not child.s_config then
				child.s_config = {}
			end
			if child.s_config.css == nil then
				child.s_config.css = self.s_config.css
			end
		end
	end
	if self.s_config.class then
		local classes = self.s_config.css or SMODS.SUI.CSS or {}
		local classname = self.s_config.class
		local old_config = self.config
		self.config = {}
		for word in string.gmatch(classname, "%S+") do
			if classes[word] then
				for k, v in pairs(classes[word]) do
					self:process_config(k, v)
				end
			end
		end
		for k, v in pairs(old_config) do
			self:process_config(k, v)
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
	}
end
function SMODS.SUI.Node:topology()
	self.config = self.config or {}
	return {
		n = SMODS.SUI.get_debug_uit_key(self.n),
		config = self.config or {},
		nodes = self.nodes or {},

		s_config = self.s_config or {},

		attributes = {
			align = self.config.align and string.format('align="%s"', self.config.align),
			colour = self.config.colour and string.format("colour=%s", SMODS.SUI.colour_to_hex(self.config.colour)),
			w = self.config.w and string.format("w=%.2f", self.config.w),
			minw = self.config.minw and string.format("minw=%.2f", self.config.minw),
			maxw = self.config.maxw and string.format("maxw=%.2f", self.config.maxw),
			h = self.config.w and string.format("h=%.2f", self.config.h),
			minh = self.config.minh and string.format("minh=%.2f", self.config.minh),
			maxh = self.config.maxh and string.format("maxh=%.2f", self.config.maxh),
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
	__call = function(t, ...)
		local args = { ... }
		local uit

		local arg = args[1]
		if type(arg) == "table" then
			uit = arg.n and (G.UIT[arg.n] and arg.n or SMODS.SUI.get_uit_key(arg.n)) or nil
			if uit then
				arg.n = nil
			end
		elseif arg then
			uit = G.UIT[arg] and arg or SMODS.SUI.get_uit_key(arg)
			if uit then
				table.remove(args, 1)
			end
		end

		if uit then
			return t[uit](unpack(args))
		end
		error("Not found node type for SMODS.SUI node")
	end,
	__index = function(t, k)
		if G.UIT[k] then
			t[k] = SMODS.SUI.extend_uit(G.UIT[k])
			return t[k]
		end
		error("Not found node type for SMODS.SUI node: " .. tostring(k))
	end,
})

-- Vanilla node elements and their extensions

-- G.UIT.B - just a box without any child elements
SUI.B = SMODS.SUI.extend_uit(G.UIT.B, {
	process_node = function(self, node, index, v) end,
})

-- G.UIT.ROOT - starting element of each UIBox
-- Fixes R/C inside, covers text into T, objects into O
SUI.ROOT = SMODS.SUI.extend_uit(G.UIT.ROOT, {
	process_node = SMODS.SUI.extended_process_node,
})

-- G.UIT.C - column element
-- Fixes R/C inside, covers text into T, objects into O
SUI.C = SMODS.SUI.extend_uit(G.UIT.C, {
	process_node = SMODS.SUI.extended_process_node,
})

-- G.UIT.R - row element
-- Fixes R/C inside, covers text into T, objects into O
SUI.R = SMODS.SUI.extend_uit(G.UIT.R, {
	process_node = SMODS.SUI.extended_process_node,
})

-- G.UIT.O - object element
-- can have only 1 child - object to render; all other removes old and place new
SUI.O = SMODS.SUI.extend_uit(G.UIT.O, {
	process_node = function(self, index, v)
		if self.config.object then
			self.config.object:remove()
		end
		self.config.object = v
	end,
	topology = function(self)
		local old_topology = SMODS.SUI.Node.topology(self)
		local meta = self.config.object and getmetatable(self.config.object)
		old_topology.attributes.object = "object={"
			.. (meta and SMODS.SUI.get_debug_object_class_name(meta) or "nil")
			.. "}"
		return old_topology
	end,
	render = function(self)
		local r = SMODS.SUI.Node.render(self)
		if type(r.config.object_func) == "function" and not r.config.object then
			r.config.object = r.config.object_func(self)
		end
		if not r.config.object then
			r.config.object = Moveable()
		end
		return r
	end,
})

-- Useful shortcuts for vanilla elements

-- SUI.ROOT with default colour G.C.CLEAR instead of G.C.BLACK
SUI.CLEAR_ROOT = SUI.ROOT:extend({
	setup = function(self, ...)
		SUI.ROOT.setup(self, ...)
		self:process_inputs({ colour = G.C.CLEAR })
	end,
})
-- SUI.ROOT with default align = "cm"
SUI.CENTER_ROOT = SUI.ROOT:extend({
	setup = function(self, ...)
		SUI.ROOT.setup(self, ...)
		self:process_inputs({ align = "cm" })
	end,
})
-- SUI.ROOT with default colour G.C.CLEAR instead of G.C.BLACK, and with default align = "cm"
SUI.CLEAR_CENTER_ROOT = SUI.ROOT:extend({
	setup = function(self, ...)
		SUI.ROOT.setup(self, ...)
		self:process_inputs({ colour = G.C.CLEAR, align = "cm" })
	end,
})
-- SUI.C with default align = "cm"
SUI.CENTER_C = SUI.C:extend({
	setup = function(self, ...)
		SUI.C.setup(self, ...)
		self:process_inputs({ align = "cm" })
	end,
})
-- SUI.R with default align = "cm"
SUI.CENTER_R = SUI.R:extend({
	setup = function(self, ...)
		SUI.R.setup(self, ...)
		self:process_inputs({ align = "cm" })
	end,
})

-- Custom elements

-- SUI.LOC_TEXT: easy way to render text via SMODS.localize_box
SUI.LOC_TEXT = SUI.C:extend({
	process_config = function(self, k, v)
		if k == "loc_box_config" or k == "row_config" then
			self.s_config[k] = SMODS.merge_defaults(v or {}, self.s_config[k] or {})
		else
			SUI.C.process_config(self, k, v)
		end
	end,
	process_node = function(self, k, v)
		local input_type = SMODS.SUI.input_type(v)
		if input_type == "node" or input_type == "moveable" then
			SUI.C.process_node(self, k, v)
		else
			local line = input_type == "string" and loc_parse_string(v) or v
			local box_config = SMODS.merge_defaults(self.s_config.loc_box_config or {}, {
				vars = {},
				default_col = G.C.UI.TEXT_LIGHT,
			})
			SUI.C.process_node(
				self,
				k,
				SUI.R({ config = self.s_config.row_config, nodes = SMODS.localize_box(line, box_config) })
			)
		end
	end,
})
