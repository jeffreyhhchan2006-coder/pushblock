require "transitions.scene_lookup"

local transition = {}

-- Initalize local transition variables here
local time = 0
local transition_transparency = 0
local transition_transparency_rate = 8
--strings of file paths of scenes in the scenes folder
local current_scene = SSM.current
local next_scene = TM.params
local is_fade_in = false
local time_limit = 3
local floor_time = -1
local game_start = false


function transition.load()
	--playSFX(score_sound)
end

function transition.update(dt)
	if not(is_fade_in) then
		if transition_transparency < 1 then
			transition_transparency = transition_transparency + transition_transparency_rate*dt
		else
			SSM.remove(current_scene)
			TM.result(TM.params)
			is_fade_in = true
		end
	else 
		time = time + dt
		if time > dt then
			SSM.setFrozen(SSM.current,true) --pauses game during countdown
		end
		if transition_transparency > 0 then
			transition_transparency = transition_transparency - transition_transparency_rate*dt
		end
		
		if math.floor(time) > floor_time then
			playSFX(score_sound)
		end
		
		if time > time_limit then
			SSM.setFrozen(SSM.current,false)
			game_start = true
		end
		
		if time > time_limit + 1 then
			TM.unload("fade-in-to-countdown") --resumes game once countdown is over
		end
		floor_time = math.floor(time)
	end
end

function transition.draw()
	love.graphics.setColor(0,0,0,transition_transparency)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	
	if is_fade_in then
		love.graphics.setColor(1,1,1)
		local font = love.graphics.newFont("fonts/PixelCards.ttf", love.graphics.getHeight()/10)
		love.graphics.setFont(font)
		if game_start then
			love.graphics.setColor(1,1,1, 1 - (time - time_limit))
			love.graphics.print("GO",love.graphics.getWidth()/2,love.graphics.getHeight()/2)
		elseif time ~= 0 then
			love.graphics.print(math.floor(4 - time),love.graphics.getWidth()/2,love.graphics.getHeight()/2)
		end
	end
	--grid_from:draw()
	--grid_to:draw()
end

return transition
