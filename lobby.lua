local Lobby = {}

local colliders = require("colliders")
local utils = require("utils")
local animations = require("animations")
local soundFX = require("soundFX")

local playerX = 0
local playerY = 0

local playerScaleX = 5
local playerScaleY = 5

local playerCollider

local playerSpeed = 400

local speedX = 0
local speedY = 0



local onLeftDoor
local onRightDoor
local onTopDoor

local lobbyBackground

local backgroundScaleX
local backgroundScaleY

local mainWallCollider

local leftDoorCollider
local rightDoorCollider
local topDoorCollider
local obstacleColliders = {}

local w, h

local entering = false

local walkingSheetDown
local walkingSheetHorizontal
local walkingSheetUp
local animation = {}

function Lobby.setPlayerStartingPosition()
    local rx = love.math.random(-10, 10) * backgroundScaleX
    local ry = love.math.random(-10, 10) * backgroundScaleY
    playerX = w/2 + rx
    playerY = h/2 + ry
    if playerCollider then playerCollider:setPosition(playerX, playerY) end
end

-- leva vrata: gl (106, 107) dd (125, 134)

-- desna vrata: gl (297, 106) dd (314, 138)

-- gornja vrata: gl (195, 29) dd (233, 38)

--levi cupovi 126,92 r=6
--veliki cup gore 170,35 i 180,50
--manji cup gore 186, 40 r = 5
--desno cupovi 291, 77 i 301, 92
--desno klupa 279, 92 i 308, 103
--kolica 300,142 i 313, 157
--donji cup 186, 211 r=6

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
    
    local leftDoorX = 106 * backgroundScaleX    --position on art times scale
    local leftDoorY = 107 * backgroundScaleY
    local leftDoorWidth = 19 * backgroundScaleX
    local leftDoorHeight = 27 * backgroundScaleY
    leftDoorCollider = colliders.BoxCollider.new(leftDoorX, leftDoorY, leftDoorWidth, leftDoorHeight)
    
    local rightDoorX = 297 * backgroundScaleX
    local rightDoorY = 106 * backgroundScaleY
    local rightDoorWidth = 17 * backgroundScaleX
    local rightDoorHeight = 32 * backgroundScaleY
    rightDoorCollider = colliders.BoxCollider.new(rightDoorX, rightDoorY, rightDoorWidth, rightDoorHeight)
    
    local topDoorX = 195 * backgroundScaleX
    local topDoorY = 29 * backgroundScaleY
    local topDoorWidth = 38 * backgroundScaleX
    local topDoorHeight = 9 * backgroundScaleY
    topDoorCollider = colliders.BoxCollider.new(topDoorX, topDoorY, topDoorWidth, topDoorHeight)

    local leftPotX = 126 * backgroundScaleX
    local leftPotY = 92 * backgroundScaleY
    local leftPotRadius = 6 * backgroundScaleX
    obstacleColliders[1] = colliders.CircleCollider.new(leftPotX, leftPotY, leftPotRadius)

    local upperBigPotX = 170 * backgroundScaleX
    local upperBigPotY = 35 * backgroundScaleY
    local upperBigPotWidth = 10 * backgroundScaleX
    local upperBigPotHeight = 15 * backgroundScaleY
    obstacleColliders[2] = colliders.BoxCollider.new(upperBigPotX, upperBigPotY, upperBigPotWidth, upperBigPotHeight)

    local upperSmallPotX = 186 * backgroundScaleX
    local upperSmallPotY = 40 * backgroundScaleY
    local upperSmallPotRadius = 5 * backgroundScaleX
    obstacleColliders[3] = colliders.CircleCollider.new(upperSmallPotX, upperSmallPotY, upperSmallPotRadius)

    local rightPotX = 291 * backgroundScaleX
    local rightPotY = 77 * backgroundScaleY
    local rightPotWidth = 10 * backgroundScaleX
    local rightPotHeight = 15 * backgroundScaleY
    obstacleColliders[4] = colliders.BoxCollider.new(rightPotX, rightPotY, rightPotWidth, rightPotHeight)

    local benchX = 279 * backgroundScaleX
    local benchY = 92 * backgroundScaleY
    local benchWidth = 29 * backgroundScaleX
    local benchHeight = 11 * backgroundScaleY
    obstacleColliders[5] = colliders.BoxCollider.new(benchX, benchY, benchWidth, benchHeight)

    local cartX = 300 * backgroundScaleX
    local cartY = 142 * backgroundScaleY
    local cartWidth = 13 * backgroundScaleX
    local cartHeight = 15 * backgroundScaleY
    obstacleColliders[6] = colliders.BoxCollider.new(cartX, cartY, cartWidth, cartHeight)

    local lowerPotX = 186 * backgroundScaleX
    local lowerPotY = 211 * backgroundScaleY
    local lowerPotRadius = 6 * backgroundScaleX
    obstacleColliders[7] = colliders.CircleCollider.new(lowerPotX, lowerPotY, lowerPotRadius)
    
    walkingSheetDown = love.graphics.newImage("assets/playerwalkingdown.png")
    walkingSheetHorizontal = love.graphics.newImage("assets/playerwalkinghorizontal.png")
    walkingSheetUp = love.graphics.newImage("assets/playerwalkingup.png")
    animation.walkingDown = animations.newAnimation(walkingSheetDown, 36, 36, 0.4)
    animation.walkingHorizontal = animations.newAnimation(walkingSheetHorizontal, 36, 36, 0.8)
    animation.walkingUp = animations.newAnimation(walkingSheetUp, 36, 36, 0.4)

    -- spawn player in the screen center (playerX/playerY are the sprite center)
    Lobby.setPlayerStartingPosition()

    local width = Player.image:getWidth() * playerScaleX * 0.3
    local height = Player.image:getHeight() * playerScaleY * 0.6
    local offsetX = -width / 2
    local offsetY = -height / 2
    playerCollider = colliders.BoxCollider.new(playerX, playerY, width, height, offsetX, offsetY)
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

    local newSpeedX = speedX
    local newSpeedY = speedY

    if speedX ~= 0 and speedY ~= 0 then
        newSpeedX = newSpeedX / math.sqrt(2)
        newSpeedY = newSpeedY / math.sqrt(2)
    end

    playerX = playerX + newSpeedX * dt
    playerY = playerY + newSpeedY * dt

    playerCollider:setPosition(playerX, playerY)

    if(not playerCollider:isInside(mainWallCollider)) then
        playerX = oldX
        playerY = oldY
        playerCollider:setPosition(playerX, playerY)
    end

    for _, obstacleCollider in ipairs(obstacleColliders) do
        if playerCollider:isColliding(obstacleCollider) then
            playerX = oldX
            playerY = oldY
            playerCollider:setPosition(playerX, playerY)
        end
    end
end

function Lobby.enterDoor()
    if not playerCollider:isColliding(leftDoorCollider) and not playerCollider:isColliding(rightDoorCollider) and not playerCollider:isColliding(topDoorCollider) then
        entering = false
    end
    if entering then return end
    if playerCollider:isColliding(leftDoorCollider) then
        onLeftDoor()
        entering = true
    elseif playerCollider:isColliding(rightDoorCollider) then
        onRightDoor()
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

    local ox = animation.walkingHorizontal.width / 2
    local oy = animation.walkingHorizontal.height / 2
    if speedX > 0 then
        animations.draw(animation.walkingHorizontal, playerX, playerY, playerScaleX, playerScaleY, ox, oy)
    elseif speedX < 0 then
        animations.draw(animation.walkingHorizontal, playerX, playerY, -playerScaleX, playerScaleY, ox, oy)
    elseif speedY < 0 then
        animations.draw(animation.walkingUp, playerX, playerY, playerScaleX, playerScaleY, animation.walkingUp.width/2, animation.walkingUp.height/2)
    else
        animations.draw(animation.walkingDown, playerX, playerY, playerScaleX, playerScaleY, animation.walkingDown.width/2, animation.walkingDown.height/2)
    end
end

return Lobby