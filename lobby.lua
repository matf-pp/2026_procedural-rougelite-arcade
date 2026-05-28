local Lobby = {}

local colliders = require("colliders")
local utils = require("utils")
local animations = require("animations")

local playerX = 0
local playerY = 0

local playerScaleX = 5
local playerScaleY = 5

local playerDirection = utils.Directions.right

local playerCollider

local playerSpeed = 400

local speedX = 0
local speedY = 0

local leftDoorX
local leftDoorY
local leftDoorWidth
local leftDoorHeight
local leftDoorCollider

local rightDoorX
local rightDoorY
local rightDoorWidth
local rightDoorHeight
local rightDoorCollider

local topDoorX
local topDoorY
local topDoorWidth
local topDoorHeight
local topDoorCollider

local onLeftDoor
local onRightDoor
local onTopDoor

local lobbyBackground

local backgroundScaleX
local backgroundScaleY

local mainWallCollider

local w, h

local entering = false

local walkingSheetDown
local walkingSheetHorizontal
local walkingSheetUp
local animation = {}

local function setPlayerStartingPosition()
    playerX = w/2 - animation.walkingHorizontal.width * playerScaleX
    playerY = h/2 - animation.walkingHorizontal.height * playerScaleY
end

-- leva vrata: gl (106, 107) dd (125, 134)

-- desna vrata: gl (297, 106) dd (314, 138)

-- gornja vrata: gl (195, 29) dd (233, 38)

function Lobby.load(functionOnRightDoor, functionOnLeftDoor, functionOnTopDoor)
    onRightDoor = functionOnRightDoor
    onLeftDoor = functionOnLeftDoor
    onTopDoor = functionOnTopDoor
    lobbyBackground = love.graphics.newImage("assets/lobby.png")
    lobbyBackground:setFilter("nearest", "nearest")
    
    w, h, _ = love.window.getMode()
    
    mainWallCollider = colliders.CircleCollider.new(w/2, h/2, 480)
    
    backgroundScaleX = w / lobbyBackground:getWidth()
    backgroundScaleY = h / lobbyBackground:getHeight()
    
    leftDoorX = 106 * backgroundScaleX    --position on art times scale
    leftDoorY = 107 * backgroundScaleY
    leftDoorWidth = 19 * backgroundScaleX
    leftDoorHeight = 27 * backgroundScaleY
    leftDoorCollider = colliders.BoxCollider.new(leftDoorX, leftDoorY, leftDoorWidth, leftDoorHeight)
    
    rightDoorX = 297 * backgroundScaleX
    rightDoorY = 106 * backgroundScaleY
    rightDoorWidth = 17 * backgroundScaleX
    rightDoorHeight = 32 * backgroundScaleY
    rightDoorCollider = colliders.BoxCollider.new(rightDoorX, rightDoorY, rightDoorWidth, rightDoorHeight)
    
    topDoorX = 195 * backgroundScaleX
    topDoorY = 29 * backgroundScaleY
    topDoorWidth = 38 * backgroundScaleX
    topDoorHeight = 9 * backgroundScaleY
    topDoorCollider = colliders.BoxCollider.new(topDoorX, topDoorY, topDoorWidth, topDoorHeight)
    
    walkingSheetDown = love.graphics.newImage("assets/playerwalkingdown.png")
    walkingSheetHorizontal = love.graphics.newImage("assets/playerwalkinghorizontal.png")
    walkingSheetUp = love.graphics.newImage("assets/playerwalkingup.png")
    animation.walkingDown = animations.newAnimation(walkingSheetDown, 36, 36, 0.4)
    animation.walkingHorizontal = animations.newAnimation(walkingSheetHorizontal, 36, 36, 0.8)
    animation.walkingUp = animations.newAnimation(walkingSheetUp, 36, 36, 0.4)

    playerCollider = colliders.BoxCollider.new(playerX, playerY, animation.walkingHorizontal.width * playerScaleX, animation.walkingHorizontal.width * playerScaleY)
    
    setPlayerStartingPosition()
end

function Lobby.keypressed(key, scancode, isrepeat)
    if key == "w" or key == "up" then
        speedY = -playerSpeed
        playerDirection = utils.Directions.up
    end
    if key == "a" or key == "left" then
        speedX = -playerSpeed
        playerDirection = utils.Directions.left
    end
    if key == "s" or key == "down" then
        speedY = playerSpeed
        playerDirection = utils.Directions.down
    end
    if key == "d" or key == "right" then
        speedX = playerSpeed
        playerDirection = utils.Directions.right
    end
end

function Lobby.keyreleased(key, scancode, isrepeat)
    if (key == "w" or key == "up") and speedY < 0  then
        speedY = 0
    end
    if (key == "a" or key == "left") and speedX < 0 then
        speedX = 0
    end
    if (key == "s" or key == "down") and speedY > 0  then
        speedY = 0
    end
    if (key == "d" or key == "right") and speedX > 0 then
        speedX = 0
    end
end

function Lobby.movePlayer(dt)
    local oldX = playerX
    local oldY = playerY

    playerX = playerX + speedX * dt
    playerY = playerY + speedY * dt

    playerCollider:setPosition(playerX, playerY)

    if(not playerCollider:isInside(mainWallCollider)) then
        playerX = oldX
        playerY = oldY
    end
end

function Lobby.enterDoor()
    if not playerCollider:isColliding(leftDoorCollider) and not playerCollider:isColliding(rightDoorCollider) and not playerCollider:isColliding(topDoorCollider) then
        entering = false
    end
    if entering then return end
    if playerCollider:isColliding(leftDoorCollider) then
        onLeftDoor()
        setPlayerStartingPosition()
        entering = true
    elseif playerCollider:isColliding(rightDoorCollider) then
        onRightDoor()
        setPlayerStartingPosition()
        entering = true
    elseif playerCollider:isColliding(topDoorCollider) then
        onTopDoor()
        entering = true
    end
end

function Lobby.update(dt) --wrapper
    Lobby.movePlayer(dt)
    Lobby.enterDoor()
    if (Player.speed ~= 0) then
        animations.updateTime(animation.walkingDown, dt)
        animations.updateTime(animation.walkingHorizontal, dt)
        animations.updateTime(animation.walkingUp, dt)
    end
end

function Lobby.draw()
    love.graphics.draw(lobbyBackground , 0, 0, 0, backgroundScaleX, backgroundScaleY)

    playerCollider:draw()
    leftDoorCollider:draw()
    rightDoorCollider:draw()
    topDoorCollider:draw()
    mainWallCollider:draw()

    if playerDirection == utils.Directions.down then
        animations.draw(animation.walkingDown, playerX, playerY, playerScaleX, playerScaleY)
    elseif playerDirection == utils.Directions.up then
        animations.draw(animation.walkingUp, playerX, playerY, playerScaleX, playerScaleY)
    elseif playerDirection == utils.Directions.right then
        animations.draw(animation.walkingHorizontal, playerX, playerY, playerScaleX, playerScaleY)
    else
        local temp = playerX + (animation.walkingHorizontal.width * playerScaleX)
        animations.draw(animation.walkingHorizontal, temp, playerY, playerScaleX * -1, playerScaleY)
    end
end

return Lobby