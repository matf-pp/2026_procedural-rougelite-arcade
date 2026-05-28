local utils  = require("utils")
local player = require("player")

Relic = {
    name = nil,
    passive_relic = nil,
    image = nil,
    title = nil,
    description = nil,
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
    DashRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    DashRelic.scale_factor.x = 0.4
    DashRelic.scale_factor.y = 0.4
    DashRelic.boost = 300
    DashRelic.cooldown = 3 --sekundi
    DashRelic.duration = 0.35 --sekundi
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

function newJumpRelic()
    local JumpRelic = {}
    setmetatable(JumpRelic, Relic)

    JumpRelic.name = "JumpRelic"
    JumpRelic.title = "Argon residuals"
    JumpRelic.description = "you feel the ground underneath becoming lighter"
    JumpRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    JumpRelic.scale_factor.x = 0.4
    JumpRelic.scale_factor.y = 0.4
    JumpRelic.cooldown = 30 --sekundi
    JumpRelic.duration = 0.2 --sekundi
    JumpRelic.timerCooldown = 0
    JumpRelic.timerDuration = JumpRelic.duration + 1
    
    function JumpRelic.update(dt)
        JumpRelic.timerCooldown = JumpRelic.timerCooldown + dt
        JumpRelic.timerDuration = JumpRelic.timerDuration + dt

        if JumpRelic.timerDuration <= JumpRelic.duration then
            if(  (not (player.direction == utils.Directions.down and player.grid_data.center.y == utils.Cells.y-1))  and
                 (not (player.direction == utils.Directions.right and player.grid_data.center.x == utils.Cells.x-1)) and
                 (not (player.direction == utils.Directions.left and player.grid_data.center.x == 0))                and
                 (not (player.direction == utils.Directions.up and player.grid_data.center.y == 0))) then
                    player.throughWall = true
                 end
        else
            player.throughWall = false
        end
    end

    function JumpRelic.canUse()
        return JumpRelic.timerCooldown >= JumpRelic.cooldown
    end

    function JumpRelic.use()
        JumpRelic.timerDuration = 0
        JumpRelic.timerCooldown = 0
    end

    return JumpRelic
end