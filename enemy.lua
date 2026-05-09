local maze = require("maze")
local utils = require("utils")

local Enemy = {
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
    }
}
Enemy.__index = Enemy

local last_direction = 0
function newEnemy(num)
    local EnemyInstance = {}
    setmetatable(EnemyInstance, Enemy)

    EnemyInstance.center = {x=0, y=0}
    EnemyInstance.scale_factor = {x=0.4, y=0.4}
    EnemyInstance.grid_data = {center = {x=0, y=0} }

    EnemyInstance.direction = last_direction+1
    last_direction = (last_direction+1) % 4

    EnemyInstance:loadImage(num)
    EnemyInstance:spawn(num)

    return EnemyInstance
end

function Enemy:loadImage(num)
    if num%4 == 0 then
        self.image = love.graphics.newImage('assets/enemy2.png')
    else
        self.image = love.graphics.newImage('assets/enemy1.png')
    end

    self.x_shift = self.image:getWidth()/2 * self.scale_factor.x
    self.y_shift = self.image:getHeight()/2 * self.scale_factor.y
end

local Spawns = {}
function Enemy:spawn(num) 
    local exists = true

    while (exists == true) do
        local tmp = math.random(1,num)
        local minus = (tmp%2==0) and -1 or 1

        -- napraviti bolju logiku za odredjivanje mesta za spawn-ovanje, ovu formulu sam izlupetao da se ne dobije overflow za vise neprijatelja samo za testiranje
        self.x = maze.Offset.x + (math.floor(((utils.Cells.x+(num*tmp*minus)/2)/2)) * maze.CellDimensions.x) - self.x_shift + maze.CellDimensions.x/2
        self.y = maze.Offset.y + (math.floor(((utils.Cells.y+(num*tmp*minus)/2)/2)) * maze.CellDimensions.y) - self.y_shift + maze.CellDimensions.y/2
        self.center.x = self.x + self.x_shift
        self.center.y = self.y + self.y_shift
        self.grid_data.center.x = math.floor(( self.center.x - maze.Offset.x ) / maze.CellDimensions.x )
        self.grid_data.center.y = math.floor(( self.center.y - maze.Offset.y ) / maze.CellDimensions.y )

        if(Spawns[self.grid_data.center.x]~=nil) then
            exists = true
        else
            exists = false
            Spawns[self.grid_data.center.x] = self.grid_data.center.y
        end

    end
end

function Enemy:freeSpawns()
    Spawns = {}
end

function Enemy:changeDirection()
    local Whitelist = {}
    local br = 1
    for smer, postojiZid in pairs(mazeGrid[self.grid_data.center.y+1][self.grid_data.center.x+1].walls) do
        if not postojiZid then
            Whitelist[br] = smer
            br=br+1
        end
    end

    math.randomseed(os.time())
    local tmp = math.random(#Whitelist)
    self.direction = Whitelist[tmp]

    self:correctPosition()
end

function Enemy:correctPosition()
    self.x = self.grid_data.center.x*maze.CellDimensions.x + maze.CellDimensions.x/2 + maze.Offset.x - self.x_shift
    self.y = self.grid_data.center.y*maze.CellDimensions.y + maze.CellDimensions.y/2 + maze.Offset.y - self.y_shift
end

function Enemy:isInCenter(dt)
    local pixel_limit = dt*Enemy.speed
    if( ( math.abs( self.center.x - (self.grid_data.center.x*maze.CellDimensions.x + maze.CellDimensions.x/2 + maze.Offset.x )) <= pixel_limit ) 
    and ( math.abs( self.center.y - (self.grid_data.center.y*maze.CellDimensions.y + maze.CellDimensions.y/2 + maze.Offset.y )) <= pixel_limit ) ) then
        return true
    end

    return false
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

    self.grid_data.center.x = math.floor(( self.center.x - maze.Offset.x ) / maze.CellDimensions.x )
    self.grid_data.center.y = math.floor(( self.center.y - maze.Offset.y ) / maze.CellDimensions.y )
end