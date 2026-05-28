local Lobby = {}

local colliders = require("colliders")

local playerX = 0
local playerY = 0

local playerCollider = colliders.BoxCollider.new(playerX, playerY, 20, 100)

local playerSpeed = 150

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

local function setPlayerStartingPosition()
    playerX = w/2
    playerY = h/2
end

local entering = false

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

    setPlayerStartingPosition()

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
end

function Lobby.keypressed(key, scancode, isrepeat)
    if key == "w" or key == "up" then
        speedY = -playerSpeed
    end
    if key == "a" or key == "left" then
        speedX = -playerSpeed
    end
    if key == "s" or key == "down" then
        speedY = playerSpeed
    end
    if key == "d" or key == "right" then
        speedX = playerSpeed
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
end

function Lobby.draw()
    love.graphics.draw(lobbyBackground , 0, 0, 0, backgroundScaleX, backgroundScaleY)

    love.graphics.rectangle("fill", playerX, playerY, 20, 20)

    playerCollider:draw()
    leftDoorCollider:draw()
    rightDoorCollider:draw()
    topDoorCollider:draw()
    mainWallCollider:draw()
end

return Lobby