local relics_hud = {}

local maze = require("maze")

local relicSheet
local rQuads = {}
local rTileW
local rScale
local labelFont

function relics_hud.load()
    relicSheet = love.graphics.newImage("assets/relic-sheet.png")
    relicSheet:setFilter("nearest", "nearest")
    local sheetW, sheetH = relicSheet:getDimensions()
    rTileW = sheetW / 3
    rScale = maze.CellDimensions.x / rTileW
    rQuads.corner = love.graphics.newQuad(0,          0, rTileW, sheetH, relicSheet)
    rQuads.wall   = love.graphics.newQuad(rTileW,     0, rTileW, sheetH, relicSheet)
    rQuads.middle = love.graphics.newQuad(2 * rTileW, 0, rTileW, sheetH, relicSheet)
    labelFont = love.graphics.newFont("assets/fonts/creato_display/CreatoDisplay-Medium.otf", 18)
end

local function drawCutout(ox, oy, wCells, hCells)
    local cs = maze.CellDimensions.x
    for row = 0, hCells - 1 do
        for col = 0, wCells - 1 do
            local cx = ox + col * cs + cs / 2
            local cy = oy + row * cs + cs / 2
            local quad, angle
            if     row == 0          and col == 0          then quad, angle = rQuads.corner, 0
            elseif row == 0          and col == wCells - 1 then quad, angle = rQuads.corner, 90
            elseif row == hCells - 1 and col == 0          then quad, angle = rQuads.corner, 270
            elseif row == hCells - 1 and col == wCells - 1 then quad, angle = rQuads.corner, 180
            elseif row == 0                                 then quad, angle = rQuads.wall,   0
            elseif row == hCells - 1                        then quad, angle = rQuads.wall,   180
            elseif col == 0                                 then quad, angle = rQuads.wall,   270
            elseif col == wCells - 1                        then quad, angle = rQuads.wall,   90
            else                                                 quad, angle = rQuads.middle, 0
            end
            love.graphics.draw(relicSheet, quad, cx, cy, math.rad(angle), rScale, rScale, rTileW / 2, rTileW / 2)
        end
    end
end

local keyLabels = {"J", "K", "L"}
local barHeight = 10
local barMargin = 20

function relics_hud.draw(activeRelics, passiveRelics)
    local cs = maze.CellDimensions.x
    love.graphics.setColor(1, 1, 1, 1)

    local slotW, slotH = 3, 3
    local gapCells = 1
    local totalH = 3 * slotH + 2 * gapCells
    local leftX = maze.Offset.x - (slotW + 2) * cs
    local leftY = maze.Offset.y + (maze.rows - totalH) / 2 * cs
    local slotPx = slotW * cs

    for i = 1, 3 do
        local ox = leftX
        local oy = leftY + (i - 1) * (slotH + gapCells) * cs

        love.graphics.setColor(1, 1, 1, 1)
        drawCutout(ox, oy, slotW, slotH)

        local relic = activeRelics[i]
        if relic then
            -- key label (top-left corner)
            love.graphics.setFont(labelFont)
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.print(keyLabels[i], ox + 10, oy + 10)

            local imgW = relic.image:getWidth()
            local imgH = relic.image:getHeight()
            local targetSize = slotPx * 0.45
            local iconScale = math.min(targetSize / imgW, targetSize / imgH)
            local imgCX = ox + slotPx / 2
            local imgCY = oy + slotPx / 2 - barHeight
            local ready = relic.timerCooldown >= relic.cooldown
            love.graphics.setColor(1, 1, 1, ready and 1 or 0.4)
            love.graphics.draw(relic.image, imgCX, imgCY, 0,
                iconScale, iconScale,
                imgW / 2, imgH / 2)

            -- cooldown crtica kako god
            local fill     = math.min(relic.timerCooldown / relic.cooldown, 1)
            local barX     = ox + barMargin
            local barY     = oy + slotPx - barMargin - barHeight
            local barW     = slotPx - 2 * barMargin

            love.graphics.setColor(0.25, 0.25, 0.25, 0.9)
            love.graphics.rectangle("fill", barX, barY, barW, barHeight, 4, 4)

            love.graphics.setColor(ready and {0.2, 0.9, 0.35, 1} or {0.4, 0.55, 1, 1})
            love.graphics.rectangle("fill", barX, barY, barW * fill, barHeight, 4, 4)
        end
    end

    -- desna strana: skor (4x2) gore, pasivni relici (4x4) dole
    local passiveW, passiveH = 4, 4
    local passivePx = passiveW * cs
    local rightX = maze.Offset.x + maze.cols * cs + cs
    local passiveY = maze.Offset.y + (maze.rows - passiveH) * cs

    -- btw sve ovde sam morao da racunam malo dinamicno zbog toga sto se velicina maze-a menja

    love.graphics.setColor(1, 1, 1, 1)
    drawCutout(rightX, maze.Offset.y, 4, 2)
    drawCutout(rightX, passiveY, passiveW, passiveH)

    -- nemamo pasivne relike sada pa crtam ove aktivne cisto da se vidi dole nesto
    local drawRelics = #passiveRelics > 0 and passiveRelics or activeRelics

    local cellPx = passivePx / 2
    for i, relic in ipairs(drawRelics) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local ox = rightX + col * cellPx
        local oy = passiveY + row * cellPx

        local imgW = relic.image:getWidth()
        local imgH = relic.image:getHeight()
        local targetSize = cellPx * 0.55
        local iconScale = math.min(targetSize / imgW, targetSize / imgH)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(relic.image, ox + cellPx / 2, oy + cellPx / 2, 0,
            iconScale, iconScale, imgW / 2, imgH / 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return relics_hud
