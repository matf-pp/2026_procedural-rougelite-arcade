local moonshine = require("moonshine")
local utils = require("utils")

local starshine = {}
starshine.active = false

local text = ""
local onDismiss = nil
local boxY, targetY, offscreenY = 0, 0, 0
local blurSigma = 0
local dismissing = false
local blurEffect = nil
local original_update, original_draw, original_keypressed = nil, nil, nil

local PAD = 40
local BOX_H = 180

local function restore()
    love.update = original_update
    love.draw = original_draw
    love.keypressed = original_keypressed
    starshine.active = false
    dismissing = false
end

local function drawBox()
    local w, h = love.graphics.getDimensions()
    local boxW = w * 0.6
    local boxX = w / 2 - boxW / 2

    love.graphics.setColor(0.1, 0.1, 0.1, 0.92)
    love.graphics.rectangle("fill", boxX, boxY, boxW, BOX_H, 12, 12)
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("line", boxX, boxY, boxW, BOX_H, 12, 12)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(utils.fonts.default)
    love.graphics.printf(text, boxX + PAD, boxY + PAD, boxW - PAD * 2)

    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print("[ Enter ]", boxX + boxW - utils.fonts.default:getWidth("[ Enter ]") - PAD, boxY + BOX_H - PAD)
    love.graphics.setColor(1, 1, 1, 1)
end

local function starshine_update(dt)
    boxY = boxY + (targetY - boxY) * dt * 10
    if not dismissing then
        blurSigma = blurSigma + (4 - blurSigma) * dt * 10
        blurEffect.gaussianblur.sigma = blurSigma
    end
    if dismissing and offscreenY - boxY < 2 then
        restore()
        if onDismiss then onDismiss() end
    end
end

local function starshine_draw()
    if not dismissing then
        utils.drawWithEffect(blurEffect, function() original_draw() end)
    else
        original_draw()
    end
    drawBox()
end

local function starshine_keypressed(key, scancode, isrepeat)
    if key == "return" or key == "space" then
        dismissing = true
        targetY = offscreenY
    end
end

function starshine.show(msg, callback)
    if starshine.active then return end

    if not blurEffect then
        blurEffect = moonshine(moonshine.effects.gaussianblur)
    end

    local _, h = love.graphics.getDimensions()
    offscreenY = h + BOX_H
    targetY = h - BOX_H - 60
    boxY = offscreenY
    blurSigma = 0
    dismissing = false

    text = msg
    onDismiss = callback
    starshine.active = true

    original_update = love.update
    original_draw = love.draw
    original_keypressed = love.keypressed

    love.update = starshine_update
    love.draw = starshine_draw
    love.keypressed = starshine_keypressed
end

return starshine
