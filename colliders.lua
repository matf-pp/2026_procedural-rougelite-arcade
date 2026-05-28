local Colliders = {}

local Collider = {}
Collider.__index = Collider

local function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function Collider.new(x, y)
    local self = setmetatable({}, Collider)
    self.x = x or 0
    self.y = y or 0
    return self
end

function Collider:setPosition(x, y)
    self.x = x
    self.y = y
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

function Colliders.BoxCollider.new(x, y, width, height)
    local self = Collider.new(x, y)
    setmetatable(self, Colliders.BoxCollider)
    self.width = width
    self.height = height
    return self
end

function Colliders.BoxCollider:getType()
    return "box collider"
end

function Colliders.BoxCollider:printInfo()
    print(self.x, self.y, self.width, self.height)
end

function Colliders.BoxCollider:isColliding(collider)
    if collider:getType() == "box collider" then
        return not (self.x + self.width < collider.x or      --not out of the box
                    self.y + self.height < collider.y or
                    self.x > collider.x + collider.width or
                    self.y > collider.y + collider.height)
    elseif collider:getType() == "circle collider" then
        local closeX = collider.x
        local closeY = collider.y

        if collider.x > self.x + self.width then
            closeX = self.x + self.width
        elseif collider.x < self.x then
            closeX = self.x
        end

        if collider.y > self.y + self.height then
            closeY = self.y + self.height
        elseif collider.y < self.y then
            closeY = self.y
        end

        return collider:isPointInside(closeX, closeY)
    else
        print("not a compatible collider")
    end
end

function Colliders.BoxCollider:isInside(collider)
    if collider:getType() == "circle collider" then
        return collider:isPointInside(self.x, self.y) and
               collider:isPointInside(self.x + self.width, self.y) and
               collider:isPointInside(self.x + self.width, self.y + self.height) and
               collider:isPointInside(self.x, self.y + self.height)
    else
        return "not a compatible collider"
    end
end

function Colliders.BoxCollider:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

Colliders.CircleCollider = setmetatable({}, Collider)
Colliders.CircleCollider.__index = Colliders.CircleCollider

function Colliders.CircleCollider.new(x, y, radius)
    local self = Collider.new(x, y)
    setmetatable(self, Colliders.CircleCollider)
    self.radius = radius
    return self
end

function Colliders.CircleCollider:getType()
    return "circle collider"
end

function Colliders.CircleCollider:printInfo()
    print(self.x, self.y, self.radius)
end

function Colliders.CircleCollider:isColliding(collider)
    if collider:getType() == "circle collider" then
        local radiusSum = self.radius + collider.radius
        local centerDistance = distance(self.x, self.y, collider.x, collider.y)

        return radiusSum < centerDistance
    elseif collider:getType() == "box collider" then
        return collider:isColliding(self)
    else
        print("not a compatible collider")
    end
end

function Colliders.CircleCollider:isPointInside(x, y)
    return distance(x, y, self.x, self.y) < self.radius
end

function Colliders.CircleCollider:draw()
    love.graphics.circle("line", self.x, self.y, self.radius)
end


return Colliders