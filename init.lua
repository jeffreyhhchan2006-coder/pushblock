require "utilities"
require "grid"
require "board_square"

function load_players()
	table.insert(players, player:new({player = 1, assoc_board = block_board, assoc_game_board = game_board}))
	--No multiplayer for now
end

function load_board()
	blocks_scored_to_be_animated = {}
	
	function updateScoredBlocks(dt,game_board)
		for i, scored_block in pairs(blocks_scored_to_be_animated) do
			scored_block:update(dt)
			if scored_block.assoc_square:isAssocBlockNil() then
				table.remove(blocks_scored_to_be_animated, i)
				i = i - 1
			end
		end
	end
	
	--game board
	game_boardSquare = boardSquare:new()
	function game_boardSquare:update(dt)
		self.time = self.time + dt
		
		if not self:isAssocBlockNil() then
			self.assoc_block:update(dt)
		else
			return
		end
		
		--this should just run once?
		if self.gridx < self.grid.player_area then --if not floor, move block
			self:moveBlock(self.grid.gravity, false) --move blocks vertically if have space
		end
	end
	
	function game_boardSquare:draw() --doesn't draw
		if self.gridx > self.grid.player_area then
			love.graphics.setColor(0.2,0.2,0.2)
			love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
		end
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
		if next(self.assoc_block) ~= nil then 
			self.assoc_block:draw(self)
		end
	end
	
	function game_boardSquare:moveBlock(direction, is_stop_at_player_area)
		if is_stop_at_player_area == nil then
			is_stop_at_player_area = true
		end
		local ooB = false
		if self:isAssocBlockNil() then 
			return 
		end
		if is_stop_at_player_area then 
			print("Block "..self.gridx.. ","..self.gridy.." would stop at player area: "..self.grid.player_area) 
		end
		--checks for if block can even move downwards
		--check if block would go out of bounds
		local newX, newY = self.gridx + direction[1], self.gridy + direction[2]
		if outsideBoardBounds(self.grid, newX, newY) then
			print("Block "..self.gridx.. ","..self.gridy.." would be moved outside of bounds to "..newX..", "..newY)
			print("Get block back to the top")
			self.grid.contents[self.gridy][1]:setBlock(self.assoc_block.type, 1)
			print("Remove block")
			self:removeBlock(0)
			return
		end
		--check if block would go under the ground when its not supposed to
		if (newX > self.grid.player_area and is_stop_at_player_area) then
			--print("Block "..self.gridx.. ","..self.gridy.." would be moved outside of player area to "..newX..", "..newY)
			game_board:matchBlocks() --fucked change
			return
		end
		--check if block has another block below them
		if self.assoc_block:isPieceBelow() then
			--print("Block "..self.gridx.. ","..self.gridy.." would be moved onto another block")
			game_board:matchBlocks()
			return
		end
		
		print("Block "..self.gridx..", "..self.gridy.." affected by gravity...")
		
		local newSquare = self.grid.contents[newY][newX]
		if next(newSquare.assoc_block) ~= nil then return end
		--print("move block "..self.gridy)
		newSquare.assoc_block = copy(self.assoc_block) 
		newSquare.assoc_block.assoc_square = newSquare
		newSquare.assoc_block.x = newSquare.x
		newSquare.assoc_block.y = newSquare.y
		self.assoc_block = {}
		print("block moved from "..self.gridx..","..self.gridy.." to "..newSquare.gridx..", "..newSquare.gridy)
		--self.grid:matchBlocks() --check whenever blocks move rather than always check, but idk why this lags more than updating it every dt
	end
	
	local middle_x = 360
	local middle_y = 80
	game_board = grid:new(
		{
			rows = 12, 
			columns = 8, 
			x = middle_x + 100,
			y = middle_y,
			size = 800,
			scaling_mult = 0.8,
			gravity = {1,0},
			player_area = 8 --x value
		}, 
		game_boardSquare --seperate square needed?
	)
	--idk how fucky this is
	function game_board:update(dt)
		-- if self.size == 0 then self.size = love.graphics.getHeight() * self.scaling_mult end
		self.square_size = self.size / self.rows
		for y=1,self.columns do
			for x=self.rows,1,-1 do
				self.contents[y][x].size = self.square_size
				self.contents[y][x].x = self.x + (x-1)*(self.square_size)
				self.contents[y][x].y = self.y + (y-1)*(self.square_size)
				self.contents[y][x]:update(dt)
			end
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
	
	function game_board:matchBlocks()
		for y,column in pairs(self.contents) do
			for x,square in pairs(column) do
				if next(square.assoc_block) == nil then goto continue end
				local playerID = square.assoc_block.player
				local is_loopback = false
				
				--finding connected blocks part
				local scoring_blocks = square.assoc_block:findDirectOppositeBlocks() --start of loop
				if #scoring_blocks > 0 then
					--print("found matching blocks to score for block "..square.gridx..", "..square.gridy)
					for i,scored_block in pairs(scoring_blocks) do
						local old_scoring_blocks_num = #scoring_blocks
						--print("size of scoring blocks in i="..i..": "..#scoring_blocks)
						local found_list = scored_block:findDirectOppositeBlocks() --get all nearby blocks for same type from blocks in scoring_blocks
						--print("number of same type blocks found: "..#found_list)
						
						--make found list have unique blocks
						if next(found_list) ~= nil then 
							for i,block1 in pairs(scoring_blocks) do
								for j,block2 in pairs(found_list) do
									if block1.assoc_square.gridx == block2.assoc_square.gridx and block1.assoc_square.gridy == block2.assoc_square.gridy then
										table.remove(found_list,j)
										j = j - 1
									end
								end
							end
						end -- deleting same blocks in found_list as scoring_blocks
						
						for j,b in pairs(found_list) do --loop for inserting all unique found blocks to scoring blocks
							table.insert(scoring_blocks,b)  
						end
						
						--scoring checks
						if scored_block.player > 0 then
							playerID = scored_block.player
						end
						
						if scored_block.is_loopback then
							is_loopback = true
						end
						--print("blocks added to scoring_blocks: ".. #scoring_blocks-old_scoring_blocks_num)
					end
				end
				
				--scoring connected blocks part
				--print("final num of scoring blocks: "..#scoring_blocks)
				if #scoring_blocks >= 4 then
					local total_score = 0
					print("found >4 matching blocks to score: "..#scoring_blocks)
					for i,scored_block in pairs(scoring_blocks) do
						--this part should only run once
						--score block
						local score_per_block = #scoring_blocks
						if is_loopback then
							score_per_block = score_per_block ^ 2
						end
						total_score = total_score + score_per_block
						players[playerID]:addScore(score_per_block)
						--set block to score animate
						scored_block:setBlockToScore(playerID)
					end
					print("TOTAL SCORE (without counting combos): "..total_score)
					players[playerID]:setCombo()
					blocks_scored_to_be_animated = scoring_blocks
					--remove blocks from board, shift the rows they occupy, then score the blocks
					return --once something is scored don't score anymore since no updates this time
				end
				:: continue ::
			end
		end
	end
	
	--block board
	block_board = grid:new(
		{
			rows = 1, --row size
			columns = 8, --column size
			x = middle_x,
			y = middle_y,
			size = game_board.size/game_board.rows,
			scaling_mult = 0.8,
			refresh_time = 0,
			refresh_wait = 3,
			expunge_time = 30, 
			expunge_wait = 30
			
		}, 
		boardSquare
	)
	
	--block board functions
	function block_board:setBlocks()
		for i,square in pairs(self.contents) do --only one column
			--make sure it's only values between 1 to 6
			square[1]:setBlock(getRandomType()) 
		end
	end
	
	function block_board:topUp()
		for i,square in pairs(self.contents) do
			if next(square[1].assoc_block) == nil then
				square[1]:setBlock(getRandomType()) 
			end
		end
	end
	
	function block_board:oldTopUp()
		if next(self.contents[1][1].assoc_block) == nil then
			self.contents[1][1]:setBlock(getRandomType()) 
		end
	end
	
	function block_board:refresh()
		if self.time > self.refresh_time then
			--set blocks
			self.refresh_time = self.refresh_time + self.refresh_wait
		end
	end
	
	function block_board:ExpungeBlocks()
		for i=1,#self.contents do
			self.contents[i][1]:pushBlock(1, game_board)
		end
		self:setBlocks()
		self.expunge_time = self.expunge_wait
	end
	
	function block_board:toExpungeBlocks(dt)
		if self.expunge_time <= 0 then
			self:ExpungeBlocks()
		else
			self.expunge_time = self.expunge_time - dt
		end
	end
end


