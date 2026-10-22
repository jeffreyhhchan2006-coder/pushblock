function getRandomType()
	return math.floor(math.random()*6 - 0.1) + 1
end

function flipDirection(direction)
	return {direction[1]*-1,direction[2]*-1}
end

function makeListObjectsUnique(list)
	for i,o in pairs(list) do
		for j=i+1,#list do
			if list[j] == nil then goto continue end
			if next(list[j]) == nil then goto continue end
			if TablesMatch(o,list[j]) then
				table.remove(list,j)
				j = j - 1
			end
			::continue::
		end
	end
	return list
end


function outsideBoardBounds(game_board, x, y)
	local is_outside = x <= 0 or x > game_board.rows or y <= 0 or y > game_board.columns
	-- if is_outside then
		-- print(x..", "..y.." is out of bounds")
	-- else
		-- print(x..", "..y.." is not out of bounds")
	-- end
	return is_outside
end


function print_list(list)
	local list_to_string
	list_to_string = function (ls)
		local str = "\n{"
		for i,l in pairs(ls) do
			if type(l) == "table" then
				str = str .. list_to_string(l)
			else
				str = str .. l
			end
			if i < #ls then
				str = str .. ", "
			end
		end
		str = str .. "}\n"
		return str
	end
	
	print(list_to_string(list))
end


--Shamelessly stolen from https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

--https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua
function TablesMatch( a, b )
    return table.concat(a) == table.concat(b)
end

function hypo(a,b)
	return math.sqrt(a^2 + b^2)
end
--gameplay utilities

function listHas(list, item)
	for i,l in pairs(list) do
		if l == item then
			return true
		end
	end
end

function getOpponent(player)
	if player == 1 then
		return 2
	elseif player == 2 then
		return 1
	end
end

function getDirection(direction) --always return this to a table
	local dx = 0
	local dy = 0
	if direction == 1 then
		dy = 1
	elseif direction == 2 then
		dx = 1
	elseif direction == 3 then
		dx = 1
		dy = 1
	elseif direction == 4 then
		dx = -1
		dy = 1
	end
	return dx,dy
end

--draw utilities
function changeColorBrightness(color,val)
	local c = copy(color)
	for i=1,3 do
		c[i] = c[i] + val
	end
	return c
end

function drawRotatedRectangle(mode, x, y, width, height, angle)
	local cosa, sina = math.cos(angle), math.sin(angle)

	local dx1, dy1 = width*cosa,   width*sina
	local dx2, dy2 = -height*sina, height*cosa

	local px1, py1 = x,         y
	local px2, py2 = x+dx1,     y+dy1
	local px3, py3 = x+dx1+dx2, y+dy1+dy2
	local px4, py4 = x+dx2,     y+dy2
	
	love.graphics.polygon(mode, px1,py1, px2,py2, px3,py3, px4,py4)
end

function drawRepeatingPattern(time,x,y,size,width,speed,spacing_x,spacing_y,draw1,color1,draw2,color2) 
	draw2 = draw2 or draw1
	color2 = color2 or color1
	local scroll_piece_x = (spacing_x ~= 0 and x + ((time * speed) % 2*(size + spacing_x))) or x
	local scroll_piece_y = (spacing_y ~= 0 and y + ((time * speed) % 2*(size + spacing_y))) or y
	local scroll_unit_x = (spacing_x ~= 0 and size + spacing_x) or 0
	local scroll_unit_y = (spacing_y ~= 0 and size + spacing_y) or 0
	local scroll_span = math.sqrt((love.graphics.getWidth() + math.abs(x))^2 + (love.graphics.getHeight() + math.abs(y))^2)
		
	--print(math.floor(love.graphics.getWidth()/scroll_piece_size))
	for i = 0,math.floor(scroll_span/size) + 5 do
		love.graphics.setColor(color1)
		draw1(
			scroll_piece_x + (2*i)*(scroll_unit_x),
			scroll_piece_y + (2*i)*(scroll_unit_y),
			size,
			width,
			0
		)
		love.graphics.setColor(color2)
		draw2(
			scroll_piece_x + ((2*i) + 1)*(scroll_unit_x),
			scroll_piece_y + ((2*i) + 1)*(scroll_unit_y),
			size,
			width,
			0
		)
	end
end	

function drawRow(time,x,y,size,width,speed,spacing,draw1,color1,draw2,color2) 
	draw2 = draw2 or draw1
	color2 = color2 or color1
	local scroll_piece_spacing = spacing
	local scroll_piece_size = size
	local scroll_piece_width = width
	local scroll_piece_x = x + (time * speed) % 2*(size + scroll_piece_spacing)
	local scroll_piece_y = y
	local scroll_unit = scroll_piece_size + scroll_piece_spacing
	local scroll_span = love.graphics.getWidth() + math.abs(x)
		
	--print(math.floor(love.graphics.getWidth()/scroll_piece_size))
	for i = 0,math.floor(scroll_span/scroll_piece_size) + 5 do
		love.graphics.setColor(color1)
		draw1(
			scroll_piece_x + (2*i)*(scroll_unit),
			scroll_piece_y,
			scroll_piece_size,
			scroll_piece_width,
			0
		)
		love.graphics.setColor(color2)
		draw2(
			scroll_piece_x + ((2*i) + 1)*(scroll_unit),
			scroll_piece_y,
			scroll_piece_size,
			scroll_piece_width,
			0
		)
	end
end	

function drawOpiece(x,y,size,width,margins)
	local centrex = x + size / 2
	local centrey = y + size / 2
	local function stencilfunc()
		love.graphics.circle("fill", centrex, centrey, ((size / 2) - margins) - width)
	end
	love.graphics.stencil(stencilfunc, "replace", 1)
	love.graphics.setStencilTest("equal", 0)
	love.graphics.circle( "fill", centrex, centrey, ((size / 2) - margins))
end

function drawXpiece(x,y,size,width,margins)
	local cross_width = width	
	local cross_margins = margins
	love.graphics.polygon("fill", 
		(x+cross_width+cross_margins),y+cross_margins, 
		x+cross_margins,(y+cross_width+cross_margins), 
		(x+size-cross_width-cross_margins),(y+size-cross_margins),
		(x+size-cross_margins),(y+size-cross_width-cross_margins)
	)
			
	love.graphics.polygon("fill", 
		x+cross_margins,(y+size-cross_width-cross_margins),
		(x+cross_width+cross_margins),(y+size-cross_margins),
		(x+size-cross_margins),(y+cross_width+cross_margins),
		(x+size-cross_width-cross_margins),y+cross_margins
	)
end


function drawScoringLine(x,y,width,height,angle)
	local cosa, sina = math.cos(angle), math.sin(angle)
	
	local dx1, dy1 = width*cosa,   width*sina
	local dx2, dy2 = -height*sina, height*cosa

	local px1, py1 = x,         y
	local px2, py2 = x+dx1+dx2/2,     y+dy1+dy2/2
	local px4, py4 = x-dx1+dx2/2,     y-dy1+dy2/2
	local px3, py3 = x+dx2, y+dy2
	
	
	--vertical
	love.graphics.polygon("fill", px1,py1, px2,py2, px3,py3, px4,py4)
end

function drawSpellFrag(id, x, y, size)
	if id == 1 or id == 7 or id == 8 then
		--love.graphics.rectangle('fill', )
	end

end


function drawSpotlight()

end