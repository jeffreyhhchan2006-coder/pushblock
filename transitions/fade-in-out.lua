require "transitions.scene_lookup"

local transition = {}

-- Initalize local transition variables here
local time = 0
local transition_transparency = 0
local transition_transparency_rate = 6
--strings of file paths of scenes in the scenes folder
local current_scene = SSM.current
local next_scene = TM.params
local is_fade_in = false


function transition.load()
	
end

function transition.update(dt)
	time = time + dt
	if not(is_fade_in) then
		if transition_transparency < 1 then
			transition_transparency = transition_transparency + transition_transparency_rate*dt
		else
			SSM.remove(current_scene)
			TM.result(TM.params)
			is_fade_in = true
		end
	else 
		if transition_transparency > 0 then
			transition_transparency = transition_transparency - transition_transparency_rate*dt
		else
			TM.unload("fade-in-out")
		end
	end
end

function transition.draw()
	love.graphics.setColor(0,0,0,transition_transparency)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	--grid_from:draw()
	--grid_to:draw()
end

return transition
