block = object:new({

	--x and y coord for this is kinda useless since it should use assoc_square's coords
	player = 0,
	type = 1, --there are 6 types of blocks, each with different colour
	colour = {1,1,1,1}, --this for white,
	--booleans
	is_scored = false, --if block is scored, disable it?
	is_falling = false,
	is_selected = false,
	is_loopback = false,
	--shift block variables
	shift_block = 0,
	shift_time = 0,
	shift_wait = 0.1,
	--animation when block needs to appear blinking
	blink_time = 0,
	blink_interval = 0.2,
	--score animation duration
	score_time = 0,
	score_duration = 0.5,
	--address to square it's in
	assoc_square = {},
	
	draw = function (self)
		local square = self.assoc_square
		local margin = 10
		love.graphics.setColor(self.colour)
		
		if self.is_scored then
			if self.time % self.blink_interval > (self.blink_interval/2) then
				return
			end
		end
		
		--block itself
		love.graphics.rectangle( "fill", self.x+margin, self.y+margin, square.size - 2*margin, square.size - 2*margin) --should I just use assoc_square coords to save processing in updating said x coord?
		love.graphics.setColor({0,0,0,1})
		love.graphics.rectangle( "line", self.x+margin, self.y+margin, square.size - 2*margin, square.size - 2*margin) 
		
		--print shift block value
		love.graphics.setColor({0,0,0,1})
		love.graphics.print( self.shift_block, self.x+margin, self.y+margin)
	end
})

function block:new(obj)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.assoc_square = obj.assoc_square or {}
	obj:setColour()
	return obj
end

function block:setBlockToScore(playerID)
	self.player = playerID
	self.is_scored = true
	self.score_time = self.time
end

function block:setColour()
	--set color based on type
	--Since there is still white, make white the match with all colours type
	if self.type == 1 then
		self.colour = {0,1,1,1} --yellow
	elseif self.type == 2 then
		self.colour = {1,0,0,1} --red
	elseif self.type == 3 then
		self.colour = {0,1,0,1} --green
	elseif self.type == 4 then
		self.colour = {0,0,1,1} --blue
	elseif self.type == 5 then
		self.colour = {1,1,0,1} --orange?
	elseif self.type == 6 then
		self.colour = {1,0,1,1} --purple
	end
end	

function block:isSameType(other_block)
	if self.type == other_block.type or self.type == 0 or other_block.type == 0 then
		return true
	end
	return false
end

function block:piece_debug()
	print("-----start of block info-----")
	print(self.assoc_square.gridx..", "..self.assoc_square.gridy.." player: "..self.player)
	print("-----end of block info-----")
end

function block:isPieceBelow()
	local board = self.assoc_square.grid
	local gravity = board.gravity
	local belowX = self.assoc_square.gridx + gravity[1]
	local belowY = self.assoc_square.gridy + gravity[2]
	if outsideBoardBounds(board, belowX, belowY) then
		return true
	end
	if not board.contents[belowY][belowX]:isAssocBlockNil() then
		return true
	end
	return false
end

function block:findDirectOppositeBlocks() --pieces to your north, south, east, west
	local found_pieces = {}
	local x = self.assoc_square.gridx
	local y = self.assoc_square.gridy
	local board = self.assoc_square.grid --grid may not be properly initialised
	local function checkInsert(x,y)
		if board.contents[y][x].assoc_block:isSameType(self) then
			table.insert(found_pieces,board.contents[y][x].assoc_block)
		end
	end
	for i = -1,1,2 do 
		if not(x + i < 1 or x + i > board.rows) then --checks west / east pieces
			if next(board.contents[y][x + i].assoc_block) ~= nil then
				checkInsert(x + i,y)
			end
		end
		
		if not(y + i < 1 or y + i > board.columns) then --checks north / south pieces
			if next(board.contents[y + i][x].assoc_block) ~= nil then
				checkInsert(x,y + i)
			end
		end
	end
	return found_pieces
end

function block:update(dt) 
	self.time = self.time + dt
	
	--print("check if block is scored")
	if self.is_scored then
		print("score block")
		print("scored block time: "..self.time)
		print("scored block score time + duration:"..self.score_time + self.score_duration)
		if self.time > (self.score_time + self.score_duration) then
			-- remove block
			print("delete scored block")
			self.assoc_square:removeBlock(self.player)
			if SHIFT_BLOCKS_AFTER_SCORE then
				-- shift column 1 square to the right
				print("scored_block coords: "..self.assoc_square.gridx..", "..self.assoc_square.gridy)
				game_board:shiftRowAfterSquare(self.assoc_square.gridx,self.assoc_square.gridy)
			end
		end
		return
	end

	if self.shift_time > 0 then
		self.shift_time = self.shift_time - dt
	end
	if self.shift_block > 0 then
		print("block shift: "..self.shift_block)
		if self.shift_time <= 0 then
			self.shift_block = self.shift_block - 1
			self.shift_time = self.shift_wait
			self.assoc_square:moveBlock(self.assoc_square.grid.gravity,false)
		end
	end
	--update coords
	self.x = self.assoc_square.x
	self.y = self.assoc_square.y
end