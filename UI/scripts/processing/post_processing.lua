local moonshine = require("moonshine")

local PostProcessing = {}

local chain
local enabled = true
local sceneCanvas
local scanPhase = 0

function PostProcessing.load()
    sceneCanvas = love.graphics.newCanvas()

    chain = moonshine(moonshine.effects.chromasep)
        .chain(moonshine.effects.scanlines)
        .chain(moonshine.effects.crt)
        .chain(moonshine.effects.vignette)

    chain.chromasep.radius     = 2
    chain.scanlines.opacity    = 0.3
    chain.scanlines.width      = 2
    chain.crt.distortionFactor = {1.04, 1.04}
    chain.vignette.radius      = 0.9
    chain.vignette.softness    = 0.45
    chain.vignette.opacity     = 0.45
end

function PostProcessing.setEnabled(v)
    enabled = v
end

function PostProcessing.enable()
    enabled = true
end

function PostProcessing.disable()
    enabled = false
end

function PostProcessing.toggle()
    enabled = not enabled
end

function PostProcessing.isEnabled()
    return enabled
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

    chain(function()
        love.graphics.draw(sceneCanvas)
    end)
end

return PostProcessing
