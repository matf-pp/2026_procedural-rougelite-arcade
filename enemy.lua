local utils = require("utils")
local colliders = require("colliders")

local Enemy = {
    num = nil,
    x = 0,
    y = 0,
    image = nil,
    scale_factor = {
        x = 0,
        y = 0
    },
    direction = 0,
    speed = nil,
    grid_data = {
        center = {
            x = 0,
            y = 0
        },
    },
    collider = nil,
    exitSpawn = false
}
Enemy.__index = Enemy

Enemy.list = {}
Enemy.timerEnemySpawn = 0
local offset = 4
local br = 1
local midX = 0
local midY = 0

function Enemy:loadImage(num)
    self.num = num

    if num%4 == 0 then
        self.image = love.graphics.newImage('assets/enemy2.png')
    else
        self.image = love.graphics.newImage('assets/enemy1.png')
    end
end

local last_direction = 0
function newEnemy(num)
    local EnemyInstance = {}
    setmetatable(EnemyInstance, Enemy)

    EnemyInstance.speed = utils.enemySpeed
    EnemyInstance.scale_factor = {x=0.3, y=0.3}
    EnemyInstance.grid_data = {center = {x=0, y=0} }

    EnemyInstance.direction = last_direction+1
    last_direction = (last_direction+1) % 4

    EnemyInstance:loadImage(num)
    EnemyInstance:spawn(num)

    return EnemyInstance
end

--TODO: da li moze efikasnije da se uradi sapwnovanje, nekako sa lokalnim promenljivim, da se ne pristupa stalno utils? problem je sto je svaki "objekat zaseban" pa bi auzirarnje lokalne promenljivih moralo za svaki posebno sto ne znam koliko je brze od samo pristupanju utils. 
function Enemy:spawn() 
    self.x = utils.Offset.x + ((utils.Cells.x)/2-1)*utils.CellDimensions.x + utils.CellDimensions.x/2
    self.y = utils.Offset.y + ((utils.Cells.y)/2-1)*utils.CellDimensions.y + utils.CellDimensions.y/2
    self.grid_data.center.x = math.floor(( self.x - utils.Offset.x ) / utils.CellDimensions.x )
    self.grid_data.center.y = math.floor(( self.y - utils.Offset.y ) / utils.CellDimensions.y )

    local width = self.image:getWidth() * self.scale_factor.x
    local height = self.image:getHeight() * self.scale_factor.y
    self.collider = colliders.BoxCollider.new(self.x, self.y, width*0.75, height*0.75, -width*0.375, -height*0.375)
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

function Enemy:updateCollider()
    if self.collider then
        self.collider:setPosition(self.x, self.y)
    end
end

--wrapper
function Enemy:correctPosition()
    local tmp = utils.gridDataToPx(self.grid_data.center.x, self.grid_data.center.y)
    self.x = tmp[1]
    self.y = tmp[2]
    self:updateCollider()
end

--wrapper
function Enemy:isInCenter(dt)
    return utils.isInCenter(self.x, self.y, self.grid_data.center.x, self.grid_data.center.y, self.speed, dt)
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

    self:updateCollider()
    self.grid_data.center.x = math.floor(( self.x - utils.Offset.x ) / utils.CellDimensions.x )
    self.grid_data.center.y = math.floor(( self.y - utils.Offset.y ) / utils.CellDimensions.y )
end

function Enemy.spawnAll(n)
    Enemy.list = {}
    Enemy.timerEnemySpawn = 0
    offset = 4; br = 1
    midX = utils.Cells.x/2; midY = utils.Cells.y/2
    for i=1, n do
        table.insert(Enemy.list, newEnemy(i))
    end
end

function Enemy.pauseAll()
    for _, e in ipairs(Enemy.list) do
        e.speed = 0
    end
end

function Enemy.unpauseAll()
    for _, e in ipairs(Enemy.list) do
        e.speed = utils.enemySpeed
    end
end

function Enemy.drawAll()
    for _, e in ipairs(Enemy.list) do
        e.collider:draw()
        love.graphics.draw(e.image, e.x, e.y, 0, e.scale_factor.x, e.scale_factor.y, e.image:getWidth()/2, e.image:getHeight()/2)
    end
end

function Enemy.updateAll(dt, mazeGrid, player)
    --enemy update logic
        --enemy spawn and move
        --na svakih offset sekundi se otvaraju zidovi u kutiji sa donje strane
    Enemy.timerEnemySpawn = Enemy.timerEnemySpawn + dt
    if ( (math.floor(Enemy.timerEnemySpawn) == (offset)) and br~=0) then
        if br%2 == 0 then
            mazeGrid[midY+1][midX].walls[utils.Directions.up] = false
            mazeGrid[midY+1][midX+1].walls[utils.Directions.up] = false
        else
            mazeGrid[midY][midX].walls[utils.Directions.up] = false
            mazeGrid[midY][midX+1].walls[utils.Directions.up] = false
        end
        Enemy.list[br].exitSpawn = true
        offset = offset + 4
    end

    for _, e in ipairs(Enemy.list) do
        if e.exitSpawn == false then --provera da li treba da izadje iz centralne kutije
            if e:isInCenter(dt) then

                --ako je zaglavljen da se odglavi tj odmah promeni smer
                for smer, postojiZid in ipairs(mazeGrid[e.grid_data.center.y+1][e.grid_data.center.x+1].walls) do
                    if postojiZid and e.direction == smer then
                        e:changeDirection()
                    end
                end

                --u suprotnom redovno proverava da li da promeni smer ili ne
                if(math.random(1,4)==2) then
                    e:changeDirection()
                end
            end
        else
            --manuelno postavljanje smera da izadje iz kutije
            if br%2 == 0 then
                e:changeDirection(utils.Directions.down)
            else
                e:changeDirection(utils.Directions.up)
            end
            e:move(dt)  --smemo da pozovemo move() i ako nismo prvo proverili isInCenter() jer changeDirection() poziva correctPosition()
            e.exitSpawn = false
            if (br>=#Enemy.list) then br=0 else br=br+1 end
        end
        e:move(dt)
        mazeGrid[midY][midX].walls[utils.Directions.up] = true
        mazeGrid[midY][midX+1].walls[utils.Directions.up] = true
        mazeGrid[midY+1][midX].walls[utils.Directions.up] = true
        mazeGrid[midY+1][midX+1].walls[utils.Directions.up] = true

        --checking collision with player using colliders
        if e.collider and player.collider and e.collider:isColliding(player.collider) then
            player.kill()
        end
    end
end

return Enemy