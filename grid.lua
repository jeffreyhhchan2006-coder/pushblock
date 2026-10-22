require "objects"

gridSquare = object:new({
	size = 0,
	scaling_mult = 1,
	grid = {},
	gridx = 0,
	gridy = 0,
	draw = function (self)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
	end
})

grid = object:new({
	contents = {},
	rows = 0,
	columns = 0,
	x_offset = 0,
	y_offset = 0,
	size = love.graphics.getHeight(),
})

--Implementation, probably used in new()
grid.x = (love.graphics.getWidth() / 2) - (grid.size / 2) + grid.x_offset
grid.y = (love.graphics.getHeight() / 2) - (grid.size / 2) + grid.y_offset
grid.square_size = grid.size / grid.rows

function grid:draw()
	for y=1,self.columns do
		for x,s in pairs(self.contents[y]) do
			--print(x)
			s:draw()
		end
	end
end

function grid:update(dt)
	-- if self.size == 0 then self.size = love.graphics.getHeight() * self.scaling_mult end
	self.square_size = self.size / self.rows
	for y=1,self.columns do
		for x=1,self.rows do
			self.contents[y][x].size = self.square_size
			self.contents[y][x].x = self.x + (x-1)*(self.square_size)
			self.contents[y][x].y = self.y + (y-1)*(self.square_size)
			self.contents[y][x]:update(dt)
		end
	end
end


function grid:new(obj,squareClass)
	local obj = obj or {} 
	setmetatable(obj, self)
	self.__index = self
	obj.contents = {}
	obj.square_size = obj.size / obj.rows
	for y=1,obj.columns do
		table.insert(obj.contents,{})
		for x=1,obj.rows do
			table.insert(obj.contents[y],squareClass:new({
			grid = obj, 
			size = obj.square_size,
			x = obj.x + (x-1)*(obj.square_size), 
			y = obj.y + (y-1)*(obj.square_size),
			gridx = x, 
			gridy = y
			}))
		end
	end
	-- print("grid rows: "..obj.rows)
	-- print("grid columns: "..obj.columns)
	-- print("length of row 1: "..#obj.contents[1])
	return obj
end

function grid:returnCoords(gridx,gridy)
	return self.contents[gridy][gridx].x, self.contents[gridy][gridx].y
end

function grid:checkValid(gridx,gridy)
	if gridx > 0 and
		gridx <= self.rows and
		gridy > 0 and
		gridy <= self.columns then
		return true
	end
	return false
end
	
	