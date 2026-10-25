
local scene = {}

function scene.load()
	print('results screen')
	time = 0
	start_scoring = 0.5
	score_to_show = 0
	max_combo_to_show = 0
	results_state = "load"
	print(players[1].score)
	print(players[1].max_combo)
end


function scene.update(dt)
	time = time + dt
	print("current state: "..results_state)
	if time > start_scoring and results_state == "load" then
		results_state = "tally_score"
	end
	
	if results_state == "tally_score" then
		if love.keyboard.isDown("j") then
			score_to_show = players[1].score
		end
		if score_to_show < players[1].score then
			score_to_show = score_to_show + 1
			playSFX(move_sfx)
		else
			results_state = "tally_max_combo"
		end
	elseif results_state == "tally_max_combo" then
		if love.keyboard.isDown("j") then
			max_combo_to_show = players[1].max_combo
		end
		if max_combo_to_show < players[1].max_combo then
			max_combo_to_show = max_combo_to_show + 1
			playSFX(move_sfx)
		else
			results_state = "continue"
		end
	elseif results_state == "continue" then
		if love.keyboard.isDown("return") then
			print("back to start")
			TM.load(
				"fade-in-out",         -- effect
				SSM.add,   -- result
				'start'                 -- result params
			)
		end
	end
end

function scene.draw()
	drawBackground()
	--shading the board background
	love.graphics.setColor(0,0,0,0.75)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	
	love.graphics.setColor(1,1,1)
	local combo_font = love.graphics.newFont("fonts/PixelCards.ttf", love.graphics.getHeight()/7.5)
	love.graphics.setFont(combo_font)
	love.graphics.print("GAME OVER",  (love.graphics.getWidth()/2) - combo_font:getWidth("GAME OVER")/2, love.graphics.getHeight()/8)
	
	
	local results_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/30)
	love.graphics.setFont(results_font)
	
	love.graphics.print("SCORE:", love.graphics.getWidth()*3/8, love.graphics.getHeight()*3/8)
	love.graphics.print(score_to_show, love.graphics.getWidth()*5/8, love.graphics.getHeight()*3/8)
	
	love.graphics.print("MAX COMBO:", love.graphics.getWidth()*3/8, love.graphics.getHeight()*4/8)
	love.graphics.print(max_combo_to_show, love.graphics.getWidth()*5/8, love.graphics.getHeight()*4/8)
	
	if results_state == "continue" then
		local continue_text = "Press Enter to Continue"
		love.graphics.print(continue_text, (love.graphics.getWidth()/2) - results_font:getWidth(continue_text)/2, love.graphics.getHeight()*5/8)
	end
	
end

return scene