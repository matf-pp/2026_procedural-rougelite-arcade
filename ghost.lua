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
    speed = nil,
    collider = nil,
    leader = false,
}
Ghost.__index = Ghost

Ghost.list = {}

local GhostLeader
function Ghost.newGhost(x, y, leader)
    local self = setmetatable({}, Ghost)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/ghost.png")
    self.scale_factor = 2
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.collider = colliders.CircleCollider.new(self.x, self.y, self.image:getWidth() * self.scale_factor / 2 * 0.2, 0, self.height * 0.1 * self.scale_factor)
    self.leader = leader
    if(leader) then GhostLeader = self; self.speed=40;
    else self.speed = 20 end
    return self
end

function Ghost:updateCollider()
    if self.collider then
        self.collider:setPosition(self.x, self.y)
    end
end

function Ghost.spawnAll()
    Ghost.list = {}
    if(utils.numberOfGhosts==1) then
        table.insert( Ghost.list, Ghost.newGhost(utils.windowWidth/2, utils.windowHeight/2, true))
    elseif(utils.numberOfGhosts > 1) then
        table.insert( Ghost.list, Ghost.newGhost(utils.windowWidth/2, utils.windowHeight/2, true))
        for i=2, utils.numberOfGhosts do
            local Xrand = math.random(1, utils.Cells.x/2-utils.Cells.x/6)
            local Yrand = math.random(1, utils.Cells.y/2-utils.Cells.y/6)
            local tmp1 = math.random(1,2); if tmp1%2 == 0 then Xrand=Xrand*(-1) end
            local tmp2 = math.random(1,2); if tmp2%2 == 0 then Yrand=Yrand*(-1) end
            Xrand = Xrand*utils.CellDimensions.x; Yrand = Yrand*utils.CellDimensions.y;
            table.insert( Ghost.list, Ghost.newGhost(utils.windowWidth/2+Xrand, utils.windowHeight/2+Yrand, false))
        end
    end
end

function Ghost.updateAll(dt)
    for _, g in ipairs(Ghost.list) do
        g:update(dt)
    end
end

function Ghost:update(dt)
    local target = self.leader and player or GhostLeader

    local distX = target.x - self.x
    local distY = target.y - self.y
    local vecLength = math.sqrt(distX*distX + distY*distY)

    self.x = self.x + (distX/vecLength) * self.speed * dt
    self.y = self.y + (distY/vecLength) * self.speed * dt

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
    if self.collider then
        self.collider:draw()
    end
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale_factor, self.scale_factor, self.width/2, self.height/2)
end

return Ghost