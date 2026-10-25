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
	duration_before_transition = 3
	is_transition = false
	--end screen test
	-- players[1].influence = 2500
	win_sfx_played = false
	player_win = 0 --used in results
	math.randomseed(os.time())
	block_board:setBlocks()
	delta_time = 0
	game_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/30)
	intro_music_played = false
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
	
	--music handling
	local function isAllSilent()
		local list = {calm_music, good_music, ok_music1, ok_music2, bad_music, very_bad_music}
		for i,m in pairs(list) do
			if m:isPlaying( ) then
				return false
			end
		end
		return true
	end
	
	local function playLoopIfSilent(music)
		if isAllSilent() then
			playLoopMusic(music)
		end
	end
	
	local function stopAllMusic()
		local list = {title_music, intro_music, calm_music, good_music, ok_music1, ok_music2, bad_music, very_bad_music}
		for i,m in pairs(list) do
			love.audio.stop(m)
		end
	end
	
	if not title_music:isPlaying( ) then
		if not intro_music_played then
			love.audio.play(intro_music)
			intro_music_played = true
		else
			if not intro_music:isPlaying( ) then
				local game_condition = game_board:checkGameCondition()
				if game_condition < 0.2 then
					playLoopIfSilent(calm_music)
				elseif game_condition < 0.4 then
					playLoopIfSilent(good_music)
				elseif game_condition < 0.6 then
					playLoopIfSilent(ok_music1)
				elseif game_condition < 0.8 then
					playLoopIfSilent(ok_music2)
				elseif game_condition < 0.9 then
					playLoopIfSilent(bad_music)
				else
					playLoopIfSilent(very_bad_music)
				end
			end
		end
	end
	
	if game_end then
		stopAllMusic()
		love.audio.play(game_over_music)
		timer_before_transition = timer_before_transition + dt
		if timer_before_transition >= duration_before_transition and not is_transition then
			saveGame(players[1].score, players[1].max_combo)
			TM.load(
				"fade-in-out",                       
				SSM.add,                          
				'results'
			)
			is_transition = true
		end
	end
	
	if next(blocks_scored_to_be_animated) ~= nil then
		updateScoredBlocks(dt,game_board)
		goto exit
	end
	
	updateScorePopups(dt)
	
	-- if next(blocks_scored_to_be_animated) ~= nil then
		-- print("game update continues despite return")
	-- end

	--everything below shouldn't update before scoring animations finish
	-- NEED TO GET RELIABLE LOSE CONDITION CHECKER!!!
	game_board:update(dt)
	
	if EXPUNGE_BOARD_BLOCKS then
		block_board:toExpungeBlocks(dt)
	end
	block_board:update(dt)
	block_board:topUp()
	block_board:updateExpungeCooldown(dt)
	
	for i,p in pairs(players) do
		p:update(dt)
		block_board:changeExpungeWait(p.score)
		if p.combo_time <= 0 then
			if game_board:checkLoseCondition() then
				game_end = true
			end
		end
	end
	
	
	
	:: exit ::
end

function scene.draw()

	drawBackground()
	love.graphics.setFont(game_font)
	--shading the baord background
	love.graphics.setColor(0,0,0,0.75)
	love.graphics.rectangle("fill", game_board.x, game_board.y, game_board.size, game_board.size)
	
	--game board
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("line", game_board.x, game_board.y, game_board.size, game_board.size)
	game_board:draw()
	drawScorePopups(dt)
	
	--block board
	block_board:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(game_font)
	local time_to_expunge = math.floor(block_board.expunge_time + 0.5)
	love.graphics.print(time_to_expunge.."/"..block_board.expunge_wait, block_board.x, block_board.y - 50)
	
	--player
	for i,p in pairs(players) do
		--draw plyaer cursor
		p:draw(block_board.square_size)
	end
	
	--UI
	local text_margin = 10
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(game_font)
	love.graphics.print("Score: "..players[1].score, text_margin, 100)
	love.graphics.print("Target: "..block_board.score_before_expunge_change, text_margin, 125)
	love.graphics.print("Blocks Scored: "..players[1].blocks_scored, text_margin, 150)
	love.graphics.print(delta_time, 0, 0)
	
	--Game Over Screen
	if game_end then
		love.graphics.setColor(0,0,0,timer_before_transition)
		love.graphics.rectangle("fill", 0,0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(1,1,1)
		local font = love.graphics.newFont("fonts/PixelCards.ttf", love.graphics.getHeight()/10)
		love.graphics.setFont(font)
		local text = "GAME OVER"
		love.graphics.print(text,love.graphics.getWidth()/2 - font:getWidth(text)/2,love.graphics.getHeight()/2 - font:getHeight()/2)
	end
end

return scene

