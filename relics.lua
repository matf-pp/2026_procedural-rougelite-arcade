local utils = require("utils")

SpeedRelic = {
    name = "speed_relic",
    boost = 70,
    numOfUses = 3,
    image = nil,
    title = "exalted remains",
    description = "exaltate oneself from another one's exaltation",
    usage = "Press LSHIFT",
    scale_factor = {x = nil, y = nil},
    used_times = 0,
}
SpeedRelic.__index = SpeedRelic

function newSpeedRelic()
    local SpeedRelicInstance = {}
    setmetatable(SpeedRelicInstance, SpeedRelic)

    SpeedRelicInstance.image = love.graphics.newImage('assets/relics/tmp.png')
    SpeedRelicInstance.scale_factor.x = 0.7
    SpeedRelicInstance.scale_factor.y = 0.7

    return SpeedRelicInstance
end