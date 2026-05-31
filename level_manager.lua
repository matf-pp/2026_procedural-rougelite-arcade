local maze = require("maze")
local pebble = require("pebble")
local Enemy = require("enemy")
local ghost = require("ghost")
local player = require("player")
local utils = require("utils")

local LevelManager = {
    currentLevel = 0,
    config = {
        [0] = { cells = { x = 6, y = 6 }, enemies = 1, ghosts = 0 },
        [1] = { cells = { x = 8, y = 8 }, enemies = 2, ghosts = 0 },
        [2] = { cells = { x = 10, y = 10 }, enemies = 4, ghosts = 0 },
        [3] = { cells = { x = 12, y = 12 }, enemies = 4, ghosts = 1 },
        [4] = { cells = { x = 14, y = 14 }, enemies = 6, ghosts = 3 },
        [5] = { cells = { x = 16, y = 14 }, enemies = 8, ghosts = 8 }
    },
}

function LevelManager.getConfig(levelNumber)
    return LevelManager.config[levelNumber] or LevelManager.config[5]
end

function LevelManager.prepareLevel(levelNumber)
    if levelNumber then
        LevelManager.currentLevel = levelNumber
    end
    local config = LevelManager.getConfig(LevelManager.currentLevel)

    utils.Cells.x = config.cells.x
    utils.Cells.y = config.cells.y
    utils.numberOfEnemies = config.enemies
    utils.numberOfGhosts = config.ghosts

    maze.load(utils.Cells.y, utils.Cells.x)
    local mazeGrid = maze.makeMaze(utils.Cells.y, utils.Cells.x)
    local pebbles = pebble.initPebbles()
    local numOfPebbles = #pebbles - 2

    player.alive = true
    player.setPlayerPosition()
    player.direction = 0
    player.buffer_direction = 0

    Enemy.spawnAll(utils.numberOfEnemies)
    ghost.spawnAll()

    return mazeGrid, pebbles, numOfPebbles
end

function LevelManager.nextLevel()
    LevelManager.currentLevel = LevelManager.currentLevel + 1
    return LevelManager.prepareLevel(LevelManager.currentLevel)
end

function LevelManager.resetCurrentLevel()
    return LevelManager.prepareLevel(LevelManager.currentLevel)
end

return LevelManager
