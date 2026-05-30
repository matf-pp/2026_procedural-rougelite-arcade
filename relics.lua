local utils  = require("utils")
local player = require("player")
local enemy = require("enemy")

Relic = {
    name = nil,
    passive_relic = nil,
    image = nil,
    title = nil,
    description = nil,
    scale_factor = {x = 0.4, y = 0.4},
    active = false
}
Relic.__index = Relic

--Active relics
function newDashRelic()
    local DashRelic = {}
    setmetatable(DashRelic, Relic)

    DashRelic.name = "DashRelic"
    DashRelic.passive_relic = false
    DashRelic.title = "exalted remains"
    DashRelic.description = "exaltate oneself from another one's exaltation"
    DashRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    DashRelic.boost = 300
    DashRelic.cooldown = 3 --sekundi
    DashRelic.duration = 0.35 --sekundi
    DashRelic.timerCooldown = DashRelic.cooldown
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

    function DashRelic.reset()
        DashRelic.timerCooldown = DashRelic.cooldown
        DashRelic.timerDuration = DashRelic.duration + 1
    end

    return DashRelic
end

function newJumpRelic()
    local JumpRelic = {}
    setmetatable(JumpRelic, Relic)

    JumpRelic.name = "JumpRelic"
    JumpRelic.passive_relic = false
    JumpRelic.title = "Argon residual"
    JumpRelic.description = "you feel the ground underneath becoming lighter"
    JumpRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    JumpRelic.cooldown = 30 --sekundi
    JumpRelic.duration = 0.2 --sekundi
    JumpRelic.timerCooldown = JumpRelic.cooldown
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

    function JumpRelic.reset()
        JumpRelic.timerCooldown = JumpRelic.cooldown
        JumpRelic.timerDuration = JumpRelic.duration + 1
    end

    return JumpRelic
end

function newEnemyFreezeRelic()
    local EnemyFreezeRelic = {}
    setmetatable(EnemyFreezeRelic, Relic)

    EnemyFreezeRelic.name = "FreezeRelic"
    EnemyFreezeRelic.passive_relic = false
    EnemyFreezeRelic.title = "Frozen mercury"
    EnemyFreezeRelic.description = "you feel a chilling cold biting down on you for a moment"
    EnemyFreezeRelic.image = love.graphics.newImage("assets/relics/tmp.png")
    EnemyFreezeRelic.cooldown = 120 --sekundi
    EnemyFreezeRelic.duration = 5 --sekundi
    EnemyFreezeRelic.timerCooldown = EnemyFreezeRelic.cooldown
    EnemyFreezeRelic.timerDuration = EnemyFreezeRelic.duration + 1
    
    function EnemyFreezeRelic.update(dt)
        EnemyFreezeRelic.timerCooldown = EnemyFreezeRelic.timerCooldown + dt
        EnemyFreezeRelic.timerDuration = EnemyFreezeRelic.timerDuration + dt

        if EnemyFreezeRelic.timerDuration <= EnemyFreezeRelic.duration then
            enemy.pauseAll()
        else
            enemy.unpauseAll()
        end
    end

    function EnemyFreezeRelic.canUse()
        return EnemyFreezeRelic.timerCooldown >= EnemyFreezeRelic.cooldown
    end

    function EnemyFreezeRelic.use()
        EnemyFreezeRelic.timerDuration = 0
        EnemyFreezeRelic.timerCooldown = 0
    end

    function EnemyFreezeRelic.reset()
        EnemyFreezeRelic.timerCooldown = EnemyFreezeRelic.cooldown
        EnemyFreezeRelic.timerDuration = EnemyFreezeRelic.duration + 1
    end

    return EnemyFreezeRelic
end

--Passive relics
function newBaseSpeedPassive()
    local BaseSpeedPassive = {}
    setmetatable(BaseSpeedPassive, Relic)

    BaseSpeedPassive.name = "BaseSpeedPassive"
    BaseSpeedPassive.passive_relic = true
    BaseSpeedPassive.title = "Shoes"
    BaseSpeedPassive.description = "6 pairs of shoes. Boosts player move speed"
    BaseSpeedPassive.image = love.graphics.newImage("assets/relics/tmp.png")
    BaseSpeedPassive.boost = utils.playerSpeed*0.25

    function BaseSpeedPassive.use()
        if(BaseSpeedPassive.active == false)then
            player.speed = utils.playerSpeed + BaseSpeedPassive.boost 
            utils.playerSpeed = player.speed
            BaseSpeedPassive.active = true
        end
    end

    return BaseSpeedPassive
end