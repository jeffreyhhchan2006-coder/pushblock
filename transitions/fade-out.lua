require "grid"
require "transitions.scene_lookup"

local transition = {}

-- Initalize local transition variables here
local time = 0
local transition_duration = 1
local transition_start_transparency = 0
local transition_start_transparency_rate = 1 / transition_duration
local transition_end_transparency = 0
local transition_end_transparency_rate = 1 / transition_duration
--strings of file paths of scenes in the scenes folder
local current_scene = SSM.current
local next_scene = TM.params

local current_scene_params = {rows = 0, columns = 0}
local next_scene_params = {rows = 0, columns = 0}
--grids are for being drawn only
local grid_from = {}
local grid_to = {}

--transition from one size grid to another (e.g. from 7x7 to 5x5 or vice versa)

function transition.load()
	for i,s in pairs(scene_lookup) do
		if current_scene == s[1] then
			current_scene_params.rows = s[2] 
			current_scene_params.columns = s[2] 
		end
		if next_scene == s[1] then
			next_scene_params.rows = s[2] 
			next_scene_params.columns = s[2] 
		end
	end
	grid_from = grid:new({rows = 7, columns = 7},gridSquare)
	grid_to = grid:new({rows = 5, columns = 5, size = grid_from.rows*((love.graphics.getHeight() * 0.9)/5)},gridSquare) --make sure the to grid's squares are of equal size to grid_from
end

function transition.update(dt)
	time = time + dt
	if transition_start_transparency < transition_duration then
		transition_start_transparency = transition_start_transparency + transition_start_transparency_rate*dt
	else
		if transition_end_transparency < transition_duration then
			transition_end_transparency = transition_end_transparency + transition_end_transparency_rate*dt
		else
			SSM.remove(current_scene)
			TM.result(TM.params)
			TM.unload("fade-out")
		end
	end
end

function transition.draw()
	love.graphics.setColor(0,0,0,transition_start_transparency)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	--grid_from:draw()
	--grid_to:draw()
end

return transition
