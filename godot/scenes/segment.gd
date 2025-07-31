extends StaticBody2D

@export var line_number = 0


func _on_mouse_entered() -> void:
	SignalHub.loop_closed.emit(line_number)
