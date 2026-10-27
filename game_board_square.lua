require "board_square"
require "score_popup"
--game board
game_boardSquare = boardSquare:new()
function game_boardSquare:update(dt)
	self.time = self.time + dt
	
	if not self:isAssocBlockNil() then
		self.assoc_block:update(dt)
		if not self:isAssocBlockNil() then
			if not self.assoc_block:isPieceBelow() then
				self.assoc_block.is_falling = true
			end
		end
	else
		return
	end
	--this should just run once?
	if self.assoc_block.is_falling then --if not floor, move block
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

function game_boardSquare:matchBlocks()
	print("Now scoring blocks")
	local square = self
	if next(square.assoc_block) == nil then goto continue end
	local playerID = square.assoc_block.player
	local is_loopback = false
	
	--finding connected blocks part
	local scoring_blocks = square.assoc_block:findDirectOppositeBlocks() --start of loop
	
	--ensure no blocks are scored falling
	for j,block1 in pairs(scoring_blocks) do
		if block1.is_falling then
			table.remove(scoring_blocks,j)
			j = j - 1
		end
	end
	
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
						--check if the block is same and if block2 is also falling
						if (block1.assoc_square.gridx == block2.assoc_square.gridx and block1.assoc_square.gridy == block2.assoc_square.gridy) or block2.is_falling then
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
	
	--check game_board scored blocks, interrim blocks are not scored. Maybe because I'm only reading unscored blocks? I could just check whether is_scored is true...
	--I think this works???
	for i,b in pairs(scoring_blocks) do
		if b.is_scored then
			table.remove(scoring_blocks,i)
			i = i - 1
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
		--calculate score
		print("TOTAL SCORE (without counting combos): "..total_score)
		players[playerID].blocks_scored = players[playerID].blocks_scored + #scoring_blocks
		--add blocks to be scored
		blocks_scored_to_be_animated = scoring_blocks
		addScorePopup(self.x + self.size/2,self.y + self.size/2,total_score,players[playerID].combo)
		--set combo
		players[playerID]:setCombo()
		--remove blocks from board, shift the rows they occupy, then score the blocks
		return --once something is scored don't score anymore since no updates this time
	end
	:: continue ::
end

function game_boardSquare:moveBlock(direction, is_stop_at_player_area)
	
	if is_stop_at_player_area == nil then
		is_stop_at_player_area = true
	end

	if self:isAssocBlockNil() then 
		return 
	end
	
	if self.assoc_block.is_scored then
		return
	end
	
	if not self.assoc_block.is_falling then
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
		self.assoc_block.is_falling = false
		if SHIFT_BLOCKS_AFTER_SCORE then
			print("Get block back to the top")
			self.grid.contents[self.gridy][1]:setBlock(self.assoc_block.type, 1)
			print("Remove block")
			self:removeBlock(0)
		else
			self:matchBlocks()
			-- self:matchBlocks()
		end
		
		return
	end
	--check if block would go under the ground when its not supposed to
	if (newX > self.grid.player_area and is_stop_at_player_area) then
		print("Block "..self.gridx.. ","..self.gridy.." would be moved outside of player area to "..newX..", "..newY)
		self.assoc_block.is_falling = false
		self:matchBlocks() --not here, either put it somewhere else, or make matchBlocks for a singular block only
		return
	end
	--check if block has another block below them
	if self.assoc_block:isPieceBelow() then
		print("Block "..self.gridx.. ","..self.gridy.." would be moved onto another block")
		self.assoc_block.is_falling = false
		self:matchBlocks()
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