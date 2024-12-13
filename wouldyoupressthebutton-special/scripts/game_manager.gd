extends Node2D

@export var mainMenu: PackedScene
@export var playScene: PackedScene

var scenePointer

func _ready() -> void:
	# folder for user prompts
	var dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	dir.make_dir("custom-prompts")
	# folder for prompt chances
	dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	dir.make_dir("prompt chances")
	
	var load = initialize_save("test")
	for i in load.keys():
		print(load[i].prompt)
	
	begin_menu()

func initialize_save(path):
	var textFile = FileAccess.open(Global.custom_folder_path + path + ".txt", FileAccess.READ)
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

func begin_menu():
	var menu = mainMenu.instantiate()
	add_child(menu)
	menu.connect("beginPlay", begin_play)
	if(scenePointer):
		scenePointer.queue_free()
	scenePointer = menu

func begin_play():
	var play = playScene.instantiate()
	add_child(play)
	play.connect("beginMenu", begin_menu)
	if(scenePointer):
		scenePointer.queue_free()
	scenePointer = play
