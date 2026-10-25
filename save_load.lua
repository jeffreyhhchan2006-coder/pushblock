lume = require "libraries/lume-master/lume"

save_data_location = "savedata.txt"

function initSaveData()

	if love.filesystem.getInfo(save_data_location) then 
		print("didn't init savedata, savedata already initialised")
		return 
	end
	
	local data = {}
	data.score_board = {}
	data.user_score_board = {}
	--insert high scores
	table.insert(data.score_board, 25000)
	table.insert(data.score_board, 10000)
	table.insert(data.score_board, 5000)
	table.insert(data.score_board, 2500)
	table.insert(data.score_board, 625)
	
	data.max_combo = 0
	serialized = lume.serialize(data)
	--create new file
	love.filesystem.newFile(save_data_location, "w")
    local success, message = love.filesystem.write(save_data_location, serialized)
	if success then
		print("new savedata initialised")
	else
		print("can't create savedata: "..message)
	end
end

function saveGame(score, max_combo)

	local function putScoreInScoreBoard(score,score_board)
		local score_added = false
		for i,sc in pairs(score_board) do
			if score > sc then
				table.insert(score_board, i, score)
				score_added = true
				goto continue
			end
		end
		if not score_added then
			table.insert(score_board, score)
		end
		:: continue ::
	end
	
	
	if love.filesystem.getInfo(save_data_location) then
        file = love.filesystem.read(save_data_location)
        data = lume.deserialize(file)
	else
		print("ERROR SAVING GAME, save data not found.")
		return
	end
	
	putScoreInScoreBoard(score,data.score_board)
	putScoreInScoreBoard(score,data.user_score_board)
	
	if max_combo > data.max_combo then
		data.max_combo = max_combo
	end
	serialized = lume.serialize(data)
    love.filesystem.write(save_data_location, serialized)
end

function loadGame()
	if love.filesystem.getInfo(save_data_location) then
        file = love.filesystem.read(save_data_location)
        data = lume.deserialize(file)
		print("game loaded.")
	else
		print("ERROR LOADING GAME, save data not found.")
		initSaveData()
		return
	end
end