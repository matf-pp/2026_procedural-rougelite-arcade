local utils = require("utils")
local maze = require("maze")
local collision = require("collision")
local player = require("player")
               require("enemy")
               require("relics")
local pebble = require("pebble")
local ui_main = require("UI.scripts.ui_main")
local animations = require("animations")

local gameState = utils.gameState
local fullscreen = false

local mazeCanvas
local makeMazeCanvas = true
local main_debug = true

local score = 0
local pebblesEaten = 0
local numOfPebbles = 0

local Enemies = {}
local numOfEnemies = 0
local midY = 0; local midX = 0;

local RelicOptions = {}
local ActiveRelics = {}
local PassiveRelics = {}

local PlayerAnimation = {}
local PlayerAnimationOrientation = 1

level = 0

--number of cells in maze
utils.Cells.x = 12
utils.Cells.y = 12

function love.load()
    utils.fonts.default = love.graphics.newFont("assets/fonts/creato_display/CreatoDisplay-Medium.otf")
    utils.fonts.pause = love.graphics.newFont("assets/fonts/absender/absender1.ttf", 40)

    love.graphics.setFont(utils.fonts.default)

    music = love.audio.newSource('assets/music/pesma.wav', 'stream')
    music:setLooping(true)
    music:setVolume(0.2)
    music:play()
    
    math.randomseed(os.time())
    love.window.setFullscreen(true, "desktop")
    fullscreen = true
    ui_main.load(function() gameState = "playing" end)

    --ucitavanje podataka za utils
    local _, _, flags = love.window.getMode()
    utils.vsync = flags.refreshrate
    utils.enemySpeed = 220
    utils.playerSpeed = 210
    local windowWidth, windowHeight, _ = love.window.getMode()
    utils.windowWidth = windowWidth; utils.windowHeight = windowHeight

    --generacija mape
    maze.load(utils.Cells.x, utils.Cells.y)
    mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    --generacija pebble-ova
    pebbles = pebble.initPebbles()

    --ucitavanje igraca
    player.setPlayerPosition()

    --ucitavanje neprijatelja
    numOfEnemies = utils.numberOfEnemies

    for i=1, numOfEnemies do
        table.insert(Enemies, newEnemy(i))
    end
    timerEnemySpawn = 0
    midY = utils.Cells.y/2; midX = utils.Cells.x/2;
    numOfPebbles = #pebbles - 2

    PlayerWalkingSheet = love.graphics.newImage("assets/playerwalking.png")
    PlayerAnimation = animations.newAnimation(PlayerWalkingSheet, 16, 16, 0.8)

end

local offset = 4; local br = 1;

function pause()
    player.speed=0
    for _, Enemy in ipairs(Enemies) do
        Enemy.speed = 0
    end
    
end

function unpause()
    player.speed = utils.playerSpeed
    for _, Enemy in ipairs(Enemies) do
        Enemy.speed = utils.enemySpeed
    end
    gameState = "playing"
end

function newLevel()
    if level == 1 then
        utils.Cells.x = 14
        utils.Cells.y = 14
        utils.numberOfEnemies = 7
        --Relics[1] = newSpeedRelic()
    elseif level == 2 then
        utils.Cells.x = 16
        utils.Cells.y = 16
        utils.numberOfEnemies = 10
    end

    maze.load(utils.Cells.x, utils.Cells.y)
    mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    
    pebbles = pebble.initPebbles()
    pebble.resetAllPebbles(pebbles)
    numOfPebbles = #pebbles - 2
    pebblesEaten = 0

    player.alive = true
    player.setPlayerPosition()
    player.direction = 0
    player.buffer_direction = 0
    
    --resetovanje promenljivih za Enemy spawn
    timerEnemySpawn = 0; br = 1; offset = 4
    midY = utils.Cells.y/2; midX = utils.Cells.x/2;
    
    Enemies = {}
    for i=1, utils.numberOfEnemies do
        table.insert(Enemies, newEnemy(i))
    end
    numOfEnemies = #Enemies

    makeMazeCanvas = true 

    unpause()
end

function changeFullscreen()
    if fullscreen then love.window.setFullscreen(false, "desktop"); fullscreen=false;
    else love.window.setFullscreen(true, "desktop"); fullscreen=true end
end

function love.update(dt)
    utils.FPS = love.timer.getFPS()

    player.changeState(gameState) -- this is so player.lua doesn't call global variable from utils every frame in updateDirection()

    for _, relic in ipairs(ActiveRelics) do
        relic.update(dt)
    end

    if gameState == "menu" then ui_main.update(dt); return 
    elseif gameState == "pause" then
        pause()
    elseif gameState == "victory" then
        pause()
        if(#RelicOptions == 0) then
            RelicOptions[1] = newDashRelic()
        end
    else
        if pebblesEaten >= numOfPebbles then
            gameState = "victory"
            level = level + 1
        end

        --player update logic
        if(player.alive) then
            if( player.isInCenter(dt) ) then
                local localPebble = pebbles[(player.grid_data.center.y)*utils.Cells.x+(player.grid_data.center.x+1)]
                if localPebble.alive then localPebble.alive = false; score = score + 10; pebblesEaten = pebblesEaten+1 end
                
                player.changeDirection()
            end

            player.move(dt, mazeGrid)
        else
            player.speed = 0
        end

        --player animation control

        if (player.speed ~= 0) then
            animations.updateTime(PlayerAnimation, dt)
        end

        if(player.direction == utils.Directions.right) then
            PlayerAnimationOrientation = 1
        elseif(player.direction == utils.Directions.left) then
            PlayerAnimationOrientation = -1
        end

        --enemy update logic
            --enemy spawn and move
            --na svakih offset sekundi se otvaraju zidovi u kutiji sa donje strane
        timerEnemySpawn = timerEnemySpawn + dt;
        if ( (math.floor(timerEnemySpawn) == (offset)) and br~=0) then
            if br%2 == 0 then
                mazeGrid[midY+1][midX].walls[utils.Directions.up] = false
                mazeGrid[midY+1][midX+1].walls[utils.Directions.up] = false             
            else
                mazeGrid[midY][midX].walls[utils.Directions.up] = false
                mazeGrid[midY][midX+1].walls[utils.Directions.up] = false
            end
            Enemies[br].exitSpawn = true
            offset = offset + 4
        end

        for _, Enemy in ipairs(Enemies) do
            if Enemy.exitSpawn == false then --provera da li treba da izadje iz centralne kutije
                if Enemy:isInCenter(dt) then

                    --ako je zaglavljen da se odglavi tj odmah promeni smer
                    for smer, postojiZid in ipairs(mazeGrid[Enemy.grid_data.center.y+1][Enemy.grid_data.center.x+1].walls) do
                        if postojiZid and Enemy.direction == smer then
                            Enemy:changeDirection()
                        end
                    end

                    --u suprotnom redovno proverava da li da promeni smer ili ne
                    if(math.random(1,4)==2) then
                        Enemy:changeDirection()
                    end
                end
            else
                --manuelno postavljanje smera da izadje iz kutije
                if br%2 == 0 then
                    Enemy:changeDirection(utils.Directions.down)
                else 
                    Enemy:changeDirection(utils.Directions.up)
                end
                Enemy:move(dt)  --smemo da pozovemo move() i ako nismo prvo proverili isInCenter() jer changeDirection() poziva correctPosition()
                Enemy.exitSpawn = false
                if (br>=numOfEnemies) then br=0 else br=br+1 end
            end
            Enemy:move(dt)
                mazeGrid[midY][midX].walls[utils.Directions.up] = true
                mazeGrid[midY][midX+1].walls[utils.Directions.up] = true
                mazeGrid[midY+1][midX].walls[utils.Directions.up] = true
                mazeGrid[midY+1][midX+1].walls[utils.Directions.up] = true

            --checking collision with player
            if (gridCollision(Enemy.grid_data.center.x, Enemy.grid_data.center.y, player.grid_data.center.x, player.grid_data.center.y))==true then
                player.alive=false
            end
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "menu" then ui_main.mousepressed(x, y, button, istouch, presses) end
end

function love.mousereleased(x, y, button, istouch, presses)
    if gameState == "menu" then ui_main.mousereleased(x, y, button, istouch, presses) end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if gameState == "menu" then ui_main.mousemoved(x, y, dx, dy, istouch) end
end

function love.keypressed( key, scancode, isrepeat )
    if gameState == "menu" then ui_main.keypressed(key, scancode, isrepeat); return end

    player.updateDirection(key)

    if(key == "return") then
        newLevel()
    end

    if(key == "j" and #ActiveRelics~=0) then
        if(ActiveRelics[1].canUse()) then
            ActiveRelics[1].use()
        end
    end

    if(key == "b") then
        if gameState=="shop" then gameState = "menu"
        else gameState = "shop" end
    end

    if(key == "f") then
        changeFullscreen()
    end

    if(key == "escape") then
        gameState = "menu"
    end

    if(key == "x") then
        gameState = "pause"
    end

    if(key == "c") then
        unpause()
    end

    if(key == "m") then
        music:setVolume(0.0)
    end

    if(key == "v") then
        pebblesEaten = numOfPebbles
    end
end

function love.draw()
    local width = utils.windowWidth; local height = utils.windowHeight
    if gameState == "menu" then ui_main.draw(); return end
    
    --crtanje lavirinta
    if(makeMazeCanvas) then
        mazeCanvas = maze.drawMaze(utils.Cells.x, utils.Cells.y, mazeGrid)

        makeMazeCanvas = false
    end
    love.graphics.draw(mazeCanvas, 0 , 0)

    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.print("Press enter to generate a new maze", width/2 - 110, 10)

    --crtanje pebblova
    pebble.drawPebbles(pebbles)
    love.graphics.print("Score: " .. score, width/2 - 50, 100)

    --crtanje igraca
    if(player.alive) then
        love.graphics.setColor(255, 255, 255, 1)
        local playerX = player.x
        local playerY = player.y
        if (PlayerAnimationOrientation == -1) then
            playerX = playerX + (PlayerAnimation.width * player.scale_factor.x)
        end
        animations.draw(PlayerAnimation, playerX, playerY, PlayerAnimationOrientation * player.scale_factor.x, player.scale_factor.y)
    else
        love.graphics.print("Player collision with Enemy ", 100, 980)
    end

    --crtanje neprijatelja
    for _, v in ipairs(Enemies) do
        love.graphics.draw(v.image, v.x, v.y, 0, v.scale_factor.x, v.scale_factor.y, 0, 0)
    end

    --crtanje ActiveRelics (HUD)
    if #ActiveRelics > 0 then
        local offset = 0
        for _, relic in ipairs(ActiveRelics) do
            love.graphics.setFont(utils.fonts.pause)
            love.graphics.print("ACTIVE RELICS", width-350+offset, 700)
            love.graphics.draw(relic.image, width-400+offset, 750, 0, relic.scale_factor.x, relic.scale_factor.y, 0, 0)
            love.graphics.setFont(utils.fonts.default)
            offset = offset + 600
        end
    end
    
    --crtanje PassiveRelics (HUD)
    if #PassiveRelics > 0 then
        local offset = 0
        for _, relic in ipairs(PassiveRelics) do
            love.graphics.setFont(utils.fonts.pause)
            love.graphics.print("PASSIVE RELICS", width-350+offset, 700)
            love.graphics.draw(relic.image, width-400+offset, 750, 0, relic.scale_factor.x, relic.scale_factor.y, 0, 0)
            love.graphics.print("uses left: " .. PassiveRelics[1].numOfUses - PassiveRelics[1].used_times, width-400+offset, 950)
            love.graphics.setFont(utils.fonts.default)
            offset = offset + 600
        end
    end

    --debugging
    if(main_debug) then
        love.graphics.print("FPS: ".. tostring(love.timer.getFPS()), 10, 10)

        love.graphics.print("player.center.x: " .. tostring(player.center.x), 100, 200)
        love.graphics.print("player.grid_data.center.x: " .. tostring(player.grid_data.center.x), 300, 200)
        love.graphics.print("player.gird_data.center.x px: " .. tostring(player.grid_data.center.x*maze.CellDimensions.x + maze.CellDimensions.x/2 + maze.Offset.x), 300, 260)

        love.graphics.print("player.center.y: " .. tostring(player.center.y), 100, 220)
        love.graphics.print("player.grid_data.center.y: " .. tostring(player.grid_data.center.y), 300, 220)
        love.graphics.print("player.gird_data.center.y px: " .. tostring(player.grid_data.center.y*maze.CellDimensions.y + maze.CellDimensions.y/2 + maze.Offset.y), 300, 280)

        love.graphics.print("player.buffer_direction: " .. tostring(player.buffer_direction), 100, 300)
        love.graphics.print("player.direction: " .. tostring(player.direction), 100, 320)

        love.graphics.print("gameState: " .. gameState, 300, 340)

        love.graphics.print("Wall from center UP: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.up]), 100, 360)
        love.graphics.print("Wall from center DOWN: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.down]), 100, 380)
        love.graphics.print("Wall from center RIGHT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.right]), 100, 400)
        love.graphics.print("Wall from center LEFT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.left]), 100, 420)

        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(timerEnemySpawn)), 100, 460)
        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(timerEnemySpawn)), 100, 460)

        local print_offset = 20
        for _ ,Enemy in ipairs(Enemies) do
            love.graphics.print(tostring(Enemy) .. ":direction -> " .. tostring(Enemy.direction), 100, 480+print_offset)
            print_offset = print_offset + 20
            love.graphics.print(tostring(Enemy) .. ":center -> " .. tostring(Enemy.center.x) .. " " .. tostring(Enemy.center.y), 100, 480+print_offset)
            print_offset = print_offset + 20
        end

        if(#ActiveRelics >= 1) then
            love.graphics.print("relic 1 cooldown: " .. tostring(math.floor(ActiveRelics[1].timerCooldown)) .. "/" .. tostring(math.floor(ActiveRelics[1].cooldown)), 100, 960)
        end
    end
    
    if gameState == "pause" then
        love.graphics.setFont(utils.fonts.pause)
        love.graphics.print("PAUSED", width/2-90, 110)
        love.graphics.setFont(utils.fonts.default)
    elseif gameState == "victory" then
        love.graphics.setFont(utils.fonts.pause)
        love.graphics.print("YOU SENSE SOMETHING FAMILIAR", width/2-275, 115)

        if(#RelicOptions ~= 0) then
            love.graphics.rectangle("fill", width/2-150, height/2-200, 300, 400, 20, 20)
            love.graphics.print({{0,0,0,1}, RelicOptions[1].title}, width/2-95, height/2-170, 0, 0.7, 0.7)
            love.graphics.draw(RelicOptions[1].image, width/2-100, height/2-100, 0 , RelicOptions[1].scale_factor.x, RelicOptions[1].scale_factor.y)
            love.graphics.printf({{0,0,0,1}, RelicOptions[1].description}, width/2-155, height/2+100, 800, "center", 0, 0.4, 0.4)
            love.graphics.setFont(utils.fonts.default)

            ActiveRelics[1] = RelicOptions[1] --Chosen relic from RelicOptions
        end

    elseif gameState == "shop" then
        local shopImage = love.graphics.newImage('assets/shopConceptArt.png')
        shopImage:setFilter("nearest", "nearest")
        love.graphics.draw(shopImage, 0, 0, 0, 8, 8);
    end

end