local music = {}

local ingameMusic = love.audio.newSource('assets/music/pesma.wav', 'stream')
local menuMusic = love.audio.newSource('assets/music/menulobby.wav', 'stream')

music.ingameMusic = ingameMusic
music.menuMusic = menuMusic

function music.load()
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.2)
    menuMusic:play()

    ingameMusic:setLooping(true)
    ingameMusic:setVolume(0.15) 
end

function music.setVolume(volume)
    menuMusic:setVolume(volume)
    ingameMusic:setVolume(volume* 0.75)
end

return music