local utils = require("utils")
local animations = require("animations")
local colliders = require("colliders")
local soundFX = require("soundFX")

local Player = {
    x = 0,
    y = 0,
    image = love.graphics.newImage('assets/player.png'),
    scale_factor = {
        x = 2.5,
        y = 2.5
    },
    direction = nil,
    buffer_direction = 0,
    speed = 190,
    grid_data = {
        center = {
            x = 0,
            y = 0
        }
    },
    alive = true,
    animation = {},
    collider = nil,
    animationOrientation = 1,
    throughWall = false,
    score = 0
}

function Player.setPlayerPosition()
    Player.x = utils.Offset.x + (math.floor((utils.Cells.x/2)) * utils.CellDimensions.x) + utils.CellDimensions.x/2
    Player.y = utils.Offset.y + (math.floor((utils.Cells.y/1.2)) * utils.CellDimensions.y) + utils.CellDimensions.y/2

    Player:updateCollider()
end

function Player:initCollider()
    local width = Player.image:getWidth() * Player.scale_factor.x * 0.3
    local height = Player.image:getHeight() * Player.scale_factor.y * 0.6
    local offsetX = Player.image:getWidth() * Player.scale_factor.x * 0.35 - Player.image:getWidth()/2 * Player.scale_factor.x
    local offsetY = Player.image:getHeight() * Player.scale_factor.y * 0.2 - Player.image:getHeight()/2 * Player.scale_factor.y
    Player.collider = colliders.BoxCollider.new(Player.x, Player.y, width, height, offsetX, offsetY)
end

function Player:updateCollider()
    if Player.collider then
        Player.collider:setPosition(Player.x, Player.y)
    end
end

local localGameState = "menu"

local function isOppositeDirection(dirA, dirB)
    return dirA % 4 == (dirB + 2) % 4 
end

function Player.changeState(state)
    localGameState = state
end

function Player.updateDirection(key)
    local MovementKeys = {"w", "a", "s", "d", "up", "down", "left", "right"}

    for _, value in ipairs(MovementKeys) do
        if(key == value and localGameState == "playing") then

            if(key=="w" or key=="up") then
                Player.buffer_direction = utils.Directions.up
                Player.speed = utils.playerSpeed
            end

            if(key=="d" or key=="right") then
                Player.buffer_direction = utils.Directions.right
                Player.speed = utils.playerSpeed
            end

            if(key=="s" or key=="down") then
                Player.buffer_direction = utils.Directions.down
                Player.speed = utils.playerSpeed
            end
            if(key=="a" or key=="left") then
                Player.buffer_direction = utils.Directions.left
                Player.speed = utils.playerSpeed
            end

            if Player.direction == nil or isOppositeDirection(Player.buffer_direction, Player.direction) then
                Player.direction = Player.buffer_direction
            end
        
        end
    end
end

--wrapper
function Player.correctPosition()
    local tmp = utils.gridDataToPx(Player.grid_data.center.x, Player.grid_data.center.y)
    Player.x = tmp[1]
    Player.y = tmp[2]
    Player:updateCollider()
end

function Player.changeDirection()

    --[[
    ako igrac pokusa da promeni smer negde gde je zid dok moze da nastavi dalje istim smerom, ne menjamo smer (nema stajanja dok se ne uradi u zid trenutnim smerom)
    -- ------------------- 
    --    igrac-> -> ->      bez obzira na ulaz, igrac ide napred
    -- -------------------
    --]]
    if(not ( mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[Player.direction] )
       and ( mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[Player.buffer_direction]) ) then
        return
    end

    Player.direction = Player.buffer_direction

    Player.correctPosition()
end

--wrapper
function Player.isInCenter(dt)
    return utils.isInCenter(Player.x, Player.y, Player.grid_data.center.x, Player.grid_data.center.y, Player.speed, dt)
end

function Player.move(dt, mazeGrid)
    if Player.throughWall==false and Player.isInCenter(dt) then
        if( Player.direction == utils.Directions.up and mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[utils.Directions.up] ) then
            return
        end
        if( Player.direction == utils.Directions.down and mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[utils.Directions.down] ) then
            return
        end
        if( Player.direction == utils.Directions.right and mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[utils.Directions.right] ) then
            return
        end
        if( Player.direction == utils.Directions.left and mazeGrid[Player.grid_data.center.y+1][Player.grid_data.center.x+1].walls[utils.Directions.left] ) then
            return
        end
    end

    if(Player.direction == utils.Directions.up) then
        Player.y = Player.y - Player.speed*dt
    end

    if(Player.direction == utils.Directions.down) then
        Player.y = Player.y + Player.speed*dt
    end

    if(Player.direction == utils.Directions.left) then
        Player.x = Player.x - Player.speed*dt
    end

    if(Player.direction == utils.Directions.right) then
        Player.x = Player.x + Player.speed*dt
    end

    Player:updateCollider()

    Player.grid_data.center.x = math.floor(( Player.x - utils.Offset.x ) / utils.CellDimensions.x )
    Player.grid_data.center.y = math.floor(( Player.y - utils.Offset.y ) / utils.CellDimensions.y )
end

function Player.loadAnimation()
    Player.walkingSheetDown = love.graphics.newImage("assets/playerwalkingdown.png")
    Player.walkingSheetHorizontal = love.graphics.newImage("assets/playerwalkinghorizontal.png")
    Player.walkingSheetUp = love.graphics.newImage("assets/playerwalkingup.png")
    Player.animation.walkingDown = animations.newAnimation(Player.walkingSheetDown, 36, 36, 0.4)
    Player.animation.walkingHorizontal = animations.newAnimation(Player.walkingSheetHorizontal, 36, 36, 0.8)
    Player.animation.walkingUp = animations.newAnimation(Player.walkingSheetUp, 36, 36, 0.4)
    Player:initCollider()
end

function Player.updateAnimation(dt)
    if (Player.speed ~= 0) then
        animations.updateTime(Player.animation.walkingDown, dt)
        animations.updateTime(Player.animation.walkingHorizontal, dt)
        animations.updateTime(Player.animation.walkingUp, dt)
    end

    if(Player.direction == utils.Directions.right) then
        Player.animationOrientation = 1
    elseif(Player.direction == utils.Directions.left) then
        Player.animationOrientation = -1
    end
end

function Player.draw()
    if(Player.alive) then
        local playerX = Player.x
        local playerY = Player.y
        local animationToDraw

        if Player.direction == utils.Directions.down then
            animationToDraw = Player.animation.walkingDown
        elseif Player.direction == utils.Directions.up then
            animationToDraw = Player.animation.walkingUp
        else
            animationToDraw = Player.animation.walkingHorizontal
        end

        local originX = animationToDraw.width/2
        local originY = animationToDraw.height/2
        local scaleX = Player.animationOrientation * Player.scale_factor.x

        animations.draw(animationToDraw, playerX, playerY, scaleX, Player.scale_factor.y, originX, originY)
    end
end

function Player.update(dt)
    if(Player.alive) then
        if( Player.isInCenter(dt) ) then
            Player.changeDirection()
        end

        Player.move(dt, mazeGrid)
    else
        Player.speed = 0
    end

    --Player animation control
    Player.updateAnimation(dt)
end

function Player.kill()
    if Player.alive then soundFX.death() end
    Player.alive = false
end

return Player