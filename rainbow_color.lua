require "utilities"

rainbow_color = {
	time = 0,
	time_to_change = 0.1,
	color = {1,1,1}
}

function rainbow_color:update(dt)
	self.time = self.time + dt
	if self.time < self.time_to_change then
		return
	end
	local type = getRandomType()
	if type > 0 then
		self.color = changeColorBrightness(color_palettes.blocks[type],0.3)
	else
		self.color = {1,1,1}
	end
	self.time = 0
end

function rainbow_color:get()
	return self.color
end