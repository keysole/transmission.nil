class_name Target
extends Area2D

signal clicked(_target_data : TargetData)

@export var target_data : TargetData
@export var is_moving := false


func _ready() -> void:
	self.hide()
	set_active(false)
	if target_data:
		$Label.text = target_data.code_name + '-' + str(target_data.code_num)


func reveal() -> void:
	if self.visible:
		return

	%RevealSfx.play()
	self.show()
	if is_moving:
		$SfxTimer.start()
		$SfxTimer.timeout.connect(_sfx_timeout)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(target_data)
		get_viewport().set_input_as_handled()


func set_active(value : bool) -> void:
	self.monitorable = value
	self.monitoring = value


func _sfx_timeout() -> void:
	%RevealSfx.play()
