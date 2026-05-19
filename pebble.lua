local utils = require("utils")

Pebble = {
    x = 0,
    y = 0,
    image = nil,
    x_shift = 0,
    y_shift = 0,
    center = {
        x = 0,
        y = 0
    },
    scale_factor = {
        x = 0.45,
        y = 0.45
    },
    grid_data = {
        center = {
            x = 0,
            y = 0
        }
    },
    alive = nil
}
Pebble.__index = Pebble

PebbleInterface = {}

function PebbleInterface.initPebbles()
    pebbles = {}; br = 1
    for i=1, utils.Cells.y do
        for j=1, utils.Cells.x do
            local pebbleInstance = {}
            setmetatable(pebbleInstance, Pebble)

            if ((i==utils.Cells.y/2) and (j==utils.Cells.x/2 or j==utils.Cells.x/2+1)) then
                pebbleInstance.alive = false
                pebbles[br] = pebbleInstance
                br = br + 1
                goto continue
            end
            
            pebbleInstance.image = love.graphics.newImage('assets/pebble.png')
            pebbleInstance.scale_factor = {x=0.75, y=0.75}
            pebbleInstance.x_shift = pebbleInstance.image:getWidth()/2 * pebbleInstance.scale_factor.x
            pebbleInstance.y_shift = pebbleInstance.image:getHeight()/2 * pebbleInstance.scale_factor.y

            pebbleInstance.alive = true
            pebbleInstance.center = {x=0, y=0}

            pebbleInstance.x = utils.Offset.x + utils.CellDimensions.x*(j-1)
            pebbleInstance.center.x = pebbleInstance.x + pebbleInstance.x_shift
            
            pebbleInstance.y = utils.Offset.y + utils.CellDimensions.y*(i-1)
            pebbleInstance.center.y = pebbleInstance.y + pebbleInstance.y_shift

            pebbleInstance.grid_data = {center = {x=j, y=i} }

            pebbles[br] = pebbleInstance
            br = br +1
            ::continue::
        end
    end

    return pebbles
end

function PebbleInterface.resetAllPebbles(pebbles)
    for i=1, utils.Cells.y do
        for j=1, utils.Cells.x do
            if (not ((i==utils.Cells.y/2) and (j==utils.Cells.x/2 or j==utils.Cells.x/2+1)) ) then
                pebbles[(i-1)*utils.Cells.x+j].alive = true
            end
        end
    end
end

function PebbleInterface.drawPebbles(pebbles)
    local cellX = utils.CellDimensions.x/2; local cellY = utils.CellDimensions.y/2

    for _, v in ipairs(pebbles) do
        if (v.alive) then
            love.graphics.draw(v.image, v.x + cellX - v.x_shift, v.y + cellY - v.y_shift, 0, v.scale_factor.x, v.scale_factor.y, 0, 0)
        end        
    end
end

return PebbleInterface