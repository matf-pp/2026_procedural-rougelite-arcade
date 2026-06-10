local utils = require("utils")
local colliders = require("colliders")
local soundFX = require("soundFX")

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
    collider = nil,
    speed = utils.playerSpeed*0.4,
    toFollow = false
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
            pebbles[br].speed = utils.playerSpeed*0.4
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

local magnetActive = false
local magnet

function PebbleInterface.setMagnetTrue(MagnetPassive)
    magnetActive = true
    magnet = MagnetPassive
end

function PebbleInterface.setMagnetFalse(MagnetPassive)
    magnetActive = false
end

function PebbleInterface.update(pebbles, player, scoreInfo, dt)
    if not player or not player.collider or not scoreInfo then
        return
    end

    for _, p in ipairs(pebbles) do
        p.collider:setPosition(p.x, p.y)
        if p.collider:isColliding(player.collider) then
            if p.alive then
                scoreInfo.score = scoreInfo.score + 10
                scoreInfo.pebblesEaten = scoreInfo.pebblesEaten + 1
                soundFX.pebble()
            end
            p.alive = false
        end

        if magnetActive then
            magnet.colliderUpdate()

            if p.collider:isInside(magnet.collider) or p.toFollow then
                --p.toFollow = true
                local distX = (player.x - p.x)
                local distY = (player.y - p.y)
                local vecLength = math.sqrt(distX*distX + distY*distY)

                local speedMultiplierX = distX/vecLength
                local speedMultiplierY = distY/vecLength

                p.x = p.x + speedMultiplierX * p.speed * dt
                p.y = p.y + speedMultiplierY * p.speed * dt
                magnet.colliderUpdate()
            end
        end
    end
end

function PebbleInterface.getTotal(pebbles)
    return #pebbles - 2
end

function PebbleInterface.drawPebbles(pebbles)
    for _, v in ipairs(pebbles) do
        if v.alive then
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