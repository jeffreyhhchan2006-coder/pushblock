function drawBackground()
	--background
	love.graphics.setColor(100/255, 100/255, 100/255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),love.graphics.getHeight())
	

	local function drawPieceRow(x,y,size,width,speed) 
		local scroll_piece_spacing = width
		local scroll_piece_size = size
		local scroll_piece_width = width
		local scroll_piece_x = x + (time * speed) % 2*(size + scroll_piece_spacing)
		local scroll_piece_y = y
		
		--print(math.floor(love.graphics.getWidth()/scroll_piece_size))
		for i = 0,math.floor(love.graphics.getWidth()/scroll_piece_size) + 1 do
			love.graphics.setColor(0.42,0.42,0.42)
			love.graphics.rectangle(
				"fill",
				scroll_piece_x + (i)*(scroll_piece_size + scroll_piece_spacing), scroll_piece_y, 
				scroll_piece_size,
				scroll_piece_size
			)

		end
	end	
	
	local rows = 20
	local size = 20
	local speed = 0.5
	for i=0,rows/2 do
		drawPieceRow(-400,love.graphics.getHeight()*(i*2/rows)-2,size,size,speed) 
		drawPieceRow(-420,love.graphics.getHeight()*(((i*2)-1)/rows)-2,size,size,-speed)
	end
end