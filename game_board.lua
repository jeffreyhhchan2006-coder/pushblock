require "grid"
require "game_board_square"

game_board = grid:new(
	{
		gravity = {1,0},
		player_area = 8 --x value
	}, 
	game_boardSquare --seperate square needed?
)
--idk how fucky this is
function game_board:update(dt)
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