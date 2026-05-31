local moonshine = require("moonshine")
local utils     = require("utils")

local UiVictory = {}

local CARD_W      = 240
local CARD_H      = 340
local CARD_GAP    = 40
local CARD_DELAYS = { 0.1, 0.35, 0.6 }
local HOVER_SCALE = 1.07
local MAX_OFFSET  = 10

local relics
local onSelect
local selected
local bgCanvas
local blurEffect
local overlayAlpha
local cardScales
local cardTimers
local cardOffX
local cardOffY
local mouseX, mouseY = 0, 0

local fontTitle
local fontDesc

local function cardX(i)
    local totalW = 3 * CARD_W + 2 * CARD_GAP
    return love.graphics.getWidth() / 2 - totalW / 2 + (i - 1) * (CARD_W + CARD_GAP)
end

local function cardY()
    return love.graphics.getHeight() / 2 - CARD_H / 2
end

function UiVictory.load(relicOptions, capturedBg, callback)
    relics       = relicOptions
    bgCanvas     = capturedBg
    onSelect     = callback
    selected     = 1
    overlayAlpha = 0
    cardScales   = { 0, 0, 0 }
    cardTimers   = { 0, 0, 0 }
    cardOffX     = { 0, 0, 0 }
    cardOffY     = { 0, 0, 0 }

    blurEffect = moonshine(moonshine.effects.gaussianblur)
    blurEffect.gaussianblur.sigma = 5

    fontTitle = love.graphics.newFont("assets/fonts/Cinzel/static/Cinzel-Bold.ttf", 18)
    fontDesc  = love.graphics.newFont("assets/fonts/creato_display/CreatoDisplay-Medium.otf", 14)
end

function UiVictory.update(dt)
    overlayAlpha = math.min(1, overlayAlpha + dt * 2)

    for i = 1, 3 do
        cardTimers[i] = cardTimers[i] + dt
        if cardTimers[i] > CARD_DELAYS[i] then
            cardScales[i] = cardScales[i] + (1 - cardScales[i]) * dt * 10
        end

        local cx      = cardX(i)
        local cy      = cardY()
        local hovered = mouseX >= cx and mouseX <= cx + CARD_W
                     and mouseY >= cy and mouseY <= cy + CARD_H

        local targetOffX = hovered and (mouseX - (cx + CARD_W / 2)) / (CARD_W / 2) * MAX_OFFSET or 0
        local targetOffY = hovered and (mouseY - (cy + CARD_H / 2)) / (CARD_H / 2) * MAX_OFFSET or 0

        cardOffX[i] = cardOffX[i] + (targetOffX - cardOffX[i]) * dt * 12
        cardOffY[i] = cardOffY[i] + (targetOffY - cardOffY[i]) * dt * 12
    end
end

function UiVictory.draw()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    blurEffect(function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(bgCanvas)
    end)

    love.graphics.setColor(0, 0, 0, 0.55 * overlayAlpha)
    love.graphics.rectangle("fill", 0, 0, w, h)

    for i, relic in ipairs(relics) do
        local cx  = cardX(i) + cardOffX[i]
        local cy  = cardY()  + cardOffY[i]
        local sel = i == selected
        local s   = cardScales[i] * (sel and HOVER_SCALE or 1.0)

        love.graphics.push()
        love.graphics.translate(cx + CARD_W / 2, cy + CARD_H / 2)
        love.graphics.scale(s, s)
        love.graphics.translate(-CARD_W / 2, -CARD_H / 2)

        if sel then
            love.graphics.setColor(0.15, 0.12, 0.2, 0.92)
        else
            love.graphics.setColor(0.05, 0.05, 0.08, 0.85)
        end
        love.graphics.rectangle("fill", 0, 0, CARD_W, CARD_H, 10, 10)

        love.graphics.setLineWidth(sel and 2 or 1)
        love.graphics.setColor(sel and 1 or 0.4, sel and 1 or 0.4, sel and 1 or 0.4, sel and 1 or 0.35)
        love.graphics.rectangle("line", 0, 0, CARD_W, CARD_H, 10, 10)

        if relic.image then
            relic.image:setFilter("nearest", "nearest")
            local iw = relic.image:getWidth()
            local ih = relic.image:getHeight()
            local imgAreaW = CARD_W - 40
            local imgAreaH = 140
            local s2 = relic.passive_relic and 1
                     or math.min(imgAreaW / iw, imgAreaH / ih)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(relic.image, CARD_W / 2 - iw * s2 / 2, 30 + imgAreaH / 2 - ih * s2 / 2, 0, s2, s2)
        end

        love.graphics.setFont(fontTitle)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(relic.title or relic.name or "?", 10, 190, CARD_W - 20, "center")

        love.graphics.setFont(fontDesc)
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.printf(relic.description or "", 14, 230, CARD_W - 28, "center")

        love.graphics.pop()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function UiVictory.keypressed(key)
    if key == "left" or key == "a" then
        selected = selected - 1
        if selected < 1 then selected = #relics end
    elseif key == "right" or key == "d" then
        selected = selected + 1
        if selected > #relics then selected = 1 end
    elseif key == "return" or key == "space" then
        onSelect(relics[selected])
    end
end

function UiVictory.mousemoved(x, y)
    mouseX, mouseY = x, y
    local cy = cardY()
    for i = 1, #relics do
        local cx = cardX(i)
        if x >= cx and x <= cx + CARD_W and y >= cy and y <= cy + CARD_H then
            selected = i
        end
    end
end

function UiVictory.mousepressed(x, y, button)
    if button ~= 1 then return end
    UiVictory.mousemoved(x, y)
    onSelect(relics[selected])
end

return UiVictory
