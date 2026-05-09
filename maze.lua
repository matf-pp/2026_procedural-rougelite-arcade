local utils = require("utils")

local Maze = {
    rows = 0,
    cols = 0
}
local maze_debug = false

function Maze.load(rows, cols)
    local width, height = love.graphics.getDimensions()
    Maze.CellDimensions = { x = 60, y = 60 }
    Maze.WallWidth = 5
    Maze.Offset = {
        x = width/2 - rows/2 * Maze.CellDimensions.x,
        y = height/2 - cols/2 * Maze.CellDimensions.y
    }
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
    MakeCenter(rows, cols, maze)
    RemoveDeadEnds(rows, cols, maze)
    BreakLongWalls(rows, cols, maze, 3)

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
            if(i==y) then
                maze[i][j].walls[utils.Directions.up] = true
                maze[i-1][j].walls[utils.Directions.down] = true
            end
            if(i==height+y-1) then
                maze[i][j].walls[utils.Directions.down] = true
                maze[i+1][j].walls[utils.Directions.up] = true
            end

            if(j==x) then
                maze[i][j].walls[utils.Directions.left] = true
                maze[i][j-1].walls[utils.Directions.right] = true
            end
            if(j==width+x-1) then
                maze[i][j].walls[utils.Directions.right] = true
                maze[i][j+1].walls[utils.Directions.left] = true
            end
        end
    end
end

function MakeCenter(rows, cols, maze)
    local width  = math.floor(cols * 3 / 8)
    local height = math.floor(rows / 4)
    local x = math.floor((cols - width) / 2) + 1
    local y = math.floor((rows - height) / 2) + 1
    MakeHollowZone(x, y, width, height, maze)
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
    if(x + 1 <= rows and maze[y][x + 1].visited == false) then
        table.insert(neighbours, utils.Directions.right)
    end
    if(x - 1 > 0 and maze[y][x - 1].visited == false) then
        table.insert(neighbours, utils.Directions.left)
    end
    if(y + 1 <= cols and maze[y + 1][x].visited == false) then
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
    if(x + 1 <= rows and maze[y][x].walls[utils.Directions.right]) then
        table.insert(neighbours, utils.Directions.right)
    end
    if(x - 1 > 0 and maze[y][x].walls[utils.Directions.left]) then
        table.insert(neighbours, utils.Directions.left)
    end
    if(y + 1 <= cols and maze[y][x].walls[utils.Directions.down]) then
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

-- clanker
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

function Maze.drawMaze(rows, cols, maze)
    local function DrawHorizontalWall(x, y)
        love.graphics.rectangle("fill", x + Maze.Offset.x - math.floor(Maze.WallWidth/2), y + Maze.Offset.y - math.floor(Maze.WallWidth/2), Maze.CellDimensions.x + Maze.WallWidth, Maze.WallWidth)
    end

    local function DrawVerticalWall(x, y)
        love.graphics.rectangle("fill", x + Maze.Offset.x - math.floor(Maze.WallWidth/2), y + Maze.Offset.y - math.floor(Maze.WallWidth/2), Maze.WallWidth, Maze.CellDimensions.y + Maze.WallWidth)
    end

    love.graphics.setColor( 255, 255, 255, 1 )
    for i = 1, rows do
        for j = 1, cols do
            if(maze[i][j].walls[utils.Directions.up]) then
                DrawHorizontalWall(maze[i][j].x, maze[i][j].y)
            end
            if(maze[i][j].walls[utils.Directions.down]) then
                DrawHorizontalWall(maze[i][j].x, maze[i][j].y + Maze.CellDimensions.y)
            end
            if(maze[i][j].walls[utils.Directions.right]) then
                DrawVerticalWall(maze[i][j].x + Maze.CellDimensions.x, maze[i][j].y)
            end
            if(maze[i][j].walls[utils.Directions.left]) then
                DrawVerticalWall(maze[i][j].x, maze[i][j].y)
            end
        end
    end

    if(maze_debug) then
        local function DrawHorizontalWallDebug(x, y)
            love.graphics.rectangle("fill", x + Maze.Offset.x, y + Maze.Offset.y, Maze.CellDimensions.x + Maze.WallWidth, 1)
        end

        local function DrawVerticalWallDebug(x, y)
            love.graphics.rectangle("fill", x + Maze.Offset.x, y + Maze.Offset.y, 1, Maze.CellDimensions.y + Maze.WallWidth)
        end

        love.graphics.setColor( 37, 132, 204, 0.1 )
        for i = 1, rows do
            for j = 1, cols do
                DrawHorizontalWallDebug(maze[i][j].x, maze[i][j].y)
                DrawHorizontalWallDebug(maze[i][j].x, maze[i][j].y + Maze.CellDimensions.y)
                DrawVerticalWallDebug(maze[i][j].x + Maze.CellDimensions.x, maze[i][j].y)
                DrawVerticalWallDebug(maze[i][j].x, maze[i][j].y)
            end
        end   
    end

 
end

return Maze