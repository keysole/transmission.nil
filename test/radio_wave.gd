extends Node2D

@export var speed = 2.0


func _ready() -> void:
	$Area2D.area_entered.connect(_area_entered)


func _area_entered(area : Area2D) -> void:
	if area is Target:
		area.reveal()


func _process(delta: float) -> void:
	self.move_local_x(delta * speed)
