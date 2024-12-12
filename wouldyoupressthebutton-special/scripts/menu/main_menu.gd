extends Node2D

signal beginPlay

@export var customSelectionMenu: PackedScene

@onready var mainMenu = $Menu
@onready var settings = $Settings
@onready var instructions = $Instructions
@onready var credits = $Credits

func _ready() -> void:
	var dir = DirAccess.open(Global.custom_folder_path)
	dir.make_dir("custom-prompts")
	
	mainMenu.visible = true;
	settings.visible = false;
	instructions.visible = false;
	credits.visible = false;

@export var customChoice: PackedScene
func _on_setting_button_button_down() -> void:
	mainMenu.visible = false
	settings.visible = true;
	settings.fill_custom_container()

func _on_instructions_button_down() -> void:
	mainMenu.visible = false
	instructions.visible = true;

func _on_custom_button_pressed() -> void:
	mainMenu.visible = false
	var customMenu = customSelectionMenu.instantiate()
	add_child(customMenu)
	customMenu.connect("CustomFinished", custom_finished)

func custom_finished():
	mainMenu.visible = true

func _on_credits_button_down() -> void:
	mainMenu.visible = false
	credits.visible = true;

func _on_back_button_button_down() -> void:
	mainMenu.visible = true
	settings.visible = false;
	credits.visible = false;
	instructions.visible = false;
