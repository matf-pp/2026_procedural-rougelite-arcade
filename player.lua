local utils = require("utils")
local animations = require("animations")

Player = {
    x = 0,
    y = 0,
    image = love.graphics.newImage('assets/player.png'),
    x_shift = 0,
    y_shift = 0,
    center = {
        x = 0,
        y = 0
    },
    scale_factor = {
        x = 3.5,
        y = 3.5
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
    walkingSheet = nil,
    animation = {},
    animationOrientation = 1,
    throughWall = false,
    score = 0
}

function Player.setPlayerPosition()
    Player.x_shift = Player.image:getWidth()/2 * Player.scale_factor.x
    Player.y_shift = Player.image:getHeight()/2 * Player.scale_factor.y

    Player.x = utils.Offset.x + (math.floor((utils.Cells.x/2)) * utils.CellDimensions.x) - Player.x_shift + utils.CellDimensions.x/2
    Player.y = utils.Offset.y + (math.floor((utils.Cells.y/1.2)) * utils.CellDimensions.y) - Player.y_shift + utils.CellDimensions.y/2

    Player.center.x = Player.x + Player.x_shift
    Player.center.y = Player.y + Player.y_shift
end

local localGameState = "menu"

function Player.changeState(state)
    localGameState = state
end

function Player.updateDirection(key)
    MovementKeys = {"w", "a", "s", "d", "up", "down", "left", "right"}

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
        
        end
    end
end

--wrapper
function Player.correctPosition()
    local tmp = utils.gridDataToPx(Player.grid_data.center.x, Player.grid_data.center.y, Player.x_shift, Player.y_shift)
    Player.x = tmp[1]
    Player.y = tmp[2]
    
    Player.center.x = Player.x + Player.x_shift
    Player.center.y = Player.y + Player.y_shift
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
    return utils.isInCenter(Player.center.x, Player.center.y, Player.grid_data.center.x, Player.grid_data.center.y, Player.speed, dt)
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

    Player.center.x = Player.x + Player.x_shift
    Player.center.y = Player.y + Player.y_shift

    Player.grid_data.center.x = math.floor(( Player.center.x - utils.Offset.x ) / utils.CellDimensions.x )
    Player.grid_data.center.y = math.floor(( Player.center.y - utils.Offset.y ) / utils.CellDimensions.y )
end

function Player.loadAnimation()
    Player.walkingSheet = love.graphics.newImage("assets/playerwalking.png")
    Player.animation = animations.newAnimation(Player.walkingSheet, 16, 16, 0.8)
end

function Player.updateAnimation(dt)
    if (Player.speed ~= 0) then
        animations.updateTime(Player.animation, dt)
    end

    if(Player.direction == utils.Directions.right) then
        Player.animationOrientation = 1
    elseif(Player.direction == utils.Directions.left) then
        Player.animationOrientation = -1
    end
end

function Player.draw()
    if(Player.alive) then
        love.graphics.setColor(255, 255, 255, 1)
        local playerX = Player.x
        local playerY = Player.y
        if (Player.animationOrientation == -1) then
            playerX = playerX + (Player.animation.width * Player.scale_factor.x)
        end
        animations.draw(Player.animation, playerX, playerY, Player.animationOrientation * Player.scale_factor.x, Player.scale_factor.y)
    else
        love.graphics.print("Player collision with Enemy ", 100, 980)
    end
end

return Player