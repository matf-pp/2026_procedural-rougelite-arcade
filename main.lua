local utils = require("utils")
local maze = require("maze")
local collision = require("collision")
local player = require("player")
local enemy = require("enemy")
local pebble = require("pebble")

local r = 0
local main_debug = true
local new_maze = true

local score = 0

--number of cells in maze
utils.Cells.x = 12
utils.Cells.y = 12

function love.load()

    math.randomseed(os.time())
    love.window.setFullscreen(true, "desktop")
    
    --ucitavanje podataka za utils
    local _, _, flags = love.window.getMode()
    utils.vsync = flags.refreshrate
    utils.enemySpeed = 400
    utils.playerSpeed = 400
    local windowWidth, windowHeight = love.graphics.getDimensions()
    utils.windowWidth = windowWidth; utils.windowHeight=windowHeight

    --generacija mape
    maze.load(utils.Cells.x, utils.Cells.y)
    mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    love.graphics.setBackgroundColor(39/256, 39/256, 39/256)
    --generacija pebble-ova
    pebbles = pebble.initPebbles()

    --ucitavanje igraca
    player.setPlayerPosition()

    --ucitavanje neprijatelja
    Enemies = {}
    for i=1, utils.numberOfEnemies do
        table.insert(Enemies, newEnemy(i))
    end
    EnemyTimerStart = love.timer.getTime()
end

function love.update(dt)
    utils.FPS = love.timer.getFPS()

    --player update logic
    if(player.alive) then
        if( player.isInCenter(dt) ) then
            local localPebble = pebbles[(player.grid_data.center.y)*utils.Cells.x+(player.grid_data.center.x+1)]
            if localPebble.alive then localPebble.alive = false; score = score + 10 end
            
            player.changeDirection()
        end
            player.move(dt, mazeGrid)
    else
        player.speed = 0
    end

        --enemy update logic
    for _,Enemy in ipairs(Enemies) do
        if Enemy:isInCenter(dt) then
            --ako je zaglavljen da se odglavi tj odmah promeni smer
            for smer, postojiZid in pairs(mazeGrid[Enemy.grid_data.center.y+1][Enemy.grid_data.center.x+1].walls) do
                if postojiZid and Enemy.direction == smer then
                    Enemy:changeDirection()
                end
            end

            --u suprotnom redovno proverava da li da promeni smer ili ne
            EnemyTimerCheck = love.timer.getTime()
            --if( math.floor(EnemyTimerCheck-EnemyTimerStart)>=1) then
                if(math.random(1,4)==2) then
                    Enemy:changeDirection()
                end
                EnemyTimerStart = EnemyTimerCheck
                EnemyTimerCheck = love.timer.getTime()
            --end
        end
        Enemy:move(dt)

        --checking collision with player
        if (gridCollision(Enemy.grid_data.center.x, Enemy.grid_data.center.y, player.grid_data.center.x, player.grid_data.center.y))==true then
            player.alive=false
        end
    end

end

function love.keypressed( key, scancode, isrepeat )
    if(key == "return") then
        utils.Cells.x = utils.Cells.x + r
        utils.Cells.y = utils.Cells.y + r
        maze.load(utils.Cells.x, utils.Cells.y)
        mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)

        score = 0
        pebble.resetAllPebbles(pebbles)

        player.alive = true
        player.setPlayerPosition()
        player.direction = 0
        player.buffer_direction = 0

        --ovo ispod treba izmeniti samo je brzi kod za testiranje
        freeSpawns()
        for i=1, utils.numberOfEnemies do
            Enemies[i]:spawn(i)
        end
    end

    player.updateDirection(key)

    if(key == "f") then
        love.window.setFullscreen(false, "desktop")
    end

    if(key == "escape") then
        love.event.push("quit", 0)
    end

    if(key == "x") then
        player.speed = 0
        for index, Enemy in ipairs(Enemies) do
            Enemy.speed = 0
        end
    end

    if(key == "c") then
        player.speed = utils.playerSpeed
        for index, Enemy in ipairs(Enemies) do
            Enemy.speed = utils.enemySpeed
        end
    end


end

function love.draw()
    --crtanje lavirinta
    --TODO: CANVAS optimizacija
    maze.drawMaze(utils.Cells.x, utils.Cells.y, mazeGrid)
    local width, _ , _ = love.window.getMode()
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.print("Press enter to generate a new maze", width/2 - 110, 10)

    pebble.drawPebbles(pebbles)
    love.graphics.print("Score: " .. score, width/2 - 50, 100)

    --crtanje igraca
    if(player.alive) then
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.draw(player.image, player.x, player.y, 0, player.scale_factor.x, player.scale_factor.y, 0, 0)
    else
        love.graphics.print("Player collision with Enemy ", 100, 760)
    end

    --crtanje neprijatelja
    for k,v in pairs(Enemies) do
        love.graphics.draw(v.image, v.x, v.y, 0, v.scale_factor.x, v.scale_factor.y, 0, 0)
    end

    --debugging
    if(main_debug) then
        love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)

        love.graphics.print("player.center.x: " .. tostring(player.center.x), 100, 200)
        love.graphics.print("player.grid_data.center.x: " .. tostring(player.grid_data.center.x), 300, 200)
        love.graphics.print("player.gird_data.center.x px: " .. tostring(player.grid_data.center.x*maze.CellDimensions.x + maze.CellDimensions.x/2 + maze.Offset.x), 300, 260)

        love.graphics.print("player.center.y: " .. tostring(player.center.y), 100, 220)
        love.graphics.print("player.grid_data.center.y: " .. tostring(player.grid_data.center.y), 300, 220)
        love.graphics.print("player.gird_data.center.y px: " .. tostring(player.grid_data.center.y*maze.CellDimensions.y + maze.CellDimensions.y/2 + maze.Offset.y), 300, 280)

        love.graphics.print("player.buffer_direction: " .. tostring(player.buffer_direction), 100, 300)
        love.graphics.print("player.direction: " .. tostring(player.direction), 100, 320)

        love.graphics.print("Wall from center UP: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.up]), 100, 360)
        love.graphics.print("Wall from center DOWN: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.down]), 100, 380)
        love.graphics.print("Wall from center RIGHT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.right]), 100, 400)
        love.graphics.print("Wall from center LEFT: " .. tostring(mazeGrid[player.grid_data.center.y+1][player.grid_data.center.x+1].walls[utils.Directions.left]), 100, 420)

        love.graphics.print("EnemyTimerStart: " .. tostring(EnemyTimerStart), 100, 460)

        local print_offset = 20
        for index,Enemy in pairs(Enemies) do
            love.graphics.print(tostring(Enemy) .. ":direction -> " .. tostring(Enemy.direction), 100, 480+print_offset)
            print_offset = print_offset + 20
            love.graphics.print(tostring(Enemy) .. ":center -> " .. tostring(Enemy.center.x) .. " " .. tostring(Enemy.center.y), 100, 480+print_offset)
            print_offset = print_offset + 20
        end
    end
end