extends RigidBody2D

@export var speed = 1


func _physics_process(delta: float) -> void:
	if Globals.player:
		var direction: Vector2 = Globals.player.global_position - global_position
		var motion = direction.normalized() * speed
		move_and_collide(motion)
