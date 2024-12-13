extends Node

func get_text_list(path):
	var promptList = []
	var file = FileAccess.open(path, FileAccess.READ)
	while file.get_position() < file.get_length():
		promptList.push_back(file.get_line())
	return promptList

func save_game(path, save_data): 
	if(FileAccess.file_exists(Global.custom_folder_path + path + ".txt")):
		var save_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.WRITE)
		var json_string = JSON.stringify(save_data)
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

func create_basic_save(path): # get TXT file
	if(!path):
		print("path is null: ", path)
	else:
		var file
		if path == "default":
			file = Global.default_file_path
		else:
			file = Global.custom_folder_path + path + ".txt"
		if(FileAccess.file_exists(file)):
			var save_dict = {}
			var position = 1
			while file.get_position() < file.get_length():
				save_dict[position] = {"prompt": file.get_line(), "chance": 0.5}
				position += 1
			
			var save_file = FileAccess.open(Global.chance_folder_path + path + ".save", FileAccess.WRITE)
			var json_string = JSON.stringify(save_dict)
			save_file.store_line(json_string)
		else:
			print("no file")
