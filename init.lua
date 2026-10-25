require "utilities"
require "grid"
require "board_square"
require "game_board"
require "block_board"
require "backgrounds"


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
	
	--setup
	local middle_x = 360
	local middle_y = 80
	local player_area = 10
	local game_rows = 10
	local game_columns = 10
	if not HAVE_UNDER_GROUND then
		game_rows = player_area
	end
	game_board = game_board:new(
		{
			rows = game_rows, 
			columns = game_columns, 
			x = middle_x + 100,
			y = middle_y,
			size = 70 * game_rows,
			scaling_mult = 0.8,
			gravity = {1,0},
			player_area = player_area --x value
		}, 
		game_boardSquare --seperate square needed?
	)
	
	block_board = block_board:new(
		{
			assoc_game_board = game_board,
			rows = 1, --row size
			columns = game_columns, --column size
			x = middle_x,
			y = middle_y,
			size = game_board.size/game_board.rows,
			scaling_mult = 0.8,
			refresh_time = 0,
			refresh_wait = 3,
			expunge_time = 30, 
			expunge_min = 3,
			expunge_mid = 15,
			expunge_max = 30,
			expunge_wait = 30,
			expunge_wait_change = 3,
			expunge_cooldown_time = 0, --to prevent player from expunging multiple time consecutively accidentally
			expunge_cooldown_duration = 0.25,
			score_before_expunge_change = 500,
			score_add = 100,
			score_mult = 2
		}, 
		boardSquare
	)

end
