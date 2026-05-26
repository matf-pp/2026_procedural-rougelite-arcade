local Lobby = {}

local playerX = 100
local playerY = 100

local playerSpeed = 150

local speedX = 0
local speedY = 0

local doorX = 960
local doorY = 540

local onEnter

function Lobby.load(functionOnEnter)
    onEnter = functionOnEnter
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
    if key == "w" or key == "up" then
        speedY = 0
    end
    if key == "a" or key == "left" then
        speedX = 0
    end
    if key == "s" or key == "down" then
        speedY = 0
    end
    if key == "d" or key == "right" then
        speedX = 0
    end
end

function Lobby.movePlayer(dt) 
    playerX = playerX + speedX * dt
    playerY = playerY + speedY * dt
end

function Lobby.enterDoor()
    if math.abs(playerX - doorX) < 10 and math.abs(playerY - doorY) < 10 then
        onEnter()
    end
end

function Lobby.update(dt) --wrapper
    Lobby.movePlayer(dt)
    Lobby.enterDoor()
end

function Lobby.draw()
    love.graphics.rectangle("fill", playerX, playerY, 20, 20)
    love.graphics.rectangle("fill", doorX, doorY, 20, 20)
end

return Lobby