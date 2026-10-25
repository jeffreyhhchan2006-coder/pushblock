

player = object:new({ --crash after transition to spell_menu
	gridx = 1,
	gridy = 1, --index by 1 since tables are also
	player = 1,
	colour = {1,1,1},
	--scoring
	score = 0,
	blocks_scored = 0,
	combo = 1,
	max_combo = 0,
	combo_time = 0,
	combo_time_limit = 1,
	--controls
	cooldown_time = 0.06,
	input_delay = 0.04,
	control_map = {
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		select = "k",
		push = "j",
		pushAll = "space"
	},
	idle_time = 0,
	idle_duration = 10, --if player doesn't move for 10 seconds, start removing influence
	move_delay = 0, --for input delay, once move delay reaches input delay, inputs would be executed
	move_cooldown = 0, --after inputs executed, have cooldown before inputs are accepted again (linked to cooldown_time)
	inputs = {},
	--Board
	assoc_board = {},
	assoc_game_board = {},
	selected_block = {}
})

function player:new(obj)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.inputs = {}
	obj.selected_block = {}
	return obj
end


function player:draw(size) --only draws the cursor
	-- if self.player == 1 then
		-- love.graphics.setColor(player_colors[1])
	-- elseif self.player == 2 then
		-- love.graphics.setColor(1,0,0)
	-- end
	love.graphics.setColor(self.colour)
	local cursor_size = size * 0.9
	local cursor_margin = (size - cursor_size)/2
	love.graphics.setLineWidth(5)
	love.graphics.rectangle("line", self.x + cursor_margin, self.y + cursor_margin, cursor_size, cursor_size)
	love.graphics.setLineWidth(1)
	
	
	--draw a right angled triangle instead, player 1 on top left, player 2 on bottom right
	local triangle_length = cursor_size/2
	if next(self.selected_block) == nil then return end
	
	love.graphics.setColor(self.selected_block.colour)
	
	if self.player == 1 then
		love.graphics.rectangle("fill", self.x + cursor_margin, self.y + cursor_margin, triangle_length, triangle_length)
		love.graphics.setColor({0,0,0})
		love.graphics.rectangle("line", self.x + cursor_margin, self.y + cursor_margin, triangle_length, triangle_length)
		-- love.graphics.polygon(
			-- "fill", 
			-- self.x,self.y,
			-- self.x + cursor_margin + triangle_length,self.y + cursor_margin, 
			-- self.x + cursor_margin + triangle_length,self.y + cursor_margin + triangle_length, 
			-- self.x + cursor_margin,self.y + cursor_margin + triangle_length
		-- )
	else
		love.graphics.polygon(
			"fill", 
			self.x + size - cursor_margin - triangle_length,self.y + size - cursor_margin, 
			self.x + size - triangle_length - cursor_margin,self.y + size - triangle_length - cursor_margin,
			self.x + size - cursor_margin,self.y + size - triangle_length - cursor_margin
		)
	end
end

function player:move(board,x,y) --reuse for menu control
	if (self.gridx > 1 and x < 0) or (self.gridx < board.rows and x > 0) then
		self.gridx = self.gridx + x
		playSFX(move_sfx)
	end
	if (self.gridy > 1 and y < 0) or (self.gridy < board.columns and y > 0) then
		self.gridy = self.gridy + y
		playSFX(move_sfx)
	end
end

function player:addScore(val)
	self.score = self.score + val*self.combo
	self.assoc_board:changeExpungeWait(self.score)
end

function player:setCombo()
	self.combo = self.combo + 1
	self.combo_time = self.combo_time_limit
end

function player:updateCombo(dt)
	if self.combo_time <= 0 then
		if self.combo > self.max_combo then
			self.max_combo = self.combo
		end
		self.combo = 1
	else
		self.combo_time = self.combo_time - dt
	end
end

function player:pushBlock(board)
	board.contents[self.gridy][self.gridx]:pushBlock(self.player, self.assoc_game_board) --keep using player for multiplayer
	self.selected_block = {}
end

function player:selectBlock(board) --not tested
	if next(self.selected_block) == nil then
		self.selected_block = board.contents[self.gridy][self.gridx].assoc_block --keep using player for multiplayer
	else
		self.selected_block = {}
	end
end

function player:selectedBlockSwitch(board)
	local block = self.selected_block
	--print("player coords: "..self.gridx..", "..self.gridy)
	--print("block coords: "..block.assoc_square.gridx..", "..block.assoc_square.gridy)
	--not issue with constant switching
	if self.gridx == block.assoc_square.gridx and self.gridy == block.assoc_square.gridy then return end
	--if selected block is not equal to player coords then
	print("player and selected block have different coords, switch blocks")
	board.contents[self.gridy][self.gridx]:switchBlocks(self)
end

function player:interact(board) --for when player presses place button in game (function would be changed for menu cursor
	self:selectBlock(board) --keep using plyaer for multiplayer
end

function player:readInput(input)
	for i,c in pairs(self.inputs) do
		if c == input then 
			if not love.keyboard.isDown(input) then
				table.remove(self.inputs,i)
			end
			return
		end
	end
	if love.keyboard.isDown(input) then
		table.insert(self.inputs,input)
	end
end

function player:controls_read(controls,board,dt)
	if self.move_cooldown > 0 then
		return
	end
	if self.move_delay > 0 then
		self:readInput(controls.push)
		self:readInput(controls.pushAll)
		self:readInput(controls.up)
		self:readInput(controls.down)
		self:readInput(controls.left)
		self:readInput(controls.right)
		self:readInput(controls.select)
	end
end

function player:controls_act(controls,board,dt) --board is assoc_board
	local x = 0
	local y = 0
	for i,c in pairs(self.inputs) do
		if c == controls.select then
			if next(self.selected_block) ~= nil then
				self:selectedBlockSwitch(board)
				self.selected_block = {}
			else
				self:interact(board)
			end
		elseif c == controls.up then
			y = -1
		elseif c == controls.down then
			y = 1
		elseif c == controls.left then
			x = -1
		elseif c == controls.right then
			x = 1
		elseif c == controls.push then 
			self:pushBlock(board)
		elseif c == controls.pushAll then 
			board:ExpungeBlocks()
		end
	end
	self:move(board,x,y)
	self.move_cooldown = self.cooldown_time
	self.move_delay = self.input_delay
	self.inputs = {}
end



function player:controls_update(controls,board,dt)
	if self.move_delay > 0 and next(self.inputs) ~= nil then
		self.move_delay = self.move_delay - dt
	end
	
	if self.move_cooldown > 0 then
		self.move_cooldown = self.move_cooldown - dt
		return
	end
	
	if self.move_delay <= 0 then
		self:controls_act(controls,board,dt)
	end
end



function player:update(dt)
	local board = self.assoc_board
	self.time = self.time + dt
	--update combo
	self:updateCombo(dt)
	--update player coords
	self.x = board.x + (self.gridx-1)*board.square_size
	self.y = board.y + (self.gridy-1)*board.square_size

	self:controls_read(self.control_map,board,dt)
	self:controls_update(self.control_map,board,dt)
	
	if self.assoc_board.expunge_time <= 0 then
		self.selected_block = {}
	end
	-- if next(self.selected_block) ~= nil then
		-- local sbsquare = self.selected_block.assoc_square
		-- print("selected block coords: "..sbsquare.gridx..", "..sbsquare.gridy)
	-- end
end