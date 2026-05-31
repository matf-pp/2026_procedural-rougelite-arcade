local utils      =  require("utils")
local maze       =  require("maze")
local collision  =  require("collision")
local player     =  require("player")
local Enemy      =  require("enemy")
local ghost      =  require("ghost")
                    require("relics")
local pebble     =  require("pebble")
local ui_main    =  require("UI.scripts.ui_main")
local animations =  require("animations")
local lobby      =  require("lobby")
local moonshine  =  require("moonshine")
local sunshine   =  require("sunshine")
local starshine  =  require("starshine")
local pause_menu =  require("UI.scripts.pause_menu")
local relics_hud =  require("UI.scripts.relics_hud")
local soundFX    =  require("soundFX")

local gameState = "menu"
local fullscreen = false
local prevGameState = "playing"
local pauseBgCanvas

local mazeCanvas
local makeMazeCanvas = true
local backgroundCanvas
local makeBackgroundCanvas = true
local main_debug = false

local scoreInfo = {pebblesEaten = 0, score = 0}

local RelicOptions = {}
local ActiveRelics = {}
local PassiveRelics = {}
local Ghost

local level = 0

--number of cells in maze
utils.Cells.x = 12
utils.Cells.y = 12

function love.load()
    utils.fonts.default = love.graphics.newFont("assets/fonts/creato_display/CreatoDisplay-Medium.otf")
    utils.fonts.pause = love.graphics.newFont("assets/fonts/absender/absender1.ttf", 40)

    soundFX.load()

    love.graphics.setFont(utils.fonts.default)

    ingameMusic = love.audio.newSource('assets/music/pesma.wav', 'stream')
    menuMusic = love.audio.newSource('assets/music/menulobby.wav', 'stream')
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.2)
    menuMusic:play()

    ingameMusic:setLooping(true)
    ingameMusic:setVolume(0.15)
    
    math.randomseed(os.time())
    love.window.setFullscreen(true, "desktop")
    fullscreen = true
    
    --ucitavanje podataka za utils
    local _, _, flags = love.window.getMode()
    utils.vsync = flags.refreshrate
    utils.enemySpeed = 220
    utils.basePlayerSpeed = 210
    utils.playerSpeed = utils.basePlayerSpeed
    local windowWidth, windowHeight, _ = love.window.getMode()
    utils.windowWidth = windowWidth; utils.windowHeight = windowHeight
    
    pauseBgCanvas = love.graphics.newCanvas()
    ui_main.load(function() startTransition("fade", function() gameState = "lobby" end) end)
    lobby.load(function() soundFX.iris(); startTransition("iris", function() menuMusic:stop(); ingameMusic:play(); gameState = "playing";  lobby.setPlayerStartingPosition() end) end,
               function() soundFX.iris(); startTransition("iris", function() gameState = "shop";  lobby.setPlayerStartingPosition() end) end,
               function() starshine.show("door opens from the other side") end
              )
    pause_menu.load(
        function()
            player.speed = utils.playerSpeed
            Enemy.unpauseAll()
            gameState = prevGameState
        end,
        function()
            player.speed = utils.playerSpeed
            Enemy.unpauseAll()
            soundFX.iris();
            startTransition("iris", function() ingameMusic:stop(); menuMusic:play() ; gameState = "menu" end)
        end
    )


    --generacija mape
    maze.load(utils.Cells.x, utils.Cells.y)
    mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    --generacija pebble-ova
    pebbles = pebble.initPebbles()

    relics_hud.load()

    --ucitavanje igraca
    player.setPlayerPosition()
    player.loadAnimation()

    --ucitavanje neprijatelja
    Enemy.spawnAll(utils.numberOfEnemies)
    numOfPebbles = #pebbles - 2

    Ghost = ghost.newGhost(utils.windowWidth/2, utils.windowHeight/2)
end

function pause()
    player.speed=0
    Enemy.pauseAll()
end

function unpause()
    player.speed = utils.playerSpeed
    Enemy.unpauseAll()
    gameState = "playing"
end

function newLevel()
    scoreInfo.score = player.score
    if level == 1 then
        utils.Cells.x = 14
        utils.Cells.y = 14
        utils.numberOfEnemies = 6
    elseif level == 2 then
        utils.Cells.x = 16
        utils.Cells.y = 14
        utils.numberOfEnemies = 10
    end

    maze.load(utils.Cells.y, utils.Cells.x)
    mazeGrid = maze.makeMaze(utils.Cells.y, utils.Cells.x)
    
    pebbles = pebble.initPebbles()
    pebble.resetAllPebbles(pebbles)
    numOfPebbles = #pebbles - 2
    scoreInfo.pebblesEaten = 0

    player.alive = true
    player.setPlayerPosition()
    player.direction = 0
    player.buffer_direction = 0

    --resetovanje neprijatelja
    Enemy.spawnAll(utils.numberOfEnemies)

    Ghost = ghost.newGhost(utils.windowWidth/2, utils.windowHeight/2)

    --resetovanje relic timera
    for _, relic in ipairs(ActiveRelics) do
        relic.reset()
    end

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
    elseif gameState == "lobby" then lobby.update(dt); return
    elseif gameState == "pause" then
        pause()
        pause_menu.update(dt)
    elseif gameState == "victory" then
        pause()
        if(#RelicOptions == 0) then
            RelicOptions[1] = newDashRelic()
            RelicOptions[2] = newJumpRelic()
            RelicOptions[3] = newEnemyFreezeRelic()
            RelicOptions[4] = newBaseSpeedPassive()
            RelicOptions[5] = newCooldownReductionPassive()
            --RelicOptions[6] = newMagnetPassive()
        end
        player.score = player.score + scoreInfo.score
    else
        if scoreInfo.pebblesEaten >= numOfPebbles then
            gameState = "victory"
            level = level + 1
        end

        --player update logic
        player.update(dt)
        pebble.update(pebbles, player, scoreInfo)

        --enemy update logic
        Enemy.updateAll(dt, mazeGrid, player)

        Ghost:update(dt)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "menu" then ui_main.mousepressed(x, y, button, istouch, presses)
    elseif gameState == "pause" then pause_menu.mousepressed(x, y, button, istouch, presses) end
end

function love.mousereleased(x, y, button, istouch, presses)
    if gameState == "menu" then ui_main.mousereleased(x, y, button, istouch, presses) end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if gameState == "menu" then ui_main.mousemoved(x, y, dx, dy, istouch)
    elseif gameState == "pause" then pause_menu.mousemoved(x, y, dx, dy, istouch) end
end

function love.keypressed( key, scancode, isrepeat )
    if key == "escape" then
        if gameState == "playing" then
            prevGameState = "playing"
            gameState = "pause"
        elseif gameState == "lobby" then
            prevGameState = "lobby"
            gameState = "pause"
        elseif gameState == "shop" then
            soundFX.iris();
            startTransition("iris", function() gameState = "lobby" end)
        elseif gameState == "pause" then
            pause_menu.keypressed(key, scancode, isrepeat)
        end
        return
    end

    if gameState == "menu" then ui_main.keypressed(key, scancode, isrepeat); return end
    if gameState == "lobby" then lobby.keypressed(key, scancode, isrepeat); return end
    if gameState == "pause" then pause_menu.keypressed(key, scancode, isrepeat); return end

    player.updateDirection(key)

    if(key == "return") then
        newLevel()
    end
        
    if(key == "j" and #ActiveRelics>=1) then
        if(ActiveRelics[1].canUse()) then
            ActiveRelics[1].use()
        end
    end

    if(key == "k" and #ActiveRelics>=2) then
        if(ActiveRelics[2].canUse()) then
            ActiveRelics[2].use()
        end
    end

    if(key == "l" and #ActiveRelics>=3) then
        if(ActiveRelics[3].canUse()) then
            ActiveRelics[3].use()
        end
    end


    if(key == "f") then
        changeFullscreen()
    end

    if(key == "m") then
        music:setVolume(0.0)
    end

    if(key == "v") then
        scoreInfo.pebblesEaten = numOfPebbles
    end
end

function love.keyreleased(key, scancode, isrepeat)
    if gameState == "lobby" then lobby.keyreleased(key, scancode, isrepeat); return end
end

function love.draw()
    local width = utils.windowWidth; local height = utils.windowHeight
    if gameState == "menu" then ui_main.draw(); return end
    if gameState == "lobby" then lobby.draw(); return end

    if gameState == "pause" then
        love.graphics.setCanvas(pauseBgCanvas)
        love.graphics.clear(0, 0, 0, 1)
        if prevGameState == "lobby" then
            lobby.draw()
        else
            love.graphics.draw(backgroundCanvas, 0, 0)
            love.graphics.draw(mazeCanvas, 0, 0)
            pebble.drawPebbles(pebbles)
            player.draw()
            Enemy.drawAll()
            relics_hud.draw(ActiveRelics, PassiveRelics)
        end
        love.graphics.setCanvas()
        pause_menu.draw(pauseBgCanvas)
        return
    end
    
    --crtanje lavirinta
    if(makeMazeCanvas) then
        mazeCanvas = maze.drawMaze(utils.Cells.x, utils.Cells.y, mazeGrid)

        makeMazeCanvas = false
    end

    if makeBackgroundCanvas then
        backgroundCanvas = love.graphics.newCanvas()
        love.graphics.setCanvas(backgroundCanvas)
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
        local backgroundImage = love.graphics.newImage("assets/background.png")
        backgroundImage:setFilter("nearest", "nearest")
        love.graphics.draw(backgroundImage, 0, 0, 0, 2, 2)

        love.graphics.setCanvas()

        makeBackgroundCanvas = false
    end


    love.graphics.draw(backgroundCanvas, 0, 0)

    love.graphics.draw(mazeCanvas, 0 , 0)

    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.print("Press enter to generate a new maze", width/2 - 110, 10)

    --crtanje pebblova
    pebble.drawPebbles(pebbles)
    love.graphics.print("Score: " .. scoreInfo.score, width/2 - 50, 100)

    --crtanje igraca
    player.draw()

    --crtanje neprijatelja
    Enemy.drawAll()

    --crtanje duha
    Ghost:draw()

    relics_hud.draw(ActiveRelics, PassiveRelics)


    --debugging
    if(main_debug) then
        love.graphics.print("FPS: ".. tostring(love.timer.getFPS()), 10, 10)

        love.graphics.print("player.x: " .. tostring(player.x), 100, 200)
        love.graphics.print("player.grid_data.center.x: " .. tostring(player.grid_data.center.x), 300, 200)
        love.graphics.print("player.gird_data.center.x px: " .. tostring(player.grid_data.center.x*maze.CellDimensions.x + maze.CellDimensions.x/2 + maze.Offset.x), 300, 260)

        love.graphics.print("player.y: " .. tostring(player.y), 100, 220)
        love.graphics.print("player.grid_data.center.y: " .. tostring(player.grid_data.center.y), 300, 220)
        love.graphics.print("player.gird_data.center.y px: " .. tostring(player.grid_data.center.y*maze.CellDimensions.y + maze.CellDimensions.y/2 + maze.Offset.y), 300, 280)

        love.graphics.print("player.buffer_direction: " .. tostring(player.buffer_direction), 100, 300)
        love.graphics.print("player.direction: " .. tostring(player.direction), 100, 320)

        love.graphics.print("gameState: " .. gameState, 300, 340)

        love.graphics.print("Wall from center UP: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.up]), 100, 360)
        love.graphics.print("Wall from center DOWN: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.down]), 100, 380)
        love.graphics.print("Wall from center RIGHT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.right]), 100, 400)
        love.graphics.print("Wall from center LEFT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.left]), 100, 420)

        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(Enemy.timerEnemySpawn)), 100, 460)
        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(Enemy.timerEnemySpawn)), 100, 460)

        local print_offset = 20
        for _, e in ipairs(Enemy.list) do
            love.graphics.print(tostring(e) .. ":direction -> " .. tostring(e.direction), 100, 480+print_offset)
            print_offset = print_offset + 20
            love.graphics.print(tostring(e) .. ":pos -> " .. tostring(e.x) .. " " .. tostring(e.y), 100, 480+print_offset)
            print_offset = print_offset + 20
        end

        if(#ActiveRelics >= 1) then
            love.graphics.print("relic 1 cooldown: " .. tostring(math.floor(ActiveRelics[1].timerCooldown)) .. "/" .. tostring(math.floor(ActiveRelics[1].cooldown)), 100, 960)
            love.graphics.print("relic 2 cooldown: " .. tostring(math.floor(ActiveRelics[2].timerCooldown)) .. "/" .. tostring(math.floor(ActiveRelics[2].cooldown)), 100, 980)
        end
    end
    
    if gameState == "victory" then
        love.graphics.setFont(utils.fonts.pause)
        love.graphics.print("YOU SENSE SOMETHING FAMILIAR", width/2-275, 115)

        if(#RelicOptions ~= 0) then
            love.graphics.rectangle("fill", width/2-150, height/2-200, 300, 400, 20, 20)
            love.graphics.print({{0,0,0,1}, RelicOptions[1].title}, width/2-95, height/2-170, 0, 0.7, 0.7)
            love.graphics.draw(RelicOptions[1].image, width/2-100, height/2-100, 0 , RelicOptions[1].scale_factor.x, RelicOptions[1].scale_factor.y)
            love.graphics.printf({{0,0,0,1}, RelicOptions[1].description}, width/2-155, height/2+100, 800, "center", 0, 0.4, 0.4)
            love.graphics.setFont(utils.fonts.default)

            ActiveRelics[1] = RelicOptions[1] --Chosen relic from RelicOptions
            ActiveRelics[2] = RelicOptions[2]
            ActiveRelics[3] = RelicOptions[3]
            PassiveRelics[1] = RelicOptions[4]
            PassiveRelics[1].use()
            PassiveRelics[2] = RelicOptions[5]
            PassiveRelics[2].use(ActiveRelics)
            --PassiveRelics[3] = RelicOptions[6]
            --PassiveRelics[3].use()
        end

    elseif gameState == "shop" then
        local shopImage = love.graphics.newImage('assets/shopConceptArt.png')
        shopImage:setFilter("nearest", "nearest")
        love.graphics.draw(shopImage, 0, 0, 0, 8, 8);
    end

end