require "grid"
require "game_board_square"

game_board = grid:new(
	{	
		dropped_blocks = {},
		gravity = {1,0},
		player_area = 8		--x value
	}, 
	game_boardSquare --seperate square needed?
)

function game_board:new(obj,squareClass)
	local obj = obj or {} 
	setmetatable(obj, self)
	self.__index = self
	obj.contents = {}
	obj.dropped_blocks = {}
	obj.square_size = obj.size / obj.rows
	for y=1,obj.columns do
		table.insert(obj.contents,{})
		for x=1,obj.rows do
			table.insert(obj.contents[y],squareClass:new({
			grid = obj, 
			size = obj.square_size,
			x = obj.x + (x-1)*(obj.square_size), 
			y = obj.y + (y-1)*(obj.square_size),
			gridx = x, 
			gridy = y
			}))
		end
	end
	-- print("grid rows: "..obj.rows)
	-- print("grid columns: "..obj.columns)
	-- print("length of row 1: "..#obj.contents[1])
	return obj
end

--idk how fucky this is
function game_board:update(dt)
	self.square_size = self.size / self.rows
	for x=self.rows,1,-1 do
		for y=1,self.columns do
			self.contents[y][x].size = self.square_size
			self.contents[y][x].x = self.x + (x-1)*(self.square_size)
			self.contents[y][x].y = self.y + (y-1)*(self.square_size)
			self.contents[y][x]:update(dt)
		end
	end
end

function game_board:checkLoseCondition()
	local is_lose = true
	for y=1,self.columns do
		for x=self.rows,1,-1 do
			--check lose condition
			if self.contents[y][x]:isAssocBlockNil() then
				is_lose = false
			end
		end
	end
	return is_lose
end

function game_board:checkGameCondition()
	local how_much_filled = 0
	for y=1,self.columns do
		for x=self.rows,1,-1 do
			--check lose condition
			if not self.contents[y][x]:isAssocBlockNil() then
				how_much_filled = how_much_filled + 1
			end
		end
	end
	return how_much_filled / (self.player_area * self.columns)
end

function game_board:checkRowIsFilled(y)
	local how_much_filled = 0
	for x=self.rows,1,-1 do
		if not self.contents[y][x]:isAssocBlockNil() then
			how_much_filled = how_much_filled + 1
		end
	end
	if how_much_filled == self.rows then
		return true
	else
		return false
	end
end

--game board functions
function game_board:shiftRowAfterSquare(x,y) --shift row forwards
	print("-----START OF SHIFT ROW-----")
	print("shift row "..y.." after square "..x..", "..y)
	for i=#self.contents[y],1,-1 do
		print("checking block "..i..", "..y)
		if i <= x then print("-----END OF SHIFT ROW-----") return end
		self.contents[y][i]:shiftBlock(1)
	end
end

function game_board:removeDroppedBlock(x,y)
	for i=#self.dropped_blocks,1,-1 do
		if self.dropped_blocks[i].assoc_square == nil then
			table.remove(self.dropped_blocks,i)
			goto continue
		end
		
		--print("removed dropped block i: "..i)
		--print("size of dropped blocks: "..#self.dropped_blocks)
		
		if self.dropped_blocks[i].assoc_square.gridx == x and self.dropped_blocks[i].assoc_square.gridy == y then
			table.remove(self.dropped_blocks,i)
		end
		:: continue ::
	end
end

function game_board:checkDroppedBlocks()
	-- print("checking dropped blocks: size "..#self.dropped_blocks)
	-- remove dropped blocks with nil assoc squares
	for i=#self.dropped_blocks,1,-1 do
		if self.dropped_blocks[i].assoc_square == nil then
			table.remove(self.dropped_blocks,i)
		end
	end
	-- check whether any dropped block is falling, if so, don't matchBlocks
	for i,b in pairs(self.dropped_blocks) do
		-- print("block "..i..": "..b.assoc_square.gridx..", "..b.assoc_square.gridy)
		if b.is_falling then return end
	end
	-- match blocks for remaining blocks
	for i=#self.dropped_blocks,1,-1 do
		self.dropped_blocks[i].assoc_square:matchBlocks()
		table.remove(self.dropped_blocks,i)
	end
end

-- function game_board:checkFallingBlocks()
	-- check if blocks are falling
	-- for y=1,self.columns do
		-- for x=self.rows,1,-1 do
			-- check lose condition
			-- if not self.contents[y][x]:isAssocBlockNil() then
				-- if self.contents[y][x].assoc_block.is_falling then
					-- return true
				-- end
			-- end
		-- end
	-- end
	-- return false
-- end

-- function game_board:checkMatchBlock()
	-- after no blocks are falling, check matches
	-- for y=1,self.columns do
		-- for x=self.rows,1,-1 do
			-- check lose condition
			-- if not self.contents[y][x]:isAssocBlockNil() then
				-- self.contents[y][x]:matchBlocks()
			-- end
		-- end
	-- end
-- end