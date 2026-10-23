require "grid"
require "board_block"

boardSquare = gridSquare:new({
	grid = {},
	assoc_block = {}, --for block block
	remove_block_oob = false, --bad implementation, block need to settle first before scoring I guess
	gravity = {0,1},
	draw = function (self) --doesn't draw
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
		if next(self.assoc_block) ~= nil then 
			self.assoc_block:draw(self)
		end
	end
})

function boardSquare:new(obj)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.assoc_block = {}
	return obj
end

function boardSquare:isAssocBlockNil()
	if next(self.assoc_block) == nil or self.assoc_block == nil then return true end
	return false
end

function boardSquare:setBlock(type, player, is_loopback)
	print("setting block")
	player = player or 0
	is_loopback = is_loopback or false
	self.assoc_block = block:new({x = self.x, y = self.y, assoc_square = self, type = type, player = player, is_falling = true, is_loopback = is_loopback})
	print("set block of type "..type.." on "..self.gridx..", "..self.gridy)
end

function boardSquare:removeBlock(player)
	self.assoc_block = {}
	print("player "..player.." removed block on "..self.gridx..", "..self.gridy)
end

function boardSquare:pushBlock(player, game_board)
	--add block to game_board
	--set block to player
	print("pushing block: ")
	if self:isAssocBlockNil() then return end
	if not game_board.contents[self.gridy][1]:isAssocBlockNil() then
		--add sound to indicate players can't place there
		return 
	end 
	game_board.contents[self.gridy][1]:setBlock(self.assoc_block.type, player)
	self:removeBlock(player)
	print("player "..player.." push block on row "..self.gridy)
end


function boardSquare:moveBlock(direction)
	if self:isAssocBlockNil() then return end
	--print("check block can move on "..self.gridy)
	local newX, newY = self.gridx + direction[1], self.gridy + direction[2]
	if outsideBoardBounds(self.grid, newX, newY) then 
		if not self.remove_block_oob then return end
		print("removing block")
		self:removeBlock(self.assoc_block.player) 
	end --add something like a socring system?
	local newSquare = self.grid.contents[newY][newX]
	if next(newSquare.assoc_block) ~= nil then return end
	--print("move block "..self.gridy)
	newSquare.assoc_block = copy(self.assoc_block) 
	newSquare.assoc_block.assoc_square = newSquare
	newSquare.assoc_block.x = newSquare.x
	newSquare.assoc_block.y = newSquare.y
	self.assoc_block = {}
end

function boardSquare:shiftBlock(val) --tells block to shift according to gravity without
	if self:isAssocBlockNil() then return end
	self.assoc_block.shift_block = self.assoc_block.shift_block + val
	self.assoc_block.shift_time = self.assoc_block.shift_wait
end

function boardSquare:switchBlocks(player) --works now
	print("switch blocks")
	
	--addresses
	
	
	local original_square = self
	local switch_square = player.selected_block.assoc_square
	
	local original_block = original_square.assoc_block:new({assoc_square = switch_square}) --causes crash
	local switch_block = switch_square.assoc_block:new({assoc_square = original_square})
	
	local board = self.grid
	local playerID = player.player
	
	original_square:removeBlock(playerID)
	switch_square:removeBlock(playerID)
	
	original_square.assoc_block = switch_block
	switch_square.assoc_block = original_block
	player.selected_block = switch_block
	
	
	-- change square addresses
	-- board.contents[original_square.gridy][original_square.gridx].assoc_square = switch_square
	-- board.contents[switch_square.gridy][switch_square.gridx].assoc_square = original_square
	-- change block addresses
	-- board.contents[original_square.gridy][original_square.gridx].assoc_square.assoc_block = switch_block
	-- board.contents[switch_square.gridy][switch_square.gridx].assoc_square.assoc_block = original_block
end

function boardSquare:findDirectOppositeSquares() --blocks to your north, south, east, west
	local found_squares = {}
	local x = self.gridx
	local y = self.gridy
	local board = self.grid --grid may not be properly initialised
	for i = -1,1,2 do 
		if not(x + i < 1 or x + i > board.rows) then --checks west / east blocks
			table.insert(found_squares,board.contents[y][x + i])
		end
		
		if not(y + i < 1 or y + i > board.columns) then --checks north / south blocks
			table.insert(found_squares,board.contents[y + i][x])
		end
	end
	return found_squares
end

function boardSquare:highlight(player)
	local color = changeColorBrightness(player_colors[player],0.5)
	color[4] = 0.25
			
	love.graphics.setColor(color)
	love.graphics.rectangle("fill",self.x,self.y,self.size,self.size)
end

function boardSquare:update(dt)
	self.time = self.time + dt
	
	if next(self.assoc_block) == nil then --used when self.assoc_block is a pointer to another block
		self.assoc_block = {}
	end
	
	--self:moveBlock(self.gravity) --move blocks vertically if have space
	
	if not self:isAssocBlockNil() then
		self.assoc_block:update(dt)
	end
end