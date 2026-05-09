local maze = require("maze")
local utils = require("utils")

utils.Cells = {
    x = 16,
    y = 16
}

function love.load()
    math.randomseed(os.time())
    love.window.setFullscreen(true, "desktop")
    maze.load(utils.Cells.x, utils.Cells.y)
    MazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    love.graphics.setBackgroundColor(39/256, 39/256, 39/256)
end

function love.draw()
    local width, _ , _ = love.window.getMode()
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.print("Press enter to generate a new maze", width/2 - 110, 100)
    maze.drawMaze(utils.Cells.x, utils.Cells.y, MazeGrid)
end

function love.update()

end

function love.keypressed( key, scancode, isrepeat )
    if(key == "return") then
        math.randomseed(os.time())
        MazeGrid = maze.makeMaze(utils.Cells.x, utils.Cells.y)
    end
end