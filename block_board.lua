--block board
block_board = grid:new(
	{
		assoc_game_board = {},
		rows = 1, --row size
		scaling_mult = 0,
		refresh_time = 0,
		refresh_wait = 0,
		expunge_time = 0, 
		expunge_min = 0,
		expunge_max = 0,
		expunge_wait = 0,
		expunge_wait_change = 0,
		score_before_expunge_change = 0,
		expunge_cooldown_time = 0, --to prevent player from expunging multiple time consecutively accidentally
		expunge_cooldown_duration = 3,
		score_before_expunge_change = 0,
		score_add = 0,
		score_mult = 0
	}, 
	boardSquare
)

--block board functions
function block_board:setBlocks()
	for i,square in pairs(self.contents) do --only one column
		--make sure it's only values between 1 to 6
		if square[1]:isAssocBlockNil() then
			square[1]:setBlock(getRandomType())
		end
	end
end

function block_board:topUp()
	for i,square in pairs(self.contents) do
		if next(square[1].assoc_block) == nil then
			square[1]:setBlock(getRandomType()) 
		end
	end
end

function block_board:oldTopUp()
	if next(self.contents[1][1].assoc_block) == nil then
		self.contents[1][1]:setBlock(getRandomType()) 
	end
end

function block_board:refresh()
	if self.time > self.refresh_time then
		--set blocks
		self.refresh_time = self.refresh_time + self.refresh_wait
	end
end

function block_board:ExpungeBlocks()
	if self.expunge_cooldown_time > 0 then return end
	for i=1,#self.contents do
		if self.assoc_game_board.contents[i][1]:isAssocBlockNil() then
			self.contents[i][1]:pushBlock(1, self.assoc_game_board)
		end
	end
	self:setBlocks()
	self.expunge_time = self.expunge_wait
	self.expunge_cooldown_time = self.expunge_cooldown_duration
end

function block_board:toExpungeBlocks(dt)
	if self.expunge_time <= 0 then
		self:ExpungeBlocks()
	else
		self.expunge_time = self.expunge_time - dt
	end
end

function block_board:changeExpungeWait(score)
	if self.expunge_wait <= self.expunge_min then return end
	if score >= self.score_before_expunge_change then
		self.expunge_wait = self.expunge_wait - self.expunge_wait_change
		if self.expunge_wait > self.expunge_mid then
			self.score_add = self.score_add * self.score_mult
		end
		self.score_before_expunge_change = self.score_before_expunge_change + self.score_add
	end
end

function block_board:updateExpungeCooldown(dt)
	if self.expunge_cooldown_time > 0 then
		self.expunge_cooldown_time = self.expunge_cooldown_time - dt
	end
end