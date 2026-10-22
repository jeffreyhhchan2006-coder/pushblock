--objects
	--Variables: almost every object in the game has x, y, time values. 
	--Function: Update counts time, draw left without implementation
	
object = {
	x = 0,
	y = 0,
	time = 0,
	update = function (self, dt) self.time = self.time + dt end,
	draw = function (self) end
}

function object:new(obj)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.time = 0
	return obj
end


game_object = object:new({
	hp = 100,
	hp_limit = 100,
	player = 0,
	direction = {0,0},
	assoc_square = {},
	assoc_effects = {}, --kinda just used for storing effect areas, for whatever use the object needs.
	time_limit = 0,
	tags = {},
	image = {},
	place = function (self) end,
	pop = function (self) end, --what to do before object if object time runs out before being deleted
	update = function (self,dt) 
		self.time = self.time + dt
		if next(self.assoc_effects) ~= nil then
			effect_manager(self, self.assoc_effects, self.assoc_square.grid, dt)
		end
	end
})

function game_object:addEffect(effect)
	for i,e in pairs(self.assoc_effects) do--it's giving the effect to the same block for some reason
		--print("effect given to "..self.assoc_square.gridx..", "..self.assoc_square.gridy)
		if e.name == effect.name then
			print('block already has that spell') --probably add a setting where return is default, remove from table if tagged
			print('is reset is '..effect.is_reset)
			if effect.is_reset == 1 then
				table.remove(self.assoc_effects,i)
			elseif effect.is_reset == 0 then
				return
			end
		end
	end
	local new_effect = effect:new({player = self.player, assoc_block = self})
	table.insert(self.assoc_effects,new_effect)
end

function game_object:changeHp(damage_dealt, damage_mult, dt)
	damage_mult = damage_mult * dt --only applies within function, should be fine
	print("original object hp "..self.hp)
	print("damage dealt "..damage_dealt)
	print("damage mult "..damage_mult)
	print((self.hp + (damage_dealt * damage_mult)) > self.hp_limit)
	print(self.hp + (damage_dealt * damage_mult))
	if (self.hp + (damage_dealt * damage_mult)) <= self.hp_limit then
		self.hp = self.hp + (damage_dealt * damage_mult)
	else
		self.hp = self.hp_limit
	end
	print("object hp is subtracted by "..damage_dealt * damage_mult.." which leads to"..self.hp)
end

function game_object:removeFromSquare()
	self.assoc_square.assoc_object = {} --assuming only 1 object per square
end