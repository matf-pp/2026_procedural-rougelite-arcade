local utils  = require("utils")
local player = require("player")
local enemy = require("enemy")
local ghost = require("ghost")
local colliders = require("colliders")
local pebble = require("pebble")
local soundFX = require("soundFX")

local RelicInterface = {}

local Relic = {
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
function RelicInterface.newDashRelic()
    local DashRelic = {}
    setmetatable(DashRelic, Relic)

    DashRelic.name = "DashRelic"
    DashRelic.passive_relic = false
    DashRelic.title = "exalted remains"
    DashRelic.description = "exaltate oneself from another one's exaltation"
    DashRelic.image = love.graphics.newImage("assets/relics/exalted_remains.png")
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
        soundFX.dash()
        DashRelic.timerDuration = 0
        DashRelic.timerCooldown = 0
    end

    function DashRelic.reset()
        DashRelic.timerCooldown = DashRelic.cooldown
        DashRelic.timerDuration = DashRelic.duration + 1
    end

    return DashRelic
end

function RelicInterface.newJumpRelic()
    local JumpRelic = {}
    setmetatable(JumpRelic, Relic)

    JumpRelic.name = "JumpRelic"
    JumpRelic.passive_relic = false
    JumpRelic.title = "Argon residue"
    JumpRelic.description = "you feel the ground underneath becoming lighter"
    JumpRelic.image = love.graphics.newImage("assets/relics/argon_residue.png")
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
        soundFX.phase()
        JumpRelic.timerDuration = 0
        JumpRelic.timerCooldown = 0
    end

    function JumpRelic.reset()
        JumpRelic.timerCooldown = JumpRelic.cooldown
        JumpRelic.timerDuration = JumpRelic.duration + 1
    end

    return JumpRelic
end

function RelicInterface.newEnemyFreezeRelic()
    local EnemyFreezeRelic = {}
    setmetatable(EnemyFreezeRelic, Relic)

    EnemyFreezeRelic.name = "FreezeRelic"
    EnemyFreezeRelic.passive_relic = false
    EnemyFreezeRelic.title = "Frozen mercury"
    EnemyFreezeRelic.description = "you feel a chilling cold biting down on you for a moment"
    EnemyFreezeRelic.image = love.graphics.newImage("assets/relics/frozenmercury.png")
    EnemyFreezeRelic.cooldown = 50 --sekundi
    EnemyFreezeRelic.duration = 2 --sekundi
    EnemyFreezeRelic.timerCooldown = EnemyFreezeRelic.cooldown
    EnemyFreezeRelic.timerDuration = EnemyFreezeRelic.duration + 1
    
    function EnemyFreezeRelic.update(dt)
        EnemyFreezeRelic.timerCooldown = EnemyFreezeRelic.timerCooldown + dt
        EnemyFreezeRelic.timerDuration = EnemyFreezeRelic.timerDuration + dt

        if EnemyFreezeRelic.timerDuration <= EnemyFreezeRelic.duration then
            enemy.pauseAll()
            ghost.pauseAll()
        else
            enemy.unpauseAll()
            ghost.unpauseAll()
        end
    end

    function EnemyFreezeRelic.canUse()
        return EnemyFreezeRelic.timerCooldown >= EnemyFreezeRelic.cooldown
    end

    function EnemyFreezeRelic.use()
        soundFX.freeze()
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
function RelicInterface.newBaseSpeedPassive()
    local BaseSpeedPassive = {}
    setmetatable(BaseSpeedPassive, Relic)

    BaseSpeedPassive.name = "BaseSpeedPassive"
    BaseSpeedPassive.passive_relic = true
    BaseSpeedPassive.title = "Shoes"
    BaseSpeedPassive.description = "6 pairs of shoes. Boosts player move speed"
    BaseSpeedPassive.image = love.graphics.newImage("assets/relics/placeholder.png")
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

function RelicInterface.newCooldownReductionPassive()
    local CooldownReductionPassive = {}
    setmetatable(CooldownReductionPassive, Relic)

    CooldownReductionPassive.name = "CooldownReductionPassive"
    CooldownReductionPassive.passive_relic = true
    CooldownReductionPassive.title = "Hourglass"
    CooldownReductionPassive.description = "Your sense of time is changed."
    CooldownReductionPassive.image = love.graphics.newImage("assets/relics/placeholder.png")
    CooldownReductionPassive.boost = utils.playerSpeed*0.25

    function CooldownReductionPassive.use(ActiveRelics)
        if(CooldownReductionPassive.active == false)then
            for _, r in ipairs(ActiveRelics) do
                if(r.cooldown ~= nil) then
                    r.cooldown = r.cooldown*0.8
                end
            end
            CooldownReductionPassive.active = true
        end
    end

    return CooldownReductionPassive
end

function RelicInterface.newMagnetPassive()
    local MagnetPassive = {}
    setmetatable(MagnetPassive, Relic)

    MagnetPassive.name = "BaseSpeedPassive"
    MagnetPassive.passive_relic = true
    MagnetPassive.title = "Shoes"
    MagnetPassive.description = "6 pairs of shoes. Boosts player move speed"
    MagnetPassive.image = love.graphics.newImage("assets/relics/placeholder.png")
    MagnetPassive.boost = utils.playerSpeed*0.25
    MagnetPassive.collider = colliders.CircleCollider.new(player.x, player.y, utils.CellDimensions.y*2)

    function MagnetPassive.colliderUpdate()
        MagnetPassive.collider:setPosition(player.x, player.y)
    end

    function MagnetPassive.use()
        if(MagnetPassive.active == false)then
            pebble.setMagnetTrue(MagnetPassive)
            MagnetPassive.active = true
        end
    end

    return MagnetPassive
end

local relicConstructors = {
    DashRelic = RelicInterface.newDashRelic,
    JumpRelic = RelicInterface.newJumpRelic,
    FreezeRelic = RelicInterface.newEnemyFreezeRelic,
    BaseSpeedPassive = RelicInterface.newBaseSpeedPassive,
    CooldownReductionPassive = RelicInterface.newCooldownReductionPassive,
    MagnetPassive = RelicInterface.newMagnetPassive,
}

RelicInterface.RelicManager = {
    ActiveRelic = {
        j = nil,
        k = nil,
        l = nil
    },
    PassiveRelicList = {}
}

function RelicInterface.RelicManager:reset()
    self.ActiveRelic = { j = nil, k = nil, l = nil }
    self.PassiveRelicList = {}
end

function RelicInterface.RelicManager:getActiveRelic(option)
    if option == "j" or option == "k" or option == "l" then
        return self.ActiveRelic[option]
    end
    return nil
end

function RelicInterface.RelicManager:setActiveRelic(option, relic)
    if option == "j" or option == "k" or option == "l" then
        self.ActiveRelic[option] = relic
        return true
    end
    return false
end

function RelicInterface.RelicManager:getPassiveRelicList()
    return self.PassiveRelicList
end

function RelicInterface.RelicManager:getActiveRelicList()
    local list = {}
    for _, option in ipairs({"j", "k", "l"}) do
        local relic = self:getActiveRelic(option)
        if relic then
            table.insert(list, relic)
        end
    end
    return list
end

function RelicInterface.RelicManager:setPassiveRelicList(list)
    if type(list) ~= "table" then
        return false
    end
    self.PassiveRelicList = list
    return true
end

function RelicInterface.RelicManager:hasRelicType(typeName)
    for _, relic in pairs(self.ActiveRelic) do
        if relic and relic.name == typeName then
            return true
        end
    end
    for _, relic in ipairs(self.PassiveRelicList) do
        if relic and relic.name == typeName then
            return true
        end
    end
    return false
end

function RelicInterface.RelicManager:addPassiveRelic(relic)
    if not relic or relic.passive_relic ~= true then
        return false
    end
    table.insert(self.PassiveRelicList, relic)
    return true
end

function RelicInterface.RelicManager:addRelic(relic)
    if not relic then
        return false
    end
    if relic.passive_relic == true then
        return self:addPassiveRelic(relic)
    end
    for _, option in ipairs({"j", "k", "l"}) do
        if self.ActiveRelic[option] == nil then
            self.ActiveRelic[option] = relic
            return true
        end
    end
    return false
end

function RelicInterface.RelicManager:useActiveRelic(option)
    local relic = self:getActiveRelic(option)
    if relic and relic.use then
        relic.use()
    end
end

function RelicInterface.RelicManager:getRandomRelicOptions(count)
    count = count or 3
    local remaining = {}
    for typeName, constructor in pairs(relicConstructors) do
        if not self:hasRelicType(typeName) then
            table.insert(remaining, constructor)
        end
    end

    local options = {}
    local total = #remaining
    for i = 1, math.min(count, total) do
        local pick = math.random(1, #remaining)
        local constructor = remaining[pick]
        table.insert(options, constructor())
        table.remove(remaining, pick)
    end
    return options
end

return RelicInterface