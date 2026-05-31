local moonshine = require("moonshine")

local PostProcessing = {}

local chain
local enabled = true
local sceneCanvas
local scanPhase = 0

function PostProcessing.load()
    sceneCanvas = love.graphics.newCanvas()

    chain = moonshine(moonshine.effects.glow)
        .chain(moonshine.effects.chromasep)
        .chain(moonshine.effects.scanlines)
        .chain(moonshine.effects.crt)
        .chain(moonshine.effects.vignette)

    chain.glow.strength        = 2.5
    chain.glow.min_luma        = 0.5
    chain.chromasep.radius     = 1
    chain.scanlines.opacity    = 0.3
    chain.scanlines.width      = 2
    chain.crt.distortionFactor = {1.01, 1.01}
    chain.vignette.radius      = 0.9
    chain.vignette.softness    = 0.45
    chain.vignette.opacity     = 0.45
end

function PostProcessing.setEnabled(v)
    enabled = v
end


function PostProcessing.update(dt)
    scanPhase = scanPhase + dt * 2
    chain.scanlines.phase = scanPhase
end

function PostProcessing.draw(sceneFn)
    if not enabled then
        sceneFn()
        return
    end

    local prev = love.graphics.getCanvas()
    love.graphics.setCanvas(sceneCanvas)
    love.graphics.clear(0, 0, 0, 1)
    sceneFn()
    love.graphics.setCanvas(prev)

    -- reset to opaque white so moonshine's final composite isn't tinted/faded
    -- by whatever color the scene left active (e.g. the menu's viewAlpha)
    love.graphics.setColor(1, 1, 1, 1)
    chain(function()
        love.graphics.draw(sceneCanvas)
    end)
end

return PostProcessing
