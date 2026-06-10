local player = require("player")
local colliders = require("colliders")
local utils = require("utils")

local Ghost = {
    x = 0,
    y = 0,
    image = nil,
    width = 0,
    height = 0,
    scale_factor = 1,
    baseSpeed = 40,
    speed = nil,
    collider = nil,
    followTarget = nil,
}
Ghost.__index = Ghost

Ghost.list = {}

function Ghost.newGhost(x, y, followTarget, speed)
    local self = setmetatable({}, Ghost)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/ghost.png")
    self.scale_factor = 2
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.collider = colliders.CircleCollider.new(self.x, self.y, self.image:getWidth() * self.scale_factor / 2 * 0.2, 0, self.height * 0.1 * self.scale_factor)
    self.followTarget = followTarget
    self.baseSpeed = speed
    self.speed = speed
    return self
end

function Ghost:updateCollider()
    if self.collider then
        self.collider:setPosition(self.x, self.y)
    end
end

function Ghost.spawnAll()
    Ghost.list = {}
    if utils.numberOfGhosts >= 1 then
        table.insert(Ghost.list, Ghost.newGhost(utils.windowWidth / 2, utils.windowHeight / 2, player, 40))
    end

    for i = 2, utils.numberOfGhosts do
        local Xrand = math.random(1, utils.Cells.x / 2 - utils.Cells.x / 6)
        local Yrand = math.random(1, utils.Cells.y / 2 - utils.Cells.y / 6)
        if math.random(1, 2) == 2 then Xrand = -Xrand end
        if math.random(1, 2) == 2 then Yrand = -Yrand end
        Xrand = Xrand * utils.CellDimensions.x
        Yrand = Yrand * utils.CellDimensions.y
        local previousGhost = Ghost.list[#Ghost.list]
        local nextSpeed = math.max(7, Ghost.list[#Ghost.list].speed - 7)
        table.insert(Ghost.list, Ghost.newGhost(utils.windowWidth / 2 + Xrand, utils.windowHeight / 2 + Yrand, previousGhost, nextSpeed))
    end
end

function Ghost.pauseAll()
    for _, g in ipairs(Ghost.list) do
        g.speed = 0
    end
end

function Ghost.unpauseAll()
    for _, g in ipairs(Ghost.list) do
        g.speed = g.baseSpeed
    end
end

function Ghost.updateAll(dt)
    for _, g in ipairs(Ghost.list) do
        g:update(dt)
    end
end

function Ghost:update(dt)
    local target = self.followTarget
    if not target then
        return
    end

    local distX = target.x - self.x
    local distY = target.y - self.y
    local vecLength = math.sqrt(distX * distX + distY * distY)
    if vecLength == 0 then
        return
    end

    self.x = self.x + (distX / vecLength) * self.speed * dt
    self.y = self.y + (distY / vecLength) * self.speed * dt

    self:updateCollider()
    
    if self.collider and player.collider and self.collider:isColliding(player.collider) then
        player.kill()
    end
end

function Ghost.drawAll()
    for _, g in ipairs(Ghost.list) do
        g:draw()
    end
end

function Ghost:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale_factor, self.scale_factor, self.width/2, self.height/2)
end

return Ghost