score_popups = {}
combo_popups = {}

score_popup = object:new({
	time_limit = 0.5,
	combo = 0,
	score = 0,
	assoc_list = {},
	--animation when block needs to appear blinking
	blink_time = 0,
	blink_interval = 0.1,
	font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/22),
	large_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/20),
	draw = function (self)
		if self.time % self.blink_interval > (self.blink_interval/2) then
			return
		end
		local text = self.score.."\nX "..self.combo
		--scale popup depending on score? IDK how to implement
		love.graphics.setColor(0.4,0.4,0.4)
		love.graphics.setFont(self.large_font)
		love.graphics.print(text,self.x - self.font:getWidth(text)/2,self.y - self.font:getHeight())
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(self.font)
		love.graphics.print(text,self.x - self.font:getWidth(text)/2,self.y - self.font:getHeight())
	end
})

function addScorePopup(x,y,score,combo)
	table.insert(score_popups,score_popup:new({
		x = x,
		y = y,
		score = score,
		combo = combo,
		assoc_list = score_popups
	}))
	playSFX(score_sfx)
end

function updateScorePopups(dt)
	for i,s in pairs(score_popups) do
		s:update(dt)
		if s.time > s.time_limit then
			table.remove(score_popups,i)
		end
	end
end

function drawScorePopups(dt)
	for i,s in pairs(score_popups) do
		s:draw(dt)
	end
end

combo_popup = score_popup:new({
	time_limit = 1,
	blink_time = 0,
	blink_interval = 0,
	font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/6),
	large_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/6.5),
	draw = function (self)
		if self.time % self.blink_interval > (self.blink_interval/2) then
			return
		end
		local text = "COMBO: "..self.combo-1 --self.combo starts as 1, so need to subtract 1
		--scale popup depending on score? IDK how to implement
		local combo_brightness_mod = 0.3 - 0.7*self.combo/10
		love.graphics.setColor(changeColorBrightness(rainbow_color:get(),-0.6 + combo_brightness_mod))
		love.graphics.setFont(self.large_font)
		love.graphics.print(text,love.graphics.getWidth()/2 - self.large_font:getWidth(text)/2,love.graphics.getHeight()/2 - self.large_font:getHeight()/1.5)
		love.graphics.setColor(changeColorBrightness(rainbow_color:get(), combo_brightness_mod))
		love.graphics.setFont(self.font)
		love.graphics.print(text,love.graphics.getWidth()/2 - self.font:getWidth(text)/2,love.graphics.getHeight()/2 - self.font:getHeight()/1.5)
	end
})

function addComboPopup(combo)
	table.insert(combo_popups,combo_popup:new({
		combo = combo,
		assoc_list = combo_popups
	}))
	playSFX(combo_sfx)
end

function updateComboPopup(dt)
	for i,s in pairs(combo_popups) do
		s:update(dt)
		if s.time > s.time_limit then
			table.remove(combo_popups,i)
		end
	end
end

function drawComboPopups(dt)
	for i,s in pairs(combo_popups) do
		s:draw(dt)
	end
end