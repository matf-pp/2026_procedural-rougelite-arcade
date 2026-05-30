local utils = require("utils")
local colliders = require("colliders")

Pebble = {
    x = 0,
    y = 0,
    image = nil,
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
    alive = nil,
    collider = nil
}
Pebble.__index = Pebble

PebbleInterface = {}

function PebbleInterface.initPebbles()
    pebbles = {}; br = 1
    for i=1, utils.Cells.y do
        for j=1, utils.Cells.x do
            local pebbleInstance = {}
            setmetatable(pebbleInstance, Pebble)

            pebbleInstance.image = love.graphics.newImage('assets/pebble.png')
            pebbleInstance.scale_factor = {x=0.75, y=0.75}
            pebbleInstance.x = utils.Offset.x + utils.CellDimensions.x*(j-1) + utils.CellDimensions.x/2
            pebbleInstance.y = utils.Offset.y + utils.CellDimensions.y*(i-1) + utils.CellDimensions.y/2
            pebbleInstance.grid_data = {center = {x=j, y=i} }

            local radius = pebbleInstance.image:getWidth() * pebbleInstance.scale_factor.x / 2
            pebbleInstance.collider = colliders.CircleCollider.new(pebbleInstance.x, pebbleInstance.y, radius)

            if ((i==utils.Cells.y/2) and (j==utils.Cells.x/2 or j==utils.Cells.x/2+1)) then
                pebbleInstance.alive = false
            else
                pebbleInstance.alive = true
            end

            pebbles[br] = pebbleInstance
            br = br +1
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

function PebbleInterface.update(pebbles, player, scoreInfo)
    if not player or not player.collider or not scoreInfo then
        return
    end

    local localPebble = pebbles[(player.grid_data.center.y)*utils.Cells.x + (player.grid_data.center.x + 1)]
    if localPebble and localPebble.alive and localPebble.collider and player.collider:isColliding(localPebble.collider) then
        localPebble.alive = false
        scoreInfo.score = scoreInfo.score + 10
        scoreInfo.pebblesEaten = scoreInfo.pebblesEaten + 1
    end
end

function PebbleInterface.getTotal(pebbles)
    return #pebbles - 2
end

function PebbleInterface.drawPebbles(pebbles)
    for _, v in ipairs(pebbles) do
        if v.alive then
            v.collider:draw()
            love.graphics.draw(
                v.image,
                v.x,
                v.y,
                0,
                v.scale_factor.x,
                v.scale_factor.y,
                v.image:getWidth() / 2,
                v.image:getHeight() / 2
            )
        end
    end
end

return PebbleInterface