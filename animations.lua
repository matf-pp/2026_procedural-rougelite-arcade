local Animations = {}

function Animations.updateTime(animation, dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end
end

function Animations.draw(animation, x, y, scaleX, scaleY)
    local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], x, y, 0, scaleX, scaleY)
end

function Animations.newAnimation(image, width, height, duration)
    local animation = {}
    animation.width = width
    animation.height = height
    animation.spriteSheet = image;
    animation.spriteSheet:setFilter("nearest", "nearest")
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end

return Animations