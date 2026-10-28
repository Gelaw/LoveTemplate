--------------------------------------------------------------------
-- core/audio.lua : gestionnaire audio (musiques + effets).
-- Le chargement et le jeu passent par le backend (testable via mock :
-- on asserte quelles sources ont été jouées, à quel volume).
--------------------------------------------------------------------
local audio = {
  musics = {},
  musicVolume = .05,
  mute = false,
  music = nil,
  sounds = {},
  SEVolume = 0.05,
  muteSE = false,
  playingSounds = {},
}

function audio.loadMusic(name, path)
  audio.musics[name] = core.api().newSource(path, 'stream')
  return audio.musics[name]
end

function audio.playMusic(source)
  if audio.music == source then return end
  if audio.music then
    audio.music:stop()
    audio.music:seek(0)
  end
  audio.music = source
  source:play()
  if audio.mute then source:pause() end
  source:setVolume(audio.musicVolume)
  source:setLooping(true)
end

function audio.toggleMute(forced)
  audio.mute = forced or not audio.mute
  if audio.mute then
    core.api().pauseAll()
  elseif audio.music then
    audio.music:play()
  end
end

function audio.changeMusicVolume(newVolume)
  audio.musicVolume = newVolume
  if audio.music then
    audio.music:setVolume(audio.musicVolume)
  end
end

function audio.loadSoundEffect(name, path)
  audio.sounds[name] = core.api().newSource(path, 'static')
  return audio.sounds[name]
end

function audio.playSound(sound)
  if audio.muteSE then return nil end
  local clone = sound:clone()
  clone:setVolume(audio.SEVolume)
  table.insert(audio.playingSounds, clone)
  clone:play()
  audio.cleanPlayingSounds()
  return clone
end

function audio.toggleMuteSE(forced)
  audio.muteSE = forced or not audio.muteSE
  for s, sound in pairs(audio.playingSounds) do
    sound:stop()
  end
  audio.playingSounds = {}
end

function audio.changeSEVolume(newVolume)
  audio.SEVolume = newVolume
  for s, sound in pairs(audio.playingSounds) do
    sound:setVolume(newVolume)
  end
end

function audio.cleanPlayingSounds()
  for s = #audio.playingSounds, 1, -1 do
    if not audio.playingSounds[s]:isPlaying() then
      table.remove(audio.playingSounds, s)
    end
  end
end

return audio
