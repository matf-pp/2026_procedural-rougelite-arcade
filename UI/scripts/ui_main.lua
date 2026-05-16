local loveli = require("LOVELi-main.LOVELi")

local ui_main = {}

local layoutmanager

function ui_main.load(onStart)
    local startBtn = loveli.Button:new{
        text = "Start",
        width = 120, height = 40,
        horizontaloptions = "center",
        horizontaltextalignment = "center",
        verticaltextalignment = "center",
        clicked = function() onStart() end
    }

    local quitBtn = loveli.Button:new{
        text = "Quit",
        width = 120, height = 40,
        horizontaloptions = "center",
        horizontaltextalignment = "center",
        verticaltextalignment = "center",
        clicked = function() love.event.push("quit", 0) end
    }

    local layout = loveli.StackLayout:new{
        orientation = "vertical",
        spacing = 10,
        width = "*", height = "*",
        horizontaloptions = "center",
        verticaloptions = "center"
    }
    :with(startBtn)
    :with(quitBtn)

    layoutmanager = loveli.LayoutManager:new{}:with(layout)
end

function ui_main.update(dt)
    layoutmanager:update(dt)
end

function ui_main.draw()
    love.graphics.clear(0, 0, 0)
    layoutmanager:draw()
end

function ui_main.mousepressed(x, y, button, istouch, presses)
    layoutmanager:mousepressed(x, y, button, istouch, presses)
end

function ui_main.mousereleased(x, y, button, istouch, presses)
    layoutmanager:mousereleased(x, y, button, istouch, presses)
end

function ui_main.mousemoved(x, y, dx, dy, istouch)
    layoutmanager:mousemoved(x, y, dx, dy, istouch)
end

function ui_main.keypressed(key, scancode, isrepeat)
    layoutmanager:keypressed(key, scancode, isrepeat)
end

return ui_main
