local utils      =  require("utils")
local maze       =  require("maze")
local player     =  require("player")
local Enemy      =  require("enemy")
local ghost      =  require("ghost")
local relics     =  require("relics")
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
local music      =  require("music")
local postProcessing = require("UI.scripts.processing.post_processing")
local stateManager = require("state_manager")
local levelManager = require("level_manager")

local fullscreen = false
local pauseBgCanvas

local mazeCanvas
local makeMazeCanvas = true
local backgroundCanvas
local makeBackgroundCanvas = true
local main_debug = false

local pauseReturnState = "playing"

local scoreInfo = {pebblesEaten = 0, score = 0}

local RelicOptions = {}
local RelicManager = relics.RelicManager

local function getActiveRelics()
    return RelicManager:getActiveRelicList()
end

local function getPassiveRelics()
    return RelicManager:getPassiveRelicList() or {}
end

local menuState = {}
local lobbyState = {}
local playingState = {}
local pauseState = {}
local victoryState = {}
local shopState = {}

--number of cells in maze
utils.Cells.x = 6
utils.Cells.y = 6

function love.load()
    utils.fonts.default = love.graphics.newFont("assets/fonts/creato_display/CreatoDisplay-Medium.otf")
    utils.fonts.pause = love.graphics.newFont("assets/fonts/absender/absender1.ttf", 40)

    soundFX.load()
    music.load()

    love.graphics.setFont(utils.fonts.default)
    
    math.randomseed(os.time())
    love.window.setFullscreen(true, "desktop")
    fullscreen = true
    postProcessing.load()

    --ucitavanje podataka za utils
    local _, _, flags = love.window.getMode()
    utils.vsync = flags.refreshrate
    utils.enemySpeed = 220
    utils.basePlayerSpeed = 210
    utils.playerSpeed = utils.basePlayerSpeed
    local windowWidth, windowHeight, _ = love.window.getMode()
    utils.windowWidth = windowWidth; utils.windowHeight = windowHeight
    
    pauseBgCanvas = love.graphics.newCanvas()
    ui_main.load(function() startTransition("fade", function() stateManager.changeState("lobby") end) end)
    lobby.load(function() soundFX.iris(); startTransition("iris", function() music.menuMusic:stop(); music.ingameMusic:play(); stateManager.changeState("playing");  lobby.setPlayerStartingPosition() end) end,
               function() soundFX.iris(); startTransition("iris", function() stateManager.changeState("shop");  lobby.setPlayerStartingPosition() end) end,
               function() starshine.show("Door does not open from this side") end
              )
    pause_menu.load(
        function()
            player.speed = utils.playerSpeed
            Enemy.unpauseAll()
            stateManager.changeState(pauseReturnState)
        end,
        function()
            player.speed = utils.playerSpeed
            Enemy.unpauseAll()
            soundFX.iris();
            startTransition("iris", function() music.ingameMusic:stop(); music.menuMusic:play() ; stateManager.changeState("menu") end)
        end
    )


    --generacija mape
    mazeGrid, pebbles, numOfPebbles = levelManager.prepareLevel(0)

    relics_hud.load()

    --ucitavanje igraca
    player.loadAnimation()

    numOfPebbles = #pebbles - 2
    stateManager.changeState("menu")
end

function pause()
    player.speed=0
    Enemy.pauseAll()
end

function unpause()
    player.speed = utils.playerSpeed
    Enemy.unpauseAll()
end

function newLevel()
    scoreInfo.score = player.score
    mazeGrid, pebbles, numOfPebbles = levelManager.nextLevel()
    scoreInfo.pebblesEaten = 0

    --resetovanje relic timera
    for _, relic in ipairs(getActiveRelics()) do
        relic.reset()
    end

    makeMazeCanvas = true
    unpause()
    stateManager.changeState("playing")
end

function changeFullscreen()
    if fullscreen then love.window.setFullscreen(false, "desktop"); fullscreen=false;
    else love.window.setFullscreen(true, "desktop"); fullscreen=true end
end

function love.update(dt)
    utils.FPS = love.timer.getFPS()
    postProcessing.update(dt)

    player.changeState(stateManager.getCurrentName() or "menu")

    for _, relic in ipairs(getActiveRelics()) do
        relic.update(dt)
    end

    stateManager.update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
    stateManager.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    stateManager.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    stateManager.mousemoved(x, y, dx, dy, istouch)
end

function love.keypressed(key, scancode, isrepeat)
    stateManager.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    stateManager.keyreleased(key, scancode, isrepeat)
end

local function drawPlayingScene()
    local width = utils.windowWidth; local height = utils.windowHeight
    if makeMazeCanvas then
        mazeCanvas = maze.drawMaze(utils.Cells.y, utils.Cells.x, mazeGrid)
        makeMazeCanvas = false
    end

    if makeBackgroundCanvas then
        backgroundCanvas = love.graphics.newCanvas()
        local prev = love.graphics.getCanvas()
        love.graphics.setCanvas(backgroundCanvas)
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
        local backgroundImage = love.graphics.newImage("assets/background.png")
        backgroundImage:setFilter("nearest", "nearest")
        love.graphics.draw(backgroundImage, 0, 0, 0, 2, 2)
        love.graphics.setCanvas(prev)
        makeBackgroundCanvas = false
    end

    love.graphics.draw(backgroundCanvas, 0, 0)
    love.graphics.draw(mazeCanvas, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Press enter to generate a new maze", width / 2 - 110, 10)
    pebble.drawPebbles(pebbles)
    love.graphics.print("Score: " .. scoreInfo.score, width / 2 - 50, 100)
    player.draw()
    Enemy.drawAll()
    ghost.drawAll()
    relics_hud.draw(getActiveRelics(), getPassiveRelics())

    if main_debug then
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
        love.graphics.print("player.x: " .. tostring(player.x), 100, 200)
        love.graphics.print("player.grid_data.center.x: " .. tostring(player.grid_data.center.x), 300, 200)
        love.graphics.print("player.gird_data.center.x px: " .. tostring(player.grid_data.center.x * maze.CellDimensions.x + maze.CellDimensions.x / 2 + maze.Offset.x), 300, 260)
        love.graphics.print("player.y: " .. tostring(player.y), 100, 220)
        love.graphics.print("player.grid_data.center.y: " .. tostring(player.grid_data.center.y), 300, 220)
        love.graphics.print("player.gird_data.center.y px: " .. tostring(player.grid_data.center.y * maze.CellDimensions.y + maze.CellDimensions.y / 2 + maze.Offset.y), 300, 280)
        love.graphics.print("player.buffer_direction: " .. tostring(player.buffer_direction), 100, 300)
        love.graphics.print("player.direction: " .. tostring(player.direction), 100, 320)
        love.graphics.print("timerEnemySpawn: " .. tostring(math.floor(Enemy.timerEnemySpawn)), 100, 460)
        local print_offset = 20
        for _, e in ipairs(Enemy.list) do
            love.graphics.print(tostring(e) .. ":direction -> " .. tostring(e.direction), 100, 480 + print_offset)
            print_offset = print_offset + 20
            love.graphics.print(tostring(e) .. ":pos -> " .. tostring(e.x) .. " " .. tostring(e.y), 100, 480 + print_offset)
            print_offset = print_offset + 20
        end
        local debugActive = getActiveRelics()
        if #debugActive >= 1 then
            love.graphics.print("relic 1 cooldown: " .. tostring(math.floor(debugActive[1].timerCooldown)) .. "/" .. tostring(math.floor(debugActive[1].cooldown)), 100, 960)
            if #debugActive >= 2 then
                love.graphics.print("relic 2 cooldown: " .. tostring(math.floor(debugActive[2].timerCooldown)) .. "/" .. tostring(math.floor(debugActive[2].cooldown)), 100, 980)
            end
        end
    end
end

local function drawVictoryScene()
    local width = utils.windowWidth; local height = utils.windowHeight
    love.graphics.setFont(utils.fonts.pause)
    love.graphics.print("YOU SENSE SOMETHING FAMILIAR", width / 2 - 275, 115)
    love.graphics.setFont(utils.fonts.default)
    love.graphics.print("Choose a relic with 1, 2 or 3:", width / 2 - 170, 200)

    for i, relic in ipairs(RelicOptions) do
        local title = relic.title or relic.name or "Unknown relic"
        local description = relic.description or ""
        love.graphics.print(string.format("%d) %s", i, title), width / 2 - 175, 230 + (i - 1) * 30)
        love.graphics.print(description, width / 2 - 175, 250 + (i - 1) * 30)
    end
end

local function drawShopScene()
    local shopImage = love.graphics.newImage('assets/shopConceptArt.png')
    shopImage:setFilter("nearest", "nearest")
    love.graphics.draw(shopImage, 0, 0, 0, 8, 8)
end

menuState = {
    update = ui_main.update,
    draw = ui_main.draw,
    keypressed = ui_main.keypressed,
    mousepressed = ui_main.mousepressed,
    mousereleased = ui_main.mousereleased,
    mousemoved = ui_main.mousemoved,
}

lobbyState = {
    update = lobby.update,
    draw = lobby.draw,
    keypressed = lobby.keypressed,
    keyreleased = lobby.keyreleased,
}

playingState = {
    update = function(dt)
        if scoreInfo.pebblesEaten >= numOfPebbles then
            stateManager.changeState("victory")
            return
        end
        player.update(dt)
        pebble.update(pebbles, player, scoreInfo, dt)
        Enemy.updateAll(dt, mazeGrid, player)
        ghost.updateAll(dt)
    end,
    draw = drawPlayingScene,
    keypressed = function(key, scancode, isrepeat)
        if key == "escape" then
            pauseReturnState = "playing"
            stateManager.changeState("pause", { returnState = "playing" })
            return
        end
        if key == "return" then
            newLevel()
            return
        end
        if key == "j" then
            local relic = RelicManager:getActiveRelic("j")
            if relic and relic.canUse and relic.canUse() then
                relic.use()
            end
            return
        end
        if key == "k" then
            local relic = RelicManager:getActiveRelic("k")
            if relic and relic.canUse and relic.canUse() then
                relic.use()
            end
            return
        end
        if key == "l" then
            local relic = RelicManager:getActiveRelic("l")
            if relic and relic.canUse and relic.canUse() then
                relic.use()
            end
            return
        end
        if key == "f" then
            changeFullscreen()
            return
        end
        if key == "v" then
            scoreInfo.pebblesEaten = numOfPebbles
            return
        end
        player.updateDirection(key)
    end,
}

pauseState = {
    enter = function(params)
        pauseReturnState = params and params.returnState or "playing"
        pause()
    end,
    update = pause_menu.update,
    draw = function()
        local prev = love.graphics.getCanvas()
        love.graphics.setCanvas(pauseBgCanvas)
        love.graphics.clear(0, 0, 0, 1)
        if stateManager.getPreviousName() == "lobby" then
            lobby.draw()
        elseif stateManager.previousState and stateManager.previousState.draw then
            stateManager.previousState.draw()
        end
        love.graphics.setCanvas(prev)
        pause_menu.draw(pauseBgCanvas)
    end,
    keypressed = pause_menu.keypressed,
    mousepressed = pause_menu.mousepressed,
    mousemoved = pause_menu.mousemoved,
}

victoryState = {
    enter = function()
        RelicOptions = RelicManager:getRandomRelicOptions(3)
        player.score = player.score + scoreInfo.score
        scoreInfo.score = 0
    end,
    update = function(dt) end,
    draw = drawVictoryScene,
    keypressed = function(key, scancode, isrepeat)
        if key == "return" then
            newLevel()
            return
        end

        local choice = tonumber(key)
        if choice and RelicOptions[choice] then
            RelicManager:addRelic(RelicOptions[choice])
            RelicOptions = {}
            newLevel()
            return
        end
    end,
}

shopState = {
    update = function(dt) end,
    draw = drawShopScene,
    keypressed = function(key, scancode, isrepeat)
        if key == "escape" then
            stateManager.changeState("lobby")
        end
    end,
}

stateManager.register("menu", menuState)
stateManager.register("lobby", lobbyState)
stateManager.register("playing", playingState)
stateManager.register("pause", pauseState)
stateManager.register("victory", victoryState)
stateManager.register("shop", shopState)

function love.draw()
    postProcessing.draw(function()
        stateManager.draw()
    end)
    if ui_main.getShowFps then
        if ui_main.getShowFps() then
            love.graphics.setColor(1,1,1,1)
            love.graphics.setFont(utils.fonts.default)
            love.graphics.print(utils.FPS, 20, 20)
        end
    end
end