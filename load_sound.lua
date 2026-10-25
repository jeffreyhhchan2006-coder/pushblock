masterVolume = 0.5 -- Maximum volume for all sounds
sfxVolume = 1
musicVolume = 0.5

function load_sound()
	expunge_sfx = love.audio.newSource("assets/audio/sfx/A01.wav", "static")
	push_sfx = love.audio.newSource("assets/audio/sfx/A02.wav", "static")
	move_sfx = love.audio.newSource("assets/audio/sfx/A03.wav", "static")
end

function load_music()
	title_music = love.audio.newSource("assets/audio/music/title.wav", "stream")
	intro_music = love.audio.newSource("assets/audio/music/intro.wav", "stream")
	--for TESound
	calm_music = love.audio.newSource("assets/audio/music/calm_loop.wav", "stream")
	good_music = love.audio.newSource("assets/audio/music/good_loop.wav", "stream")
	ok_music1 = love.audio.newSource("assets/audio/music/ok_loop1.wav", "stream")
	ok_music2 = love.audio.newSource("assets/audio/music/ok_loop2.wav", "stream")
	bad_music = love.audio.newSource("assets/audio/music/bad_loop.wav", "stream")
	very_bad_music = love.audio.newSource("assets/audio/music/very_bad_loop.wav", "stream")
	game_over_music = love.audio.newSource("assets/audio/music/game_over.wav", "stream")
end

function playSFX(sfx)
	local sound = sfx:clone()
	sound:setVolume(masterVolume * sfxVolume)
	love.audio.play(sound)
end

function playLoopMusic(music)
	music:setVolume(masterVolume * musicVolume)
	if not music:isPlaying( ) then
		print("loop music")
		love.audio.play(music)
	end
end
