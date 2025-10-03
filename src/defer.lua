
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

--- @param atlas table
--- @param path string
--- @param dpi number?
--- @param nfs boolean?
function SMODS.load_defer_atlas(atlas, path, dpi, nfs)
    local file = nfs and assert(NFS.newFileData(path)) or path
    atlas.image = love.graphics.newImage(file, {
        mipmaps = true,
        dpiscale = dpi or G.SETTINGS.GRAPHICS.texture_scaling
    })

    local mipmap_level = SMODS.config.graphics_mipmap_level_options[SMODS.config.graphics_mipmap_level]
    if mipmap_level and mipmap_level ~= 0 then
        atlas.image:setMipmapFilter('linear', mipmap_level)
    end

    return atlas.image
end

--- @param font table
--- @param path string?
--- @param nfs boolean?
function SMODS.load_defer_font(font, path, nfs)
    path = path or font.file
    local file = nfs and assert(NFS.newFileData(path)) or path
    font.FONT = love.graphics.newFont(file, font.render_scale)
    return font.FONT
end

--- @param atlas table
--- @param path string
--- @param dpi number?
--- @param nfs boolean?
function SMODS.defer_atlas(atlas, path, dpi, nfs)
    local rawmt = getmetatable(atlas)
    setmetatable(atlas, {
        __index = function(t, k)
            if k ~= "image" then return rawget(t, k) end
            setmetatable(atlas, rawmt)
            return SMODS.load_defer_atlas(atlas, path, dpi, nfs)
        end
    })
end

--- @param font table
--- @param path string?
--- @param nfs boolean?
function SMODS.defer_font(font, path, nfs)
    setmetatable(font, {
        __index = function(t, k)
            if k ~= "FONT" then return rawget(t, k) end
            setmetatable(t, nil)
            return SMODS.load_defer_font(font, path, nfs)
        end
    })
end
