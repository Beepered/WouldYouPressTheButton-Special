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
	
	begin_menu()

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
