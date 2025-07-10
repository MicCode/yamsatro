extends Panel

signal start_button_pressed

func _on_start_button_pressed() -> void:
    start_button_pressed.emit()
