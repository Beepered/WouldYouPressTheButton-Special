extends Node2D

@export var mainMenu: PackedScene
@export var playScene: PackedScene

var scenePointer

func _ready() -> void:
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
