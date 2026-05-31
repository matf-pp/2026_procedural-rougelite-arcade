local ui_main = {}
local moonshine = require("moonshine")
local soundFX = require("soundFX")
local utils = require("utils")

local selected = 1
local items = { "Enter Game", "Options", "Quit Game" }
local onStartCallback = nil

local menuOffsetY = 100
local parallaxX = 0
local parallaxY = 0
local parallaxStrength = 20

local bracketY = 0
local bracketHalfWidth = 0
local itemScale = {}
local itemAlpha = {}

local fontBold
local fontTitle
local fontDefault
local imgBackground
local imgMiddle
local imgForeground
local bgCanvas
local blurredBgCanvas
local cachedFloorPX
local cachedFloorPY
local bgEffect
local textEffect

local view = "main"
local viewAlpha = 1
local viewOffsetX = 0
local transitionPhase = "none"
local transitionOutDir = -1
local pendingView = nil

local settings = {
    musicVolume    = 20,
    sfxVolume      = 5,
    postProcessing = true,
    showFps        = false,
}

local settingsItems = {
    { label = "Music Volume",    type = "slider", key = "musicVolume",    step = 5 },
    { label = "SFX Volume",      type = "slider", key = "sfxVolume",      step = 5 },
    { label = "Post Processing", type = "toggle", key = "postProcessing"           },
    { label = "FPS Counter",     type = "toggle", key = "showFps"                  },
    { label = "Back",            type = "button"                                    },
}

local selectedSettings = 1
local lastSelectedSettings

local TRANS_SPEED = 10
local SLIDE_DIST  = 250

local function activeItemCount()
    return view == "main" and #items or #settingsItems
end

local function activeSelected()
    return view == "main" and selected or selectedSettings
end

local function itemDisplayLabel(i)
    if view == "main" then return items[i] end
    local it = settingsItems[i]
    if it.type == "slider" then
        return it.label .. "   " .. settings[it.key] .. "%"
    elseif it.type == "toggle" then
        return it.label .. "   " .. (settings[it.key] and "ON" or "OFF")
    end
    return it.label
end

local function initForView()
    local h = love.graphics.getHeight()
    local n = activeItemCount()
    local sel = activeSelected()
    local startY = h / 2 - (n * 70) / 2 + menuOffsetY + 30
    bracketY = startY + (sel - 1) * 70
    bracketHalfWidth = fontBold:getWidth(itemDisplayLabel(sel)) / 2
    for i = 1, n do
        itemScale[i] = i == sel and 1.08 or 1.0
        itemAlpha[i] = i == sel and 1.0  or 0.5
    end
end

local function switchToView(target, outDir)
    if transitionPhase ~= "none" then return end
    pendingView      = target
    transitionOutDir = outDir
    transitionPhase  = "out"
end

function ui_main.load(onStart)
    onStartCallback = onStart
    fontDefault   = love.graphics.getFont()
    fontBold      = love.graphics.newFont("assets/fonts/Cinzel/static/Cinzel-Bold.ttf", 36)
    fontTitle     = love.graphics.newFont("assets/fonts/Cinzel/static/Cinzel-Bold.ttf", 150)
    imgBackground = love.graphics.newImage("assets/mainMenu/background.png")
    imgMiddle     = love.graphics.newImage("assets/mainMenu/middle.png")
    imgForeground = love.graphics.newImage("assets/mainMenu/foreground.png")
    imgBackground:setFilter("nearest", "nearest")
    imgMiddle:setFilter("nearest", "nearest")
    imgForeground:setFilter("nearest", "nearest")

    bgCanvas        = love.graphics.newCanvas()
    blurredBgCanvas = love.graphics.newCanvas()
    cachedFloorPX   = nil
    cachedFloorPY   = nil

    settings.sfxVolume = math.floor(soundFX.getVolume() * 100 + 0.5)

    local initH    = love.graphics.getHeight()
    local initStartY = initH / 2 - (#items * 70) / 2 + menuOffsetY + 30
    bracketY = initStartY
    bracketHalfWidth = fontBold:getWidth(items[selected]) / 2
    for i = 1, #items do
        itemScale[i] = i == selected and 1.08 or 1.0
        itemAlpha[i] = i == selected and 1.0  or 0.5
    end

    bgEffect = moonshine(moonshine.effects.gaussianblur)
    bgEffect.gaussianblur.sigma = 6

    textEffect = moonshine(moonshine.effects.glow)
    textEffect.glow.strength  = 5
    textEffect.glow.min_luma  = 0.1
end

function ui_main.update(dt)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mx, my = love.mouse.getPosition()
    local nx = (mx / w - 0.5) * 2
    local ny = (my / h - 0.5) * 2
    parallaxX = parallaxX + (nx * parallaxStrength - parallaxX) * dt * 2
    parallaxY = parallaxY + (ny * parallaxStrength - parallaxY) * dt * 2

    if transitionPhase == "out" then
        viewAlpha   = viewAlpha   + (0 - viewAlpha)   * dt * TRANS_SPEED
        viewOffsetX = viewOffsetX + (transitionOutDir * SLIDE_DIST - viewOffsetX) * dt * TRANS_SPEED
        if viewAlpha < 0.04 then
            view            = pendingView
            pendingView     = nil
            transitionPhase = "in"
            viewOffsetX     = -transitionOutDir * SLIDE_DIST
            viewAlpha       = 0
            initForView()
        end
    elseif transitionPhase == "in" then
        viewAlpha   = viewAlpha   + (1 - viewAlpha)   * dt * TRANS_SPEED
        viewOffsetX = viewOffsetX + (0 - viewOffsetX) * dt * TRANS_SPEED
        if viewAlpha > 0.96 then
            viewAlpha       = 1
            viewOffsetX     = 0
            transitionPhase = "none"
        end
    end

    local n   = activeItemCount()
    local sel = activeSelected()
    local startY  = h / 2 - (n * 70) / 2 + menuOffsetY + 30
    local targetY  = startY + (sel - 1) * 70
    local targetHW = fontBold:getWidth(itemDisplayLabel(sel)) / 2
    bracketY       = bracketY      + (targetY  - bracketY)      * dt * 8
    bracketHalfWidth = bracketHalfWidth + (targetHW - bracketHalfWidth) * dt * 8

    for i = 1, n do
        local targetScale = i == sel and 1.08 or 1.0
        local targetAlpha = i == sel and 1.0  or 0.5
        itemScale[i] = itemScale[i] + (targetScale - itemScale[i]) * dt * 8
        itemAlpha[i] = itemAlpha[i] + (targetAlpha - itemAlpha[i]) * dt * 8
    end
end

local function drawCurrentItems(w, h)
    local n      = activeItemCount()
    local startY = h / 2 - (n * 70) / 2 + menuOffsetY + 30
    love.graphics.setFont(fontBold)
    local fh = fontBold:getHeight()

    love.graphics.push()
    love.graphics.translate(math.floor(viewOffsetX), 0)

    for i = 1, n do
        local label = itemDisplayLabel(i)
        local y = startY + (i - 1) * 70
        local s = itemScale[i]
        love.graphics.setColor(1, 1, 1, itemAlpha[i] * viewAlpha)
        love.graphics.push()
        love.graphics.translate(w / 2, y + fh / 2)
        love.graphics.scale(s, s)
        love.graphics.print(label, -fontBold:getWidth(label) / 2, -fh / 2)
        love.graphics.pop()

        if view == "settings" and settingsItems[i].type == "slider" then
            local barW = 200
            local barH = 4
            local bx   = w / 2 - barW / 2
            local by   = y + fh + 4
            local pct  = settings[settingsItems[i].key] / 100
            love.graphics.setColor(1, 1, 1, 0.18 * viewAlpha)
            love.graphics.rectangle("fill", bx, by, barW, barH)
            love.graphics.setColor(1, 1, 1, itemAlpha[i] * viewAlpha)
            love.graphics.rectangle("fill", bx, by, barW * pct, barH)
        end
    end

    love.graphics.setColor(1, 1, 1, viewAlpha)
    local bracketSep = fontBold:getWidth("> ")
    local bracketPad = fontBold:getWidth(" ")
    love.graphics.print(">", math.floor(w / 2 - bracketHalfWidth - bracketSep), math.floor(bracketY))
    love.graphics.print("<", math.floor(w / 2 + bracketHalfWidth + bracketPad), math.floor(bracketY))

    love.graphics.pop()
end

function ui_main.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    local function drawParallax(img, factor)
        local ox = math.floor(parallaxX * factor)
        local oy = math.floor(parallaxY * factor)
        love.graphics.draw(img, ox, oy, 0, w / img:getWidth(), h / img:getHeight())
    end

    local fpx = math.floor(parallaxX)
    local fpy = math.floor(parallaxY)
    if fpx ~= cachedFloorPX or fpy ~= cachedFloorPY then
        love.graphics.setCanvas(bgCanvas)
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
        drawParallax(imgBackground, 0.3)
        drawParallax(imgMiddle, 0.6)
        drawParallax(imgForeground, 1.0)
        love.graphics.setCanvas()

        love.graphics.setCanvas(blurredBgCanvas)
        love.graphics.clear(0, 0, 0, 1)
        bgEffect(function()
            love.graphics.draw(bgCanvas)
        end)
        love.graphics.setCanvas()

        cachedFloorPX = fpx
        cachedFloorPY = fpy
    end

    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(blurredBgCanvas)

    utils.drawWithEffect(textEffect, function()
        drawCurrentItems(w, h)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(fontTitle)
        local titleW = fontTitle:getWidth("LunaSol")
        love.graphics.print("LunaSol", math.floor(w / 2 - titleW / 2), math.floor(h * 0.1 + menuOffsetY))
    end)

    love.graphics.setFont(fontDefault)
end

local function confirm()
    soundFX.select()
    if selected == 1 then
        onStartCallback()
    elseif selected == 2 then
        switchToView("settings", -1)
    elseif selected == 3 then
        love.event.push("quit", 0)
    end
end

local lastSelected

local function changeSelected(s)
    if s ~= lastSelected then soundFX.hover() end
    selected     = s
    lastSelected = s
end

local function changeSelectedSettings(s)
    if s ~= lastSelectedSettings then soundFX.hover() end
    selectedSettings     = s
    lastSelectedSettings = s
end

local function adjustSetting(dir)
    local it = settingsItems[selectedSettings]
    if it.type == "slider" then
        settings[it.key] = math.max(0, math.min(100, settings[it.key] + dir * it.step))
        if it.key == "sfxVolume" then soundFX.setVolume(settings.sfxVolume / 100) end
        soundFX.hover()
    elseif it.type == "toggle" then
        settings[it.key] = not settings[it.key]
        soundFX.hover()
    end
end

local function confirmSettings()
    local it = settingsItems[selectedSettings]
    soundFX.select()
    if it.type == "button" then
        switchToView("main", 1)
    elseif it.type == "toggle" then
        settings[it.key] = not settings[it.key]
    end
end

local function getItemRect(i, w, h)
    local n       = activeItemCount()
    local startY  = h / 2 - (n * 70) / 2 + menuOffsetY + 30
    local label   = itemDisplayLabel(i)
    local sel     = activeSelected()
    local text    = i == sel and ("> " .. label .. " <") or label
    local tw      = fontBold:getWidth(text)
    return w / 2 - tw / 2 + viewOffsetX, startY + (i - 1) * 70, tw, fontBold:getHeight()
end


function ui_main.keypressed(key, scancode, isrepeat)
    if transitionPhase ~= "none" then return end
    if view == "main" then
        if key == "w" or key == "up" then
            changeSelected(selected - 1)
            if selected < 1 then selected = #items end
        elseif key == "s" or key == "down" then
            changeSelected(selected + 1)
            if selected > #items then selected = 1 end
        elseif key == "return" or key == "space" then
            confirm()
        end
    else
        if key == "w" or key == "up" then
            changeSelectedSettings(selectedSettings - 1)
            if selectedSettings < 1 then selectedSettings = #settingsItems end
        elseif key == "s" or key == "down" then
            changeSelectedSettings(selectedSettings + 1)
            if selectedSettings > #settingsItems then selectedSettings = 1 end
        elseif key == "left" or key == "a" then
            adjustSetting(-1)
        elseif key == "right" or key == "d" then
            adjustSetting(1)
        elseif key == "return" or key == "space" then
            confirmSettings()
        elseif key == "escape" then
            switchToView("main", 1)
        end
    end
end

function ui_main.mousemoved(x, y, dx, dy, istouch)
    if transitionPhase ~= "none" then return end
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local n = activeItemCount()
    for i = 1, n do
        local ix, iy, iw, ih = getItemRect(i, w, h)
        if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
            if view == "main" then
                changeSelected(i)
            else
                changeSelectedSettings(i)
            end
        end
    end
end

function ui_main.mousepressed(x, y, button, istouch, presses)
    if transitionPhase ~= "none" then return end
    if button ~= 1 then return end
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local n = activeItemCount()

    if view == "settings" then
        for i = 1, n do
            local ix, iy, iw, ih = getItemRect(i, w, h)
            if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
                changeSelectedSettings(i)
                confirmSettings()
                return
            end
        end
    else
        for i = 1, n do
            local ix, iy, iw, ih = getItemRect(i, w, h)
            if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
                selected = i
                confirm()
                return
            end
        end
    end
end

function ui_main.mousereleased(x, y, button, istouch, presses)
end

function ui_main.getMusicVolume()    return settings.musicVolume / 100 end
function ui_main.getSfxVolume()      return settings.sfxVolume   / 100 end
function ui_main.getPostProcessing() return settings.postProcessing    end
function ui_main.getShowFps()        return settings.showFps           end

return ui_main
