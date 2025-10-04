
local set_render_settings = Game.set_render_settings
function Game:set_render_settings()
	set_render_settings(self)

	for i, v in pairs(self.animation_atli) do
        SMODS.defer_atlas(self.ANIMATION_ATLAS[v.name], v.path)
    end

    for i, v in pairs(self.asset_atli) do
        local atlas = self.ASSET_ATLAS[v.name]
        SMODS.defer_atlas(atlas, v.path)
    end

    for i, v in pairs(self.asset_images) do
        SMODS.defer_atlas(self.ASSET_ATLAS[v.name], v.path)
    end
end

local start_up = Game.start_up
function Game:start_up()
    love.window.setVSync(0)

    local set_mode = G.FUNCS.apply_window_changes
    function G.FUNCS.apply_window_changes()
        local vsync = G.SETTINGS.WINDOW.vsync
        G.SETTINGS.WINDOW.vsync = 0
        set_mode()
        G.SETTINGS.WINDOW.vsync = vsync
    end

    start_up(self)

    G.FUNCS.apply_window_changes = set_mode

    love.window.setVSync(G.SETTINGS.WINDOW.vsync or 1)
end

--- @param atlas table
--- @param path string
--- @param opts? { nfs?: boolean, dpi?: number, nomipmap?: boolean }
function SMODS.load_defer_atlas(atlas, path, opts)
    opts = opts or {}
    local file = opts.nfs and assert(NFS.newFileData(path)) or path
    atlas.image = love.graphics.newImage(file, {
        mipmaps = true,
        dpiscale = opts.dpi or G.SETTINGS.GRAPHICS.texture_scaling
    })

    local mipmap_level = SMODS.config.graphics_mipmap_level_options[SMODS.config.graphics_mipmap_level]
    if not opts.nomipmap and mipmap_level and mipmap_level ~= 0 then
        atlas.image:setMipmapFilter('linear', mipmap_level)
    end

    return atlas.image
end

--- @param font table
--- @param opts? { nfs?: boolean, path?: string }
function SMODS.load_defer_font(font, opts)
    opts = opts or {}
    local path = opts.path or font.file
    local file = opts.nfs and assert(NFS.newFileData(path)) or path
    font.FONT = love.graphics.newFont(file, font.render_scale)
    return font.FONT
end

--- @param atlas table
--- @param path string
--- @param opts? { nfs?: boolean, dpi?: number, nomipmap?: boolean }
function SMODS.defer_atlas(atlas, path, opts)
    local rawmt = getmetatable(atlas)
    setmetatable(atlas, {
        __index = function(t, k)
            if k ~= "image" then return rawget(t, k) end
            setmetatable(atlas, rawmt)
            return SMODS.load_defer_atlas(atlas, path, opts)
        end
    })
end

--- @param font table
--- @param opts? { nfs?: boolean, path?: string }
function SMODS.defer_font(font, opts)
    setmetatable(font, {
        __index = function(t, k)
            if k ~= "FONT" then return rawget(t, k) end
            setmetatable(t, nil)
            return SMODS.load_defer_font(font, opts)
        end
    })
end
