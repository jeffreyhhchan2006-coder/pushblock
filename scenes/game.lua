require "utilities"
require "objects"
require "init"
require "player"

local scene = {}

function scene.load()
	
	print("load function should only load once")
	players = {}
	load_board()
	load_players()
	time = 0
	interval = 1.5
	time_to_place = time + interval
	alerts = {}
	events = {} --idk about the implementation
	game_board_update_time = 0
	game_end = false
	timer_before_transition = 0
	duration_before_transition = 1
	is_transition = false
	--end screen test
	-- players[1].influence = 2500
	win_sfx_played = false
	player_win = 0 --used in results
	math.randomseed(os.time())
	block_board:setBlocks()
	delta_time = 0
end

function love.keypressed(key, scancode, isrepeat )
	if scancode == "r" then 
		print("reset game")
		SSM.purgeAll()
		SSM.add('spell_menu')
	end
end


function scene.update(dt)
	time = time + dt
	delta_time = dt
	
	if next(blocks_scored_to_be_animated) ~= nil then
		updateScoredBlocks(dt,game_board)
		goto exit
	end
	
	if next(blocks_scored_to_be_animated) ~= nil then
		print("game update continues despite return")
	end
	
	--everything below shouldn't update before scoring animations finish
	-- NEED TO GET RELIABLE LOSE CONDITION CHECKER!!!
	game_board:update(dt)
	-- game_board:matchBlocks()
	
	if EXPUNGE_BOARD_BLOCKS then
		block_board:toExpungeBlocks(dt)
	end
	block_board:update(dt)
	block_board:topUp()
	
	for i,p in pairs(players) do
		p:update(dt)
	end
	
	:: exit ::
end

function scene.draw()
	--print('game draw')
	
	--shading the baord background
	love.graphics.setColor(0,0,0,0.75)
	love.graphics.rectangle("fill", game_board.x, game_board.y, game_board.size, game_board.size)
	
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("line", game_board.x, game_board.y, game_board.size, game_board.size)
	game_board:draw()
	block_board:draw()
	love.graphics.setColor(1,1,1)
	local time_to_expunge = math.floor(block_board.expunge_time + 0.5)
	love.graphics.print(time_to_expunge, block_board.x, block_board.y - 50)
	
	for i,p in pairs(players) do
		--draw plyaer cursor
		p:draw(block_board.square_size)
	end
	
	love.graphics.setColor(1,1,1)
	love.graphics.print("Score: "..players[1].score, 0, 100)
	love.graphics.print("Combo: "..players[1].combo-1, 0, 125)
	love.graphics.print("Combo Time: "..players[1].combo_time, 0, 150)
	love.graphics.print(delta_time, 0, 0)
	if game_end then
		love.graphics.print("GAME OVER", love.graphics.getWidth(), 0)
	end
end

return scene

