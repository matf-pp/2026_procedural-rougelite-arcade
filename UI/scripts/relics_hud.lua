local relics_hud = {}

local maze = require("maze")

local relicSheet
local rQuads = {}
local rTileW
local rScale

function relics_hud.load()
    relicSheet = love.graphics.newImage("assets/relic-sheet.png")
    relicSheet:setFilter("nearest", "nearest")
    local sheetW, sheetH = relicSheet:getDimensions()
    rTileW = sheetW / 3
    rScale = maze.CellDimensions.x / rTileW
    rQuads.corner = love.graphics.newQuad(0,          0, rTileW, sheetH, relicSheet)
    rQuads.wall   = love.graphics.newQuad(rTileW,     0, rTileW, sheetH, relicSheet)
    rQuads.middle = love.graphics.newQuad(2 * rTileW, 0, rTileW, sheetH, relicSheet)
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

function relics_hud.draw()
    local cs = maze.CellDimensions.x
    love.graphics.setColor(1, 1, 1, 1)

    -- leva strana: 3 slota za aktivne relikvije, svaki 3x3, vertikalno
    local slotW, slotH = 3, 3
    local gapCells = 1
    local totalH = 3 * slotH + 2 * gapCells
    local leftX = maze.Offset.x - (slotW + 2) * cs
    local leftY = maze.Offset.y + (maze.rows - totalH) / 2 * cs
    for i = 0, 2 do
        drawCutout(leftX, leftY + i * (slotH + gapCells) * cs, slotW, slotH)
    end

    -- desna strana: skor (4x2) gore, pasivne relikvije (4x4) dole
    local rightX = maze.Offset.x + maze.cols * cs + cs
    drawCutout(rightX, maze.Offset.y,                                    4, 2)
    drawCutout(rightX, maze.Offset.y + (maze.rows - 4) * cs,             4, 4)
end

return relics_hud
