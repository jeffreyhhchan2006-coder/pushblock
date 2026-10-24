require "utilities"
require "objects"
require "board"
require "spell"
require "menu"
require "init"
require "backgrounds"
require "ui"
require "player"
require "opponent_ai"

local scene = {}

function scene.load()
	print('results screen')
	-- SSM.setFrozen('game',true)
	-- player_win = 1
	-- if players[1].influence / (players[1].influence + players[2].influence) <= 0.1 then
		-- player_win = 2	
	-- end
	
end


function scene.update(dt)
	--print('results updating')
	if love.keyboard.isDown("return") then 
		if player_win == 1 then --temp switch to test next stage transition
			print("go to next opponent")
			TM.load(
				"fade-in-out",         -- effect
				SSM.add,   -- result
				'next_stage'                 -- result params
			)
		elseif player_win == 2 then
			print("back to start")
			next_opponent = 0
			TM.load(
				"fade-in-out",         -- effect
				SSM.add,   -- result
				'start'                 -- result params
			)
		end
	end
end

function scene.draw()
	--print('results draw')
	--shading the board background
	love.graphics.setColor(0,0,0,0.75)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	
	love.graphics.setColor(1,1,1)
	local combo_font = love.graphics.newFont("fonts/PixelCards.ttf", love.graphics.getHeight()/7.5)
	love.graphics.setFont(combo_font)
	love.graphics.print("GAME OVER",  (love.graphics.getWidth()/2) - combo_font:getWidth("GAME OVER")/2, love.graphics.getHeight()/8)
	
	if player_win == 1 then
		love.graphics.setColor(player_colors[1])
		love.graphics.print("PLAYER 1",  (love.graphics.getWidth()/2) - combo_font:getWidth("PLAYER 1")/2, love.graphics.getHeight()/4)
		love.graphics.print("WIN",  (love.graphics.getWidth()/2) - combo_font:getWidth("WIN")/2, love.graphics.getHeight()/4 + love.graphics.getHeight()/7.5)
	elseif player_win == 2 then
		love.graphics.setColor(player_colors[2])
		love.graphics.print("PLAYER 2",  (love.graphics.getWidth()/2) - combo_font:getWidth("PLAYER 2")/2, love.graphics.getHeight()/4)
		love.graphics.print("WIN",  (love.graphics.getWidth()/2) - combo_font:getWidth("WIN")/2, love.graphics.getHeight()/4 + love.graphics.getHeight()/7.5)
	end
end

return scene