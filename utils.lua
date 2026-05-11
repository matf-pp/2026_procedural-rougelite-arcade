Utils = {
    Directions = {
    up = 1,
    right = 2,
    down = 3,
    left = 4
    },

    numberOfEnemies = 5,

    --main.lua
    Cells = {
        x=nil,
        y=nil
    },

    --love.load
    windowWidth = nil,
    windowHeight = nil,
    enemySpeed = nil,
    playerSpeed = nil,
    FPS = nil,
    vsync = nil,

    --maze.lua
    CellDimensions = { x = nil, y = nil },
    WallWidth = nil,
    Offset = { x = nil, y = nil },
}

function Utils.gridDataToPx(xGridData, yGridData, x_shift, y_shift)
    return {xGridData*Utils.CellDimensions.x + Utils.CellDimensions.x/2 + Utils.Offset.x - x_shift, yGridData*Utils.CellDimensions.y + Utils.CellDimensions.y/2 + Utils.Offset.y - y_shift}
end

function Utils.isInCenter(x, y, xGridData, yGridData, speed, dt)
    local pixel_limit = dt*speed
    if( ( math.abs( x - (xGridData*Utils.CellDimensions.x + Utils.CellDimensions.x/2 + Utils.Offset.x )) <= (pixel_limit) )
    and ( math.abs( y - (yGridData*Utils.CellDimensions.y + Utils.CellDimensions.y/2 + Utils.Offset.y )) <= (pixel_limit) ) ) then
        return true
    end

    return false
end

return Utils