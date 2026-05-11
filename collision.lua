local maze = require("maze")
local utils = require("utils")

function gridCollision(x1,y1,x2,y2)
    if(x1==x2 and y1==y2)then
        return true
    end
    return false
end