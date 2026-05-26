local utils  = require("utils")
local player = require("player")

Relic = {
    name = nil,
    passive_relic = nil,
    image = nil,
    title = nil,
    description = nil,
    usage = nil,
    scale_factor = {x = nil, y = nil},
    active = false
}
Relic.__index = Relic

function newDashRelic()
    local DashRelic = {}
    setmetatable(DashRelic, Relic)

    DashRelic.name = "DashRelic"
    DashRelic.title = "exalted remains"
    DashRelic.description = "exaltate oneself from another one's exaltation"
    DashRelic.usage = "Press LSHIFT"
    DashRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    DashRelic.boost = 250
    DashRelic.cooldown = 3 --sekundi
    DashRelic.duration = 0.5 --sekundi
    DashRelic.timerCooldown = 0
    DashRelic.timerDuration = DashRelic.duration + 1
    
    function DashRelic.update(dt)
        DashRelic.timerCooldown = DashRelic.timerCooldown + dt
        DashRelic.timerDuration = DashRelic.timerDuration + dt

        if DashRelic.timerDuration <= DashRelic.duration then
            player.speed = utils.playerSpeed + DashRelic.boost
        else
            player.speed = utils.playerSpeed
        end
    end

    function DashRelic.canUse()
        return DashRelic.timerCooldown >= DashRelic.cooldown
    end

    function DashRelic.use()
        DashRelic.timerDuration = 0
        DashRelic.timerCooldown = 0
    end

    return DashRelic
end