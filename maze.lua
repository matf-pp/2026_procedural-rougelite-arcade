local utils = require("utils")

local Maze = {
    rows = 0,
    cols = 0
}
local maze_debug = true

local cellQuads
local textureSheet
local tileW
local cellSize

function Maze.load(rows, cols)
    local width = utils.windowWidth; local height = utils.windowHeight

    textureSheet = love.graphics.newImage("assets/wall-sheet.png")
    textureSheet:setFilter("nearest", "nearest")

    local sheetW, sheetH = textureSheet:getDimensions()
    tileW = sheetW / 5
    cellSize = math.floor(64 / tileW + 0.5) * tileW

    Maze.CellDimensions = { x = cellSize, y = cellSize }
    Maze.WallWidth = 5
    Maze.Offset = {
        x = width/2 - cols/2 * Maze.CellDimensions.x,
        y = height/2 - rows/2 * Maze.CellDimensions.y
    }

    utils.CellDimensions = { x = cellSize, y = cellSize }
    utils.WallWidth = 5
    utils.Offset = {
        x = width/2 - cols/2 * Maze.CellDimensions.x,
        y = height/2 - rows/2 * Maze.CellDimensions.y
    }

    local tileH = sheetH
    cellQuads = {}
    cellQuads.straight     = love.graphics.newQuad(0 * tileW, 0, tileW, tileH, textureSheet)
    cellQuads.corner       = love.graphics.newQuad(1 * tileW, 0, tileW, tileH, textureSheet)
    cellQuads.threeway     = love.graphics.newQuad(2 * tileW, 0, tileW, tileH, textureSheet)
    cellQuads.intersection = love.graphics.newQuad(3 * tileW, 0, tileW, tileH, textureSheet)
    cellQuads.deadend      = love.graphics.newQuad(4 * tileW, 0, tileW, tileH, textureSheet)
end

function OppositeDir(dir)
    if dir == utils.Directions.up then 
        return utils.Directions.down  
    end
    if dir == utils.Directions.down then 
        return utils.Directions.up    
    end
    if dir == utils.Directions.left then 
        return utils.Directions.right 
    end
    if dir == utils.Directions.right then 
        return utils.Directions.left  
    end
end

function Maze.makeMaze(rows, cols)
    local maze = {}

    -- Maze init 
    for i = 1, rows do
        maze[i] = {}
        for j = 1, cols do
            maze[i][j] = {}
            maze[i][j].visited = false
            maze[i][j].walls = {}
            maze[i][j].walls[utils.Directions.up] = true
            maze[i][j].walls[utils.Directions.right] = true
            maze[i][j].walls[utils.Directions.down] = true
            maze[i][j].walls[utils.Directions.left] = true
            maze[i][j].y = (i-1) * Maze.CellDimensions.y
            maze[i][j].x = (j-1) * Maze.CellDimensions.x
        end
    end

    --MakeCenter(rows, cols, maze)
    CarvePassages(1, 1, rows, cols, maze)
    RemoveDeadEnds(rows, cols, maze)
    BreakLongWalls(rows, cols, maze, 3)
    MakeCenter(rows, cols, maze)

    Maze.rows=rows
    Maze.cols=cols
    return maze
end

function MakeHollowZone(x, y, width, height, maze)
    for i = y, height + y - 1 do
        for j = x, width + x - 1 do
            maze[i][j].visited = true
            maze[i][j].walls[utils.Directions.up]    = false
            maze[i][j].walls[utils.Directions.down]  = false
            maze[i][j].walls[utils.Directions.left]  = false
            maze[i][j].walls[utils.Directions.right] = false
        end
    end
    for i = y, height + y - 1 do
        maze[i][x].walls[utils.Directions.left] = true
        maze[i][x-1].walls[utils.Directions.right] = true
        maze[i][x-1].walls[utils.Directions.up] = false
        maze[i][x-1].walls[utils.Directions.down] = false
        maze[i][width+x-1].walls[utils.Directions.right] = true
        maze[i][width+x].walls[utils.Directions.left] = true
        maze[i][width+x].walls[utils.Directions.up] = false
        maze[i][width+x].walls[utils.Directions.down] = false
    end
    for j = x, width + x - 1 do
        maze[y][j].walls[utils.Directions.up] = true
        maze[y-1][j].walls[utils.Directions.down] = true
        maze[y-1][j].walls[utils.Directions.left] = false
        maze[y-1][j].walls[utils.Directions.right] = false
        maze[height+y-1][j].walls[utils.Directions.down] = true
        maze[height+y][j].walls[utils.Directions.up] = true
        maze[height+y][j].walls[utils.Directions.left] = false
        maze[height+y][j].walls[utils.Directions.right] = false
    end
    maze[y-1][x-1].walls[utils.Directions.right] = false
    maze[y-1][x-1].walls[utils.Directions.down] = false
    maze[y-1][width+x].walls[utils.Directions.left] = false
    maze[y-1][width+x].walls[utils.Directions.down] = false
    maze[height+y][x-1].walls[utils.Directions.right] = false
    maze[height+y][x-1].walls[utils.Directions.up] = false
    maze[height+y][width+x].walls[utils.Directions.up] = false
    maze[height+y][width+x].walls[utils.Directions.left] = false
end

function MakeCenter(rows, cols, maze)
    --[[local width = math.floor(cols * 3 / 8)
    local height = math.floor(rows / 4)
    local x = math.floor((cols - width) / 2) + 1      old bigger box
    local y = math.floor((rows - height) / 2) + 1
    MakeHollowZone(x, y, width, height, maze)]]

    local x = cols / 2;
    local y = rows / 2;
    MakeHollowZone(x, y, 2, 1, maze)
end

function CarvePassages(x, y, rows, cols, maze)
    maze[y][x].visited = true

    local direction = GetUnvisitedNeighbour(x, y, rows, cols, maze)
    while (direction ~= 0) do
        local nx = x
        local ny = y
        if(direction == utils.Directions.up) then 
            ny = ny - 1
        end
        if(direction == utils.Directions.down) then 
            ny = ny + 1
        end
        if(direction == utils.Directions.right) then 
            nx = nx + 1
        end
        if(direction == utils.Directions.left) then 
            nx = nx - 1
        end
        maze[y][x].walls[direction] = false
        maze[ny][nx].walls[OppositeDir(direction)] = false
        CarvePassages(nx, ny, rows, cols, maze)
        direction = GetUnvisitedNeighbour(x, y, rows, cols, maze)
    end
end

function GetUnvisitedNeighbour(x, y, rows, cols, maze)
    local neighbours = {}
    if(x + 1 <= cols and maze[y][x + 1].visited == false) then
        table.insert(neighbours, utils.Directions.right)
    end
    if(x - 1 > 0 and maze[y][x - 1].visited == false) then
        table.insert(neighbours, utils.Directions.left)
    end
    if(y + 1 <= rows and maze[y + 1][x].visited == false) then
        table.insert(neighbours, utils.Directions.down)
    end
    if(y - 1 > 0 and maze[y - 1][x].visited == false) then
        table.insert(neighbours, utils.Directions.up)
    end
    if(#neighbours == 0) then
        return 0
    end
    local rand = math.random(#neighbours)
    return neighbours[rand]
end

function RemoveDeadEnds(rows, cols, maze)
    for i = 1, rows do
        for j = 1, cols do
            local numOfWalls = CountWalls(maze[i][j])
            if  numOfWalls >= 3 then
                local direction = GetWalledNeighbour(j, i, rows, cols, maze)
                local nx = j
                local ny = i
                if(direction == utils.Directions.up) then 
                    ny = ny - 1
                end
                if(direction == utils.Directions.down) then 
                    ny = ny + 1
                end
                if(direction == utils.Directions.right) then 
                    nx = nx + 1
                end
                if(direction == utils.Directions.left) then 
                    nx = nx - 1
                end
                maze[i][j].walls[direction] = false
                maze[ny][nx].walls[OppositeDir(direction)] = false
            end
        end
    end
end

function GetWalledNeighbour(x, y, rows, cols, maze)
    local neighbours = {}
    if(x + 1 <= cols and maze[y][x].walls[utils.Directions.right]) then
        table.insert(neighbours, utils.Directions.right)
    end
    if(x - 1 > 0 and maze[y][x].walls[utils.Directions.left]) then
        table.insert(neighbours, utils.Directions.left)
    end
    if(y + 1 <= rows and maze[y][x].walls[utils.Directions.down]) then
        table.insert(neighbours, utils.Directions.down)
    end
    if(y - 1 > 0 and maze[y][x].walls[utils.Directions.up]) then
        table.insert(neighbours, utils.Directions.up)
    end
    local rand = math.random(#neighbours)
    return neighbours[rand]
end

function CountWalls(cell)
    local count = 0
    for _, hasWall in pairs(cell.walls) do
        if hasWall then
            count = count + 1
        end
    end
    return count
end

function BreakLongWalls(rows, cols, maze, threshold)
    threshold = threshold or 3  -- break walls longer than this

    for i = 1, rows do
        local run = 0
        for j = 1, cols do
            if maze[i][j].walls[utils.Directions.up] then
                run = run + 1
                if run >= threshold then
                    local breakAt = j - math.random(0, run - 1)
                    if i - 1 >= 1 then
                        maze[i][breakAt].walls[utils.Directions.up] = false
                        maze[i-1][breakAt].walls[utils.Directions.down] = false
                    end
                    run = 0
                end
            else
                run = 0
            end
        end
    end

    for j = 1, cols do
        local run = 0
        for i = 1, rows do
            if maze[i][j].walls[utils.Directions.right] then
                run = run + 1
                if run >= threshold then
                    local breakAt = i - math.random(0, run - 1)
                    if j + 1 <= cols then
                        maze[breakAt][j].walls[utils.Directions.right] = false
                        maze[breakAt][j+1].walls[utils.Directions.left] = false
                    end
                    run = 0
                end
            else
                run = 0
            end
        end
    end
end

local function getCellQuad(cell)
    local count = CountWalls(cell)
    if(count == 0) then
        return 0, cellQuads.intersection
    elseif (count == 1) then
        if(cell.walls[utils.Directions.down]) then
            return 180, cellQuads.threeway
        elseif (cell.walls[utils.Directions.left]) then
            return 270, cellQuads.threeway
        elseif (cell.walls[utils.Directions.up]) then
            return 0, cellQuads.threeway
        else
            return 90, cellQuads.threeway
        end
    elseif (count == 2) then
        if (cell.walls[utils.Directions.up] and cell.walls[utils.Directions.down]) then
            return 0, cellQuads.straight
        elseif (cell.walls[utils.Directions.left] and cell.walls[utils.Directions.right]) then
            return 90, cellQuads.straight
        elseif (cell.walls[utils.Directions.up] and cell.walls[utils.Directions.left]) then
            return 0, cellQuads.corner
        elseif (cell.walls[utils.Directions.up] and cell.walls[utils.Directions.right]) then
            return 90, cellQuads.corner
        elseif (cell.walls[utils.Directions.right] and cell.walls[utils.Directions.down]) then
            return 180, cellQuads.corner
        elseif (cell.walls[utils.Directions.down] and cell.walls[utils.Directions.left]) then
            return 270, cellQuads.corner
        end
    elseif (count == 3) then
        if (not cell.walls[utils.Directions.right]) then
            return 0, cellQuads.deadend
        elseif (not cell.walls[utils.Directions.down]) then
            return 90, cellQuads.deadend
        elseif (not cell.walls[utils.Directions.left]) then
            return 180, cellQuads.deadend
        else
            return 270, cellQuads.deadend
        end
    end

    return 0, cellQuads.intersection
end

function Maze.drawMaze(rows, cols, maze)
    local mazeCanvas = love.graphics.newCanvas()
    local prev = love.graphics.getCanvas()
    love.graphics.setCanvas(mazeCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
    for i = 1, cols do
        for j = 1, rows do
            local angle, quad = getCellQuad(maze[i][j])
            love.graphics.draw(textureSheet, quad, maze[i][j].x + Maze.Offset.x + Maze.CellDimensions.x/2, maze[i][j].y + Maze.Offset.y + Maze.CellDimensions.y/2, math.rad(angle), cellSize/tileW, cellSize/tileW, tileW/2, tileW/2)
            --love.graphics.print(j .. " " .. i, maze[i][j].x + Maze.Offset.x, maze[i][j].y + Maze.Offset.y, math.rad(angle), 4, 4)
        end
    end
    love.graphics.setCanvas(prev)

    return mazeCanvas
end


return Maze