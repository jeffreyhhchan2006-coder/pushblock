require "utilities"
require "init"



local scene = {}

function scene.load()
	
	print("load function should only load once")
	players = {}
	score_popups = {}
	combo_popups = {}
	punish_popups = {}
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
	controls_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/35)
	intro_music_played = false
	board_filled_timer = 0
	duration_before_game_over = 0.5
	details_logo = love.graphics.newImage("assets/images/details.png")
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
	
	--rainbow color
	rainbow_color:update(dt)
	
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
			playMusic(intro_music)
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
		block_board.punish_blocks = 0
		stopAllMusic()
		playMusic(game_over_music)
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

	--everything below shouldn't update before scoring animations finish
	--game board
	game_board:update(dt)
	
	--block board
	if EXPUNGE_BOARD_BLOCKS then
		block_board:toExpungeBlocks(dt)
	end
	block_board:update(dt)
	block_board:topUp()
	block_board:updateExpungeCooldown(dt)
	
	--players
	for i,p in pairs(players) do
		block_board:setPunishBlocks(dt,p.player)
		p:update(dt)
		block_board:changeExpungeWait(p.score)
	end
	
	--punish blocks
	updatePunishPopup(dt)
	
	--game over condition
	if game_board:checkGameCondition() >= 1 then
		board_filled_timer = board_filled_timer + dt
		if board_filled_timer > duration_before_game_over then
				game_end = true
		end
	else
		board_filled_timer = 0
	end
	
	--combo popup
	updateComboPopup(dt)
	
	:: exit ::
end

function scene.draw()

	drawBackground()
	love.graphics.setFont(game_font)
	--shading the board background
	love.graphics.setColor(0,0,0,0.75)
	love.graphics.rectangle("fill", game_board.x, game_board.y, game_board.size, game_board.size)
	
	--for the game area itself
	love.graphics.push()
	-- love.graphics.translate(game_board.x-100,game_board.y+game_board.size*1.6)
	-- love.graphics.rotate(-math.pi/2)
	
	--game board
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("line", game_board.x, game_board.y, game_board.size, game_board.size)
	game_board:draw()
	drawScorePopups(dt)
	drawPunishPopups(dt)
	drawComboPopups(dt)
	
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
	
	love.graphics.pop()
	
	--UI
	local function drawUIBox(type,x,y,width,height,taper)
		love.graphics.polygon(type,
			x,y,
			x + width - taper,y,
			x + width, y + taper,
			x + width, y + height - taper,
			x + width - taper, y + height,
			x, y + height
		)
	end

	love.graphics.setColor(0.1,0.1,0.1,0.75)
	drawUIBox("fill",0,100,325,love.graphics.getHeight()-200,60)
	love.graphics.setColor(0.8,0.8,0.8)
	drawUIBox("line",0,100,325,love.graphics.getHeight()-200,60)
	
	love.graphics.push()
		love.graphics.scale(0.35,0.4)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(details_logo,20/0.6,320) --108
	love.graphics.pop()

	local text_margin = 20
	local score_text_start = 225
	local score_text_gap = 25
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(game_font)
	love.graphics.print("Score: "..players[1].score, text_margin, score_text_start)
	love.graphics.print("Target: "..block_board.score_before_expunge_change, text_margin, score_text_start + score_text_gap)
	love.graphics.print("Blocks Scored: "..players[1].blocks_scored, text_margin, score_text_start + 2*score_text_gap)
	--love.graphics.print("Combo Time: "..players[1].combo_time, text_margin, 200)
	
	local controls_text_start = 150 + 18*score_text_gap
	love.graphics.setFont(controls_font)
	love.graphics.print("W/S: Move Up/Down,\nJ: Push Block,\nK: Select/Switch Blocks, \nSpace: Expunge Blocks", text_margin, controls_text_start )
	
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

