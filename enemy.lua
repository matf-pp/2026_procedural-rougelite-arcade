local utils = require("utils")

local Enemy = {
    num = nil,
    x = 0,
    y = 0,
    image = nil,
    x_shift = 0,
    y_shift = 0,
    center = {
        x = 0,
        y = 0
    },
    scale_factor = {
        x = 0,
        y = 0
    },
    direction = 0,
    speed = 200,
    grid_data = {
        center = {
            x = 0,
            y = 0
        },
    },
    exitSpawn = false
}
Enemy.__index = Enemy

function Enemy:loadImage(num)
    self.num = num

    if num%4 == 0 then
        self.image = love.graphics.newImage('assets/enemy2.png')
    else
        self.image = love.graphics.newImage('assets/enemy1.png')
    end

    self.x_shift = self.image:getWidth()/2 * self.scale_factor.x
    self.y_shift = self.image:getHeight()/2 * self.scale_factor.y
end

local last_direction = 0
function newEnemy(num)
    local EnemyInstance = {}
    setmetatable(EnemyInstance, Enemy)

    EnemyInstance.speed = utils.enemySpeed
    EnemyInstance.center = {x=0, y=0}
    EnemyInstance.scale_factor = {x=0.4, y=0.4}
    EnemyInstance.grid_data = {center = {x=0, y=0} }

    EnemyInstance.direction = last_direction+1
    last_direction = (last_direction+1) % 4

    EnemyInstance:loadImage(num)
    EnemyInstance:spawn(num)

    return EnemyInstance
end

function Enemy:spawn(num) 
    self.x = utils.Offset.x + math.random(5,6)*utils.CellDimensions.x - self.x_shift + utils.CellDimensions.x/2
    self.y = utils.Offset.y + 5*utils.CellDimensions.y - self.y_shift + utils.CellDimensions.y/2
    self.center.x = self.x + self.x_shift
    self.center.y = self.y + self.y_shift
    self.grid_data.center.x = math.floor(( self.center.x - utils.Offset.x ) / utils.CellDimensions.x )
    self.grid_data.center.y = math.floor(( self.center.y - utils.Offset.y ) / utils.CellDimensions.y )
end

function Enemy:changeDirection(direction)
    local Whitelist = {}
    local br = 1
    if direction==nil then
        for smer, postojiZid in pairs(mazeGrid[self.grid_data.center.y+1][self.grid_data.center.x+1].walls) do
            if not postojiZid then
                Whitelist[br] = smer
                br=br+1
            end
        end
    else
        self.direction = direction
        self:correctPosition()
        return
    end

    local tmp = math.random(#Whitelist)
    self.direction = Whitelist[tmp]

    self:correctPosition()
end

--wrapper
function Enemy:correctPosition()
    local tmp = utils.gridDataToPx(self.grid_data.center.x, self.grid_data.center.y, self.x_shift, self.y_shift)
    self.x = tmp[1]
    self.y = tmp[2]
end

--wrapper
function Enemy:isInCenter(dt)
    return utils.isInCenter(self.center.x, self.center.y, self.grid_data.center.x, self.grid_data.center.y, self.speed, dt)
end

function Enemy:move(dt)
    if(self.direction == utils.Directions.up) then
        self.y = self.y - self.speed*dt
    end

    if(self.direction == utils.Directions.down) then
        self.y = self.y + self.speed*dt
    end

    if(self.direction == utils.Directions.left) then
        self.x = self.x - self.speed*dt
    end

    if(self.direction == utils.Directions.right) then
        self.x = self.x + self.speed*dt
    end

    self.center.x = self.x + self.x_shift
    self.center.y = self.y + self.y_shift

    self.grid_data.center.x = math.floor(( self.center.x - utils.Offset.x ) / utils.CellDimensions.x )
    self.grid_data.center.y = math.floor(( self.center.y - utils.Offset.y ) / utils.CellDimensions.y )
end