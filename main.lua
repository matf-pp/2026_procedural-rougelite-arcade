local utils = require("utils")
local maze = require("maze")
local collision = require("collision")
local player = require("player")
local enemy = require("enemy")
local pebble = require("pebble")
local ui_main = require("UI.scripts.ui_main")

local gameState = "menu"
local fullscreen = false

local main_debug = true


local score = 0

local shop = false

--number of cells in maze
utils.Cells.x = 12
utils.Cells.y = 12

function love.load()
    music = love.audio.newSource( 'assets/music/pesma.wav', 'stream' )
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
    timerEnemySpawn = 0
end

local offset = 4; local br = 1;
function love.update(dt)
    if gameState == "menu" then ui_main.update(dt); return end

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

    --na svakih offset sekundi se otvaraju zidovi u kutiji sa donje strane
    timerEnemySpawn = timerEnemySpawn + dt
    if ( (math.floor(timerEnemySpawn) == (offset)) and br~=0) then
        mazeGrid[6][6].walls[utils.Directions.up] = false
        mazeGrid[6][7].walls[utils.Directions.up] = false
        Enemies[br].exitSpawn = true
        offset = offset + 4
        if (br>=utils.numberOfEnemies) then br=0 else br=br+1 end
    end

    for _, Enemy in ipairs(Enemies) do
        if Enemy.exitSpawn == false then --provera da li treba da izadje iz centralne kutije
            if Enemy:isInCenter(dt) then

                --ako je zaglavljen da se odglavi tj odmah promeni smer
                for smer, postojiZid in pairs(mazeGrid[Enemy.grid_data.center.y+1][Enemy.grid_data.center.x+1].walls) do
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
            Enemy:changeDirection(utils.Directions.up)  --manuelno postavljanje smera da izadje iz kutije
            Enemy:move(dt)  --smemo da pozovemo move() i ako nismo prvo proverili isInCenter() jer changeDirection() poziva correctPosition()
            Enemy.exitSpawn = false

        end
        Enemy:move(dt)
            mazeGrid[6][6].walls[utils.Directions.up] = true
            mazeGrid[6][7].walls[utils.Directions.up] = true

        --checking collision with player
        if (gridCollision(Enemy.grid_data.center.x, Enemy.grid_data.center.y, player.grid_data.center.x, player.grid_data.center.y))==true then
            player.alive=false
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

function newLevel()
    maze.load(utils.Cells.x, utils.Cells.y)
    mazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)

    score = 0
    pebble.resetAllPebbles(pebbles)

    player.alive = true
    player.setPlayerPosition()
    player.direction = 0
    player.buffer_direction = 0

    --resetovanje promenljivih za Enemy spawn
    timerEnemySpawn = 0; br = 1; offset = 4

    for i=1, utils.numberOfEnemies do
        Enemies[i]:spawn(i)
    end
end

function changeFullscreen()
    if fullscreen then love.window.setFullscreen(false, "desktop"); fullscreen = false;
    else love.window.setFullscreen(true, "desktop"); fullscreen=true end
end

function love.keypressed( key, scancode, isrepeat )
    if gameState == "menu" then ui_main.keypressed(key, scancode, isrepeat); return end

    if(key == "return") then
        newLevel()
    end

    if(key == "b") then
        if shop then shop = false
        else shop = true end
    end

    player.updateDirection(key)

    if(key == "f") then
        changeFullscreen()
    end

    if(key == "escape") then
        gameState = "menu"
    end

    if(key == "x") then
        player.speed = 0
        for _, Enemy in ipairs(Enemies) do
            Enemy.speed = 0
        end
    end

    if(key == "c") then
        player.speed = utils.playerSpeed
        for _, Enemy in ipairs(Enemies) do
            Enemy.speed = utils.enemySpeed
        end
    end


end

function love.draw()
    if gameState == "menu" then ui_main.draw(); return end

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

        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(timerEnemySpawn)), 100, 460)

        local print_offset = 20
        for index,Enemy in pairs(Enemies) do
            love.graphics.print(tostring(Enemy) .. ":direction -> " .. tostring(Enemy.direction), 100, 480+print_offset)
            print_offset = print_offset + 20
            love.graphics.print(tostring(Enemy) .. ":center -> " .. tostring(Enemy.center.x) .. " " .. tostring(Enemy.center.y), 100, 480+print_offset)
            print_offset = print_offset + 20
        end
    end
    
    --shop prikaz
    if(shop == true) then

        local shopImage = love.graphics.newImage('assets/shopConceptArt.png')
        shopImage:setFilter("nearest", "nearest")
        love.graphics.draw(shopImage, 0, 0, 0, 8, 8);

    end
end