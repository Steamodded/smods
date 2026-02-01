assert(SMODS.path, "SMODS was not properly setup.\n\n!!!!!!!!!!!!!!\nPlease make sure your lovely is up to date (Minimum lovely v0.9.0)\n!!!!!!!!!!!!!!")
for _, path in ipairs {
    "src/ui.lua",
    "src/index.lua",
    "src/utils.lua",
    "src/overrides.lua",
    "src/game_object.lua",
    "src/compat_0_9_8.lua",
} do
    assert(load(SMODS.NFS.read(SMODS.path..path), ('=[SMODS _ "%s"]'):format(path)))()
end

function boot_print_stage(stage)
    if not SMODS.booted then
        boot_timer(nil, "STEAMODDED - " .. stage, 0.95)
    end
end

local catimg = NFS.getInfo(SMODS.path.."assets/cat.png") and love.graphics.newImage(love.filesystem.newFileData(NFS.read(SMODS.path.."assets/cat.png")))
function boot_timer(_label, _next, progress)
    progress = progress or 0
    G.LOADING = G.LOADING or {
        font = love.graphics.setNewFont("resources/fonts/m6x11plus.ttf", 20),
        love.graphics.dis
    }
    local realw, realh = love.window.getMode()
    love.graphics.setCanvas()
    love.graphics.push()
    love.graphics.setShader()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.6, 0.8, 0.9, 1)
    if progress > 0 then love.graphics.rectangle('fill', realw / 2 - 150, realh / 2 - 15, progress * 300, 30, 5) end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', realw / 2 - 150, realh / 2 - 15, 300, 30, 5)
    if catimg then love.graphics.draw(catimg, realw/2 - 264, realh/2 - 27, 0, 1, 1); love.graphics.rectangle('line', realw/2 - 264, realh/2 - 27, 96, 96, 5) end
    love.graphics.print("LOADING: " .. _next, realw / 2 - 150, realh / 2 + 40)
    love.graphics.pop()
    love.graphics.present()

    G.ARGS.bt = G.ARGS.bt or love.timer.getTime()
    G.ARGS.bt = love.timer.getTime()
end
sendInfoMessage("Steamodded v" .. SMODS.version, "SMODS")

