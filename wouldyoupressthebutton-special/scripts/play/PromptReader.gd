extends Node

func get_text_list(path):
	var promptList = []
	var file = FileAccess.open(path, FileAccess.READ)
	while file.get_position() < file.get_length():
		promptList.push_back(file.get_line())
	return promptList

func save_game(path, save_dict):
	var textFile
	if path == "default":
		textFile = FileAccess.open(Global.default_file_path, FileAccess.READ)
	else:
		textFile = FileAccess.open(Global.custom_folder_path + path + ".txt", FileAccess.READ)
	if(textFile):
		var save_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.WRITE)
		var json_string = JSON.stringify(save_dict)
		save_file.store_line(json_string)
	else:
		print("no file")

func load_game(path): # get SAVE file and return JSON
	var save_file = FileAccess.open(path, FileAccess.READ)
	if(!save_file):
		print("no save file to load")
	else:
		var json = JSON.new()
		var json_string = save_file.get_line()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		else:
			return json

func initialize_save(path):
	var textFile
	if(path == "default"):
		textFile = FileAccess.open(Global.default_file_path, FileAccess.READ)
	else:
		textFile = FileAccess.open(Global.custom_folder_path + path + ".txt", FileAccess.READ)
	if(textFile):
		var save_dict = {}
		var save_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.READ)
		if(save_file):
			var json = JSON.new()
			var json_string = save_file.get_line()
			var parse_result = json.parse(json_string)
			var data = json.data
			var savedPrompts = []
			var savedChances = []
			for i in data.keys():
				savedPrompts.append(data[i].prompt)
				savedChances.append(data[i].chance)
			# find differences through text file
			var position = 1
			while textFile.get_position() < textFile.get_length():
				var textPrompt = textFile.get_line()
				if(savedPrompts.size() < position || textPrompt != savedPrompts[position - 1]):
					save_dict[position] = {"prompt": textPrompt, "chance": 0.5}
				else:
					save_dict[position] = {"prompt": textPrompt, "chance": savedChances[position - 1]}
				position += 1
			var save_to_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.WRITE)
			json_string = JSON.stringify(save_dict)
			save_to_file.store_line(json_string)
		else:
			var position = 1
			while textFile.get_position() < textFile.get_length():
				save_dict[position] = {"prompt": textFile.get_line(), "chance": 0.5}
				position += 1
			var save_to_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.WRITE)
			var json_string = JSON.stringify(save_dict)
			save_to_file.store_line(json_string)
		return save_dict
	else:
		print("no file")
