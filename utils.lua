Utils = {
    Directions = {
    up = 1,
    right = 2,
    down = 3,
    left = 4
    },

    numberOfEnemies = 3,

    --main.lua
    Cells = {
        x=nil,
        y=nil
    },

    --love.load
    windowWidth = nil,
    windowHeight = nil,
    enemySpeed = 0,
    basePlayerSpeed = 0,
    playerSpeed = 0,
    FPS = nil,
    vsync = nil,

    --maze.lua
    CellDimensions = { x = nil, y = nil },
    WallWidth = nil,
    Offset = { x = nil, y = nil },

    fonts = {}
}

function Utils.gridDataToPx(xGridData, yGridData)
    return {xGridData*Utils.CellDimensions.x + Utils.CellDimensions.x/2 + Utils.Offset.x,
            yGridData*Utils.CellDimensions.y + Utils.CellDimensions.y/2 + Utils.Offset.y}
end

function Utils.isInCenter(x, y, xGridData, yGridData, speed, dt)
    local pixel_limit = dt*speed
    if( ( math.abs( x - (xGridData*Utils.CellDimensions.x + Utils.CellDimensions.x/2 + Utils.Offset.x )) <= (pixel_limit) )
    and ( math.abs( y - (yGridData*Utils.CellDimensions.y + Utils.CellDimensions.y/2 + Utils.Offset.y )) <= (pixel_limit) ) ) then
        return true
    end

    return false
end

-- ovo je ovde da bih mogao van UI-a da se koristi a dobra je funkcija
function Utils.drawWithEffect(effect, fn)
    if not Utils._scratchCanvas then
        Utils._scratchCanvas = love.graphics.newCanvas()
    end
    love.graphics.setCanvas(Utils._scratchCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
    fn()
    love.graphics.setCanvas()
    love.graphics.setBlendMode("alpha")
    effect(function()
        love.graphics.draw(Utils._scratchCanvas)
    end)
end

return Utils