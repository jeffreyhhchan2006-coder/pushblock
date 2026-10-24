function initSaveData()
	if love.filesystem.isFile("save_data") then return end
	file, errorstr = love.filesystem.newFile("save_data", "w")
	local high_score = {}
	table.insert(high_score, )
	--insert high scores
end