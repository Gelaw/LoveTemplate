--------------------------------------------------------------------
-- tests/unit/audio_test.lua : tests UNITAIRES — gestionnaire audio
-- avec sources mockées (on vérifie play/stop/volume/looping).
--------------------------------------------------------------------
local harness = require("tests.lib.harness")
local mock = require("tests.lib.mock_backend")

harness.describe("core.audio", function()

  local m = mock.new()
  core.attach(m.backend)
  local audio = core.audio

  harness.it("loadMusic/playMusic : source active, bouclée, au bon volume", function()
    local src = audio.loadMusic("theme", "music/theme.ogg")
    harness.assert_true(src.mockSource)
    audio.playMusic(src)
    harness.assert_eq(audio.music, src)
    harness.assert_true(src.playing)
    harness.assert_true(src.looping)
    harness.assert_eq(src.volume, audio.musicVolume)
  end)

  harness.it("playMusic deux fois : la première est stoppée et rembobinée", function()
    local src1 = audio.loadMusic("m1", "a.ogg")
    local src2 = audio.loadMusic("m2", "b.ogg")
    audio.playMusic(src1)
    audio.playMusic(src2)
    harness.assert_false(src1.playing)
    harness.assert_eq(src1.position, 0)
    harness.assert_eq(audio.music, src2)
  end)

  harness.it("playMusic avec la même source : no-op", function()
    local src = audio.loadMusic("m3", "c.ogg")
    audio.playMusic(src)
    local pos = src.position
    audio.playMusic(src) -- ne doit pas stopper/rejouer
    harness.assert_eq(audio.music, src)
  end)

  harness.it("toggleMute coupe puis restaure", function()
    local src = audio.loadMusic("m4", "d.ogg")
    audio.mute = false
    audio.playMusic(src)
    audio.toggleMute(true)
    harness.assert_true(audio.mute)
    audio.toggleMute(false)
    harness.assert_false(audio.mute)
    harness.assert_true(audio.music.playing)
  end)

  harness.it("changeMusicVolume propagé à la source courante", function()
    local src = audio.loadMusic("m5", "e.ogg")
    audio.playMusic(src)
    audio.changeMusicVolume(0.42)
    harness.assert_eq(src.volume, 0.42)
    harness.assert_eq(audio.musicVolume, 0.42)
  end)

  harness.it("playSound clone et joue au volume SE", function()
    audio.muteSE = false
    local src = audio.loadSoundEffect("jump", "sfx/jump.wav")
    local clone = audio.playSound(src)
    harness.assert_true(clone.playing)
    harness.assert_eq(clone.volume, audio.SEVolume)
  end)

  harness.it("playSound muet : rien joué", function()
    audio.muteSE = true
    local src = audio.loadSoundEffect("nope", "sfx/nope.wav")
    local clone = audio.playSound(src)
    harness.assert_nil(clone)
    audio.muteSE = false
  end)

  harness.it("toggleMuteSE stoppe les sons en cours", function()
    local src = audio.loadSoundEffect("boom", "sfx/boom.wav")
    local clone = audio.playSound(src)
    harness.assert_true(clone.playing)
    audio.toggleMuteSE(true)
    harness.assert_false(clone.playing)
    harness.assert_eq(#audio.playingSounds, 0)
    audio.muteSE = false
  end)
end)

return harness
