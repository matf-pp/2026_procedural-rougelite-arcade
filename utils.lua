Utils = {
    Directions = {
    up = 1,
    right = 2,
    down = 3,
    left = 4
    },

    Cells = {
        x=nil,
        y=nil
    },

    FPS = nil,
    vsync = nil
}

function gridDataToPx(xGridData, yGridData)
    return xGridData*Utils.CellDimensions.x + Utils.CellDimensions.x/2 + Utils.Offset.x, yGridData*Utils.CellDimensions.y + Utils.CellDimensions.y/2 + Utils.Offset.y 
end

return Utils