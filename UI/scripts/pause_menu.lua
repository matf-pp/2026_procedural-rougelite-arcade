local pause_menu = {}
local moonshine = require("moonshine")
local utils = require("utils")

local selected = 1
local items = { "Continue", "Main Menu" }
local onContinueCallback
local onMainMenuCallback

local bracketY = 0
local bracketHalfWidth = 0
local itemScale = {}
local itemAlpha = {}

local fontBold
local blurEffect
local glowEffect

function pause_menu.load(onContinue, onMainMenu)
    onContinueCallback = onContinue
    onMainMenuCallback = onMainMenu
    fontBold = love.graphics.newFont("assets/fonts/Cinzel/static/Cinzel-Bold.ttf", 36)

    blurEffect = moonshine(moonshine.effects.gaussianblur)
    blurEffect.gaussianblur.sigma = 6

    glowEffect = moonshine(moonshine.effects.glow)
    glowEffect.glow.strength = 5
    glowEffect.glow.min_luma = 0.1

    local h = love.graphics.getHeight()
    local startY = h / 2 - (#items * 70) / 2
    bracketY = startY
    bracketHalfWidth = fontBold:getWidth(items[1]) / 2
    for i = 1, #items do
        itemScale[i] = i == 1 and 1.08 or 1.0
        itemAlpha[i] = i == 1 and 1.0 or 0.5
    end
end

function pause_menu.update(dt)
    local h = love.graphics.getHeight()
    local startY = h / 2 - (#items * 70) / 2
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

local function getItemRect(i, w, h)
    local startY = h / 2 - (#items * 70) / 2
    local tw = fontBold:getWidth(items[i])
    return w / 2 - tw / 2, startY + (i - 1) * 70, tw, fontBold:getHeight()
end

local function confirm()
    local choice = selected
    selected = 1
    if choice == 1 then
        onContinueCallback()
    elseif choice == 2 then
        onMainMenuCallback()
    end
end

local function drawMenuItems(w, h)
    local startY = h / 2 - (#items * 70) / 2
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

function pause_menu.draw(bgCanvas)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    love.graphics.setBackgroundColor(0, 0, 0, 0)
    blurEffect(function() love.graphics.draw(bgCanvas) end)

    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    utils.drawWithEffect(glowEffect, function() drawMenuItems(w, h) end)
    love.graphics.setFont(utils.fonts.default)
end

function pause_menu.keypressed(key, scancode, isrepeat)
    if key == "w" or key == "up" then
        selected = selected - 1
        if selected < 1 then selected = #items end
    elseif key == "s" or key == "down" then
        selected = selected + 1
        if selected > #items then selected = 1 end
    elseif key == "return" or key == "space" or key == "escape" then
        if key == "escape" then selected = 1 end
        confirm()
    end
end

function pause_menu.mousemoved(x, y, dx, dy, istouch)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    for i = 1, #items do
        local ix, iy, iw, ih = getItemRect(i, w, h)
        if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then
            selected = i
        end
    end
end

function pause_menu.mousepressed(x, y, button, istouch, presses)
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

return pause_menu
