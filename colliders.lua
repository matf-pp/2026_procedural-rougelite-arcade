local Colliders = {}

local Collider = {}
Collider.__index = Collider

local function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function Collider.new(x, y, offsetX, offsetY)
    local self = setmetatable({}, Collider)
    self.x = x or 0
    self.y = y or 0
    self.offsetX = offsetX or 0
    self.offsetY = offsetY or 0
    return self
end

function Collider:setPosition(x, y)
    self.x = x
    self.y = y
end

function Collider:setOffset(offsetX, offsetY)
    self.offsetX = offsetX or 0
    self.offsetY = offsetY or 0
end

function Collider:getX()
    return self.x + (self.offsetX or 0)
end

function Collider:getY()
    return self.y + (self.offsetY or 0)
end

function Collider:isColliding(collider)
    return false
end

function Collider:isInside(collider)
    return false
end

function Collider:getType()
    return "base collider"
end

Colliders.BoxCollider = setmetatable({}, Collider)
Colliders.BoxCollider.__index = Colliders.BoxCollider

function Colliders.BoxCollider.new(x, y, width, height, offsetX, offsetY)
    local self = Collider.new(x, y, offsetX, offsetY)
    setmetatable(self, Colliders.BoxCollider)
    self.width = width
    self.height = height
    return self
end

function Colliders.BoxCollider:getType()
    return "box collider"
end

function Colliders.BoxCollider:printInfo()
    print(self:getX(), self:getY(), self.width, self.height)
end

function Colliders.BoxCollider:isColliding(collider)
    if collider:getType() == "box collider" then
        return not (self:getX() + self.width < collider:getX() or      --not out of the box
                    self:getY() + self.height < collider:getY() or
                    self:getX() > collider:getX() + collider.width or
                    self:getY() > collider:getY() + collider.height)
    elseif collider:getType() == "circle collider" then
        local closeX = collider:getX()
        local closeY = collider:getY()

        if collider:getX() > self:getX() + self.width then
            closeX = self:getX() + self.width
        elseif collider:getX() < self:getX() then
            closeX = self:getX()
        end

        if collider:getY() > self:getY() + self.height then
            closeY = self:getY() + self.height
        elseif collider:getY() < self:getY() then
            closeY = self:getY()
        end

        return collider:isPointInside(closeX, closeY)
    else
        print("not a compatible collider")
    end
end

function Colliders.BoxCollider:isInside(collider)
    if collider:getType() == "circle collider" then
        return collider:isPointInside(self:getX(), self:getY()) and
               collider:isPointInside(self:getX() + self.width, self:getY()) and
               collider:isPointInside(self:getX() + self.width, self:getY() + self.height) and
               collider:isPointInside(self:getX(), self:getY() + self.height)
    else
        return "not a compatible collider"
    end
end

function Colliders.BoxCollider:draw()
    love.graphics.rectangle("line", self:getX(), self:getY(), self.width, self.height)
end

Colliders.CircleCollider = setmetatable({}, Collider)
Colliders.CircleCollider.__index = Colliders.CircleCollider

function Colliders.CircleCollider.new(x, y, radius, offsetX, offsetY)
    local self = Collider.new(x, y, offsetX, offsetY)
    setmetatable(self, Colliders.CircleCollider)
    self.radius = radius
    return self
end

function Colliders.CircleCollider:getType()
    return "circle collider"
end

function Colliders.CircleCollider:printInfo()
    print(self:getX(), self:getY(), self.radius)
end

function Colliders.CircleCollider:isColliding(collider)
    if collider:getType() == "circle collider" then
        local radiusSum = self.radius + collider.radius
        local centerDistance = distance(self:getX(), self:getY(), collider:getX(), collider:getY())

        return radiusSum < centerDistance
    elseif collider:getType() == "box collider" then
        return collider:isColliding(self)
    else
        print("not a compatible collider")
    end
end

function Colliders.CircleCollider:isPointInside(x, y)
    return distance(x, y, self:getX(), self:getY()) < self.radius
end

function Colliders.CircleCollider:draw()
    love.graphics.circle("line", self:getX(), self:getY(), self.radius)
end


return Colliders