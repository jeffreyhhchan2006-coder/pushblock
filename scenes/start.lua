require "init"
require "save_load"

local scene = {}

function scene.load()
	logo = love.graphics.newImage("assets/images/logo.png")
	time = 0
	initSaveData()
	loadGame() --get data
	print("High score: "..data.score_board[1])
end


function scene.update(dt)
	time = time + dt
	bg_blocks = {}
	if love.keyboard.isDown("escape") then
		love.event.quit()
	elseif love.keyboard.isDown("return") then
		TM.load(
		  "fade-in-out",                       
		  SSM.add,       
		  "game"  
		)
	end
end

function scene.draw()

	drawBackground()
	
	--shade
	love.graphics.setColor(0, 0, 0, 0.3)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),love.graphics.getHeight()*8/16)
	
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),love.graphics.getHeight()*6/16)
	
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),love.graphics.getHeight()*5/16)
	
	--logo
	love.graphics.push()
	love.graphics.scale(2,2)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(logo, love.graphics.getWidth()/4 - logo:getWidth()/2, 0)
	love.graphics.pop()
	
	local text = "There is no perfect solution."
	local select_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/35)
	love.graphics.setFont(select_font)
	love.graphics.setColor(0.75,0.75,0.75)
	love.graphics.print(text,love.graphics.getWidth()/2-select_font:getWidth(text)/2,250)
	
	--highscore
	love.graphics.setColor(0.65,0.65,0.65)
	love.graphics.rectangle(
		"fill", 
		love.graphics.getWidth()*2/32, 
		love.graphics.getHeight()*6/16, 
		love.graphics.getWidth()*7/16,
		love.graphics.getHeight()*15/32
	)
	love.graphics.setColor(0.15,0.15,0.15)
	love.graphics.print("Score Board:",love.graphics.getWidth()*3/32,love.graphics.getHeight()*7/16)
	for i=1,5 do
		love.graphics.print("	"..i..": "..data.score_board[i],love.graphics.getWidth()*3/32,love.graphics.getHeight()*((14+i)/32))
	end
	if next(data.user_score_board) ~= nil then
		love.graphics.print("Personal Best: "..data.user_score_board[1],love.graphics.getWidth()*3/32,love.graphics.getHeight()*20/32)
	end
	
	--how to play
	love.graphics.setColor(0.75,0.75,0.75)
	love.graphics.rectangle(
		"fill", 
		love.graphics.getWidth()*16/32, 
		love.graphics.getHeight()*6/16, 
		love.graphics.getWidth()*7/16,
		love.graphics.getHeight()*15/32
	)
	love.graphics.setColor(0.15,0.15,0.15)
	love.graphics.print(
		"How to play:\n\nW/S: Move Up/Down, J: Push Block,\nK: Select/Switch Blocks, Space: Expunge Blocks\n\nYou are a Block-pusher.\nYour job is to push blocks from your inventory to\nthe board to connect them to groups of 4 or more\nof the same colour, in which they would disappear.\nYou get awarded points based on how many blocks you\nconnect and how many groups you connect at a time.\nOnce in a while, all blocks in your inventory will be\nforcibly expunged to the board, replaced by new blocks.\nLast as long as possible, you lose when you can't push\nblocks anymore. There is no perfect solution. Good luck.",
		love.graphics.getWidth()*33/64,
		love.graphics.getHeight()*25/64
	)
	
	
	local text = "Press Enter to start"
	local select_font = love.graphics.newFont("fonts/Pix32.ttf", love.graphics.getHeight()/30)
	love.graphics.setFont(select_font)
	love.graphics.setColor(1,1,1)
	love.graphics.print(text,love.graphics.getWidth()/2-select_font:getWidth(text)/2,750)
end

return scene
