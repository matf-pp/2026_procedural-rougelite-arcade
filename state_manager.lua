local StateManager = {
    currentName = nil,
    previousName = nil,
    currentState = nil,
    previousState = nil,
    states = {},
    currentParams = nil,
}

local function blank() end

function StateManager.register(name, state)
    StateManager.states[name] = state or {}
    StateManager.states[name].name = name
    StateManager.states[name].enter = state and state.enter or blank
    StateManager.states[name].exit = state and state.exit or blank
    StateManager.states[name].update = state and state.update or blank
    StateManager.states[name].draw = state and state.draw or blank
    StateManager.states[name].keypressed = state and state.keypressed or blank
    StateManager.states[name].keyreleased = state and state.keyreleased or blank
    StateManager.states[name].mousepressed = state and state.mousepressed or blank
    StateManager.states[name].mousereleased = state and state.mousereleased or blank
    StateManager.states[name].mousemoved = state and state.mousemoved or blank
end

function StateManager.changeState(name, params)
    if not StateManager.states[name] then
        error("StateManager: attempt to change to unknown state: " .. tostring(name))
    end

    if StateManager.currentState and StateManager.currentState.exit then
        StateManager.currentState.exit(params)
    end

    StateManager.previousName = StateManager.currentName
    StateManager.previousState = StateManager.currentState
    StateManager.currentName = name
    StateManager.currentState = StateManager.states[name]
    StateManager.currentParams = params

    if StateManager.currentState.enter then
        StateManager.currentState.enter(params)
    end
end

function StateManager.update(dt)
    if StateManager.currentState and StateManager.currentState.update then
        StateManager.currentState.update(dt)
    end
end

function StateManager.draw()
    if StateManager.currentState and StateManager.currentState.draw then
        StateManager.currentState.draw()
    end
end

function StateManager.keypressed(key, scancode, isrepeat)
    if StateManager.currentState and StateManager.currentState.keypressed then
        StateManager.currentState.keypressed(key, scancode, isrepeat)
    end
end

function StateManager.keyreleased(key, scancode, isrepeat)
    if StateManager.currentState and StateManager.currentState.keyreleased then
        StateManager.currentState.keyreleased(key, scancode, isrepeat)
    end
end

function StateManager.mousepressed(x, y, button, istouch, presses)
    if StateManager.currentState and StateManager.currentState.mousepressed then
        StateManager.currentState.mousepressed(x, y, button, istouch, presses)
    end
end

function StateManager.mousereleased(x, y, button, istouch, presses)
    if StateManager.currentState and StateManager.currentState.mousereleased then
        StateManager.currentState.mousereleased(x, y, button, istouch, presses)
    end
end

function StateManager.mousemoved(x, y, dx, dy, istouch)
    if StateManager.currentState and StateManager.currentState.mousemoved then
        StateManager.currentState.mousemoved(x, y, dx, dy, istouch)
    end
end

function StateManager.getCurrentName()
    return StateManager.currentName
end

function StateManager.getPreviousName()
    return StateManager.previousName
end

return StateManager
