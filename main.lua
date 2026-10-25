require "settings"
require "utilities"
require "load_sound"

SSM = require "libraries/scene_libraries/StackingSceneMgr/lib.StackingSceneMgr".newManager()
SSM.setPath("scenes/")

TM = require "libraries/scene_libraries/TransitionMgr/lib.TransitionMgr".newManager()
TM.setPath("transitions/")

--Main: (order intended)
	-- load
		-- sets Fullscreen
		-- sets player colours
		-- loads music through load_music
		-- loads sound through load_sound
		-- adds start scene
	-- update
		-- update scene
		-- update transition 
		-- [commented out: lag profiling update]
	--draw
		-- draw scene
		-- draw transition
		-- [commented out: draw lag profiling]
	
function love.load()
	-- lag profiling
	-- love.profiler = require('libraries/lag_profiling/profile') 
	-- love.profiler.start()
	love.window.setFullscreen(true, "desktop")
	love.graphics.setDefaultFilter("nearest")
	player_colors = {changeColorBrightness({68/255, 238/255, 201/255, 1},-0.1),changeColorBrightness({238/255, 66/255, 102/255, 1},-0.1)}
	load_music()
	load_sound()
	delta_time = 0
	SSM.add("start")
end

function love.keypressed(key, scancode, isrepeat )
	if scancode == "escape" then
		love.event.quit()
	end
end
love.frame = 0
function love.update(dt)
	SSM.update(dt)
	TM.update(dt)
	collectgarbage()
	delta_time = dt
	-- lag profiling
	-- love.frame = love.frame + 1
	-- if love.frame%100 == 0 then
		-- love.report = love.profiler.report(20)
		-- love.profiler.reset()
	-- end
end

function love.draw()
	SSM.draw()
	TM.draw()
	if DEBUG_MODE then
		love.graphics.print(delta_time)
	end
	-- lag report
	-- love.graphics.print(love.report or "Please wait...")
end