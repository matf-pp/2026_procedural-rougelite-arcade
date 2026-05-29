local player = require("player")
local colliders = require("colliders")

local Ghost = {
    x = 0,
    y = 0,
    image = nil,
    x_shift = 0,
    y_shift = 0,
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
    self.scale_factor.x = 2
    self.scale_factor.y = 2
    self.x_shift = self.image:getWidth()/2 * self.scale_factor.x
    self.y_shift = self.image:getHeight()/2 * self.scale_factor.y
    self.speed = 20
    self.collider = colliders.BoxCollider.new(self.x - self.x_shift, self.y - self.y_shift, self.image:getWidth() * self.scale_factor.x, self.image:getHeight() * self.scale_factor.y)
    return self
end

function Ghost:updateCollider()
    if self.collider then
        self.collider:setPosition(self.x - self.x_shift, self.y - self.y_shift)
    end
end

function Ghost:update(dt)
    local distX = (player.x - self.x)
    local distY = (player.y - self.y)
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
        self.collider:draw()
    end
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale_factor.x, self.scale_factor.y, self.x_shift, self.y_shift)
end

return Ghost