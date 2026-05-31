local SoundFX = {}

local volume = 0.05

local pebble
local death
local select
local hover
local iris

function SoundFX.load()
    pebble = love.audio.newSource('assets/soundFX/pebble.wav', 'stream')
    pebble:setVolume(volume)
    death = love.audio.newSource('assets/soundFX/death.wav', 'stream')
    death:setVolume(volume)
    select = love.audio.newSource('assets/soundFX/select.wav', 'stream')
    select:setVolume(volume)
    hover = love.audio.newSource('assets/soundFX/hover.wav', 'stream')
    hover:setVolume(volume)
    iris = love.audio.newSource('assets/soundFX/iris.wav', 'stream')
    iris:setVolume(volume)
end

function SoundFX.pebble()
    pebble:play()
end

function SoundFX.death()
    death:play()
end

function SoundFX.select()
    select:play()
end

function SoundFX.hover()
    hover:play()
end

function SoundFX.iris()
    iris:play()
end

return SoundFX