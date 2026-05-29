local player = require("player")
local colliders = require("colliders")

local Ghost = {
    x = 0,
    y = 0,
    image = nil,
    width = 0,
    height = 0,
    scale_factor = {
        x = 0,
        y = 0
    },
    speed = nil,
    collider = nil,
}
Ghost.__index = Ghost

function Ghost.newGhost(x, y)
    local self = setmetatable({}, Ghost)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/ghost.png")
    self.scale_factor = 2
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.speed = 20
    self.collider = colliders.CircleCollider.new(self.x, self.y, self.image:getWidth() * self.scale_factor / 2 * 0.2, 0, self.height * 0.1 * self.scale_factor)
    return self
end

function Ghost:updateCollider()
    if self.collider then
        self.collider:setPosition(self.x, self.y)
    end
end

function Ghost:update(dt)
    local distX = (player.center.x - self.x)
    local distY = (player.center.y - self.y)
    local vecLength = math.sqrt(distX*distX + distY*distY)

    local speedMultiplierX = distX/vecLength
    local speedMultiplierY = distY/vecLength

    self.x = self.x + speedMultiplierX * self.speed * dt
    self.y = self.y + speedMultiplierY * self.speed * dt
    self:updateCollider()

    if self.collider and player.collider and self.collider:isColliding(player.collider) then
        player.alive = false
    end
end

function Ghost:draw()
    if self.collider then
        --self.collider:draw()
    end
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale_factor, self.scale_factor, self.width/2, self.height/2)
end

return Ghost