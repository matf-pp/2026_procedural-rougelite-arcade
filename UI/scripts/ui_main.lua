local ui_main = {}
local moonshine = require("moonshine")

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
local bgEffect
local textEffect

local utils = require("utils")

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

    bgCanvas      = love.graphics.newCanvas()


    local initH = love.graphics.getHeight()
    local initStartY = initH / 2 - (#items * 70) / 2 + menuOffsetY + 30
    bracketY = initStartY
    bracketHalfWidth = fontBold:getWidth(items[selected]) / 2
    for i = 1, #items do
        itemScale[i] = i == selected and 1.08 or 1.0
        itemAlpha[i] = i == selected and 1.0 or 0.5
    end

    bgEffect = moonshine(moonshine.effects.gaussianblur)
    bgEffect.gaussianblur.sigma = 6

    textEffect = moonshine(moonshine.effects.glow)
    textEffect.glow.strength = 5
    textEffect.glow.min_luma = 0.1
end

function ui_main.update(dt)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mx, my = love.mouse.getPosition()
    local nx = (mx / w - 0.5) * 2
    local ny = (my / h - 0.5) * 2
    parallaxX = parallaxX + (nx * parallaxStrength - parallaxX) * dt * 2
    parallaxY = parallaxY + (ny * parallaxStrength - parallaxY) * dt * 2

    local startY = h / 2 - (#items * 70) / 2 + menuOffsetY + 30
    local targetY = startY + (selected - 1) * 70
    local targetHW = fontBold:getWidth(items[selected]) / 2
    bracketY = bracketY + (targetY - bracketY) * dt * 8
    bracketHalfWidth = bracketHalfWidth + (targetHW - bracketHalfWidth) * dt * 8

    for i = 1, #items do
        local targetScale = i == selected and 1.08 or 1.0
        local targetAlpha = i == selected and 1.0 or 0.5
        itemScale[i] = itemScale[i] + (targetScale - itemScale[i]) * dt * 8
        itemAlpha[i] = itemAlpha[i] + (targetAlpha - itemAlpha[i]) * dt * 8
    end
end

local function drawMenuText(w, h)
    local startY = h / 2 - (#items * 70) / 2 + menuOffsetY + 30
    love.graphics.setFont(fontBold)
    local fh = fontBold:getHeight()

    for i, label in ipairs(items) do
        local y = startY + (i - 1) * 70
        local s = itemScale[i]
        love.graphics.setColor(1, 1, 1, itemAlpha[i])
        love.graphics.push()
        love.graphics.translate(w / 2, y + fh / 2)
        love.graphics.scale(s, s)
        love.graphics.print(label, -fontBold:getWidth(label) / 2, -fh / 2)
        love.graphics.pop()
    end

    love.graphics.setColor(1, 1, 1, 1)
    local bracketSep = fontBold:getWidth("> ")
    local bracketPad = fontBold:getWidth(" ")
    love.graphics.print(">", math.floor(w / 2 - bracketHalfWidth - bracketSep), math.floor(bracketY))
    love.graphics.print("<", math.floor(w / 2 + bracketHalfWidth + bracketPad), math.floor(bracketY))
end

function ui_main.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    --love.graphics.setBackgroundColor(0, 0, 0, 0)

    local function drawScaled(img)
        love.graphics.draw(img, 0, 0, 0, w / img:getWidth(), h / img:getHeight())
    end

    local function drawParallax(img, factor)
        local ox = math.floor(parallaxX * factor)
        local oy = math.floor(parallaxY * factor)
        love.graphics.draw(img, ox, oy, 0, w / img:getWidth(), h / img:getHeight())
    end

    love.graphics.setCanvas(bgCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
    drawParallax(imgBackground, 0.3)
    drawParallax(imgMiddle, 0.6)
    drawParallax(imgForeground, 1.0)
    love.graphics.setCanvas()

    --moonshine syntax
    bgEffect(function()
        love.graphics.draw(bgCanvas)
    end)

    utils.drawWithEffect(textEffect, function()
        --love.graphics.setColor(1, 1, 1, 1)
        drawMenuText(w, h)
        love.graphics.setFont(fontTitle)
        local titleW = fontTitle:getWidth("LunaSol")
        love.graphics.print("LunaSol", math.floor(w / 2 - titleW / 2), math.floor(h * 0.1 + menuOffsetY))
    end)

    love.graphics.setFont(fontDefault)
    --love.graphics.setColor(1, 1, 1, 1)
end

local function confirm()
    if selected == 1 then
        onStartCallback()
    elseif selected == 2 then
        -- options placeholder
    elseif selected == 3 then
        love.event.push("quit", 0)
    end
end

local function getItemRect(i, w, h)
    local itemHeight = 70
    local startY = h / 2 - (#items * itemHeight) / 2 + menuOffsetY + 30
    local text = i == selected and ("> " .. items[i] .. " <") or items[i]
    local tw = fontBold:getWidth(text)
    return w / 2 - tw / 2, startY + (i - 1) * itemHeight, tw, fontBold:getHeight()
end

function ui_main.keypressed(key, scancode, isrepeat)
    if key == "w" or key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #items end
    elseif key == "s" or key == "down" then
        selected = selected + 1
        if selected > #items then selected = 1 end
    elseif key == "return" or key == "space" then
        confirm()
    end
end

function ui_main.mousemoved(x, y, dx, dy, istouch)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    for i = 1, #items do
        local ix, iy, iw, ih = getItemRect(i, w, h)
        if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
            selected = i
        end
    end
end

function ui_main.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        for i = 1, #items do
            local ix, iy, iw, ih = getItemRect(i, w, h)
            if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
                selected = i
                confirm()
            end
        end
    end
end

function ui_main.mousereleased(x, y, button, istouch, presses)
end

return ui_main
