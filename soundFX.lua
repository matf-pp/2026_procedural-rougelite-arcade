local SoundFX = {}

local volume = 0.05

local pebble
local death
local select
local hover
local iris
local dash
local freeze
local phase

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
    dash = love.audio.newSource('assets/soundFX/dash.wav', 'stream')
    dash:setVolume(volume)
    freeze = love.audio.newSource('assets/soundFX/freeze.wav', 'stream')
    freeze:setVolume(volume)
    phase = love.audio.newSource('assets/soundFX/phase.wav', 'stream')
    phase:setVolume(volume)
end

function SoundFX.getVolume()
    return volume
end
function SoundFX.setVolume(vlm)
    volume = vlm
    pebble:setVolume(volume)
    death:setVolume(volume)
    select:setVolume(volume)
    hover:setVolume(volume)
    iris:setVolume(volume)
    dash:setVolume(volume)
    freeze:setVolume(volume)
    phase:setVolume(volume)
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

function SoundFX.dash()
    dash:play()
end

function SoundFX.freeze()
    freeze:play()
end

function SoundFX.phase()
    phase:play()
end

return SoundFX