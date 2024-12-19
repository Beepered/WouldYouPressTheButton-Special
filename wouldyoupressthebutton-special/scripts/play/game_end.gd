extends CanvasLayer

@onready var playController = $".."

func _on_play_again_pressed() -> void:
	playController.reset_game()

func _on_backto_menu_pressed() -> void:
	playController.beginMenu.emit()
