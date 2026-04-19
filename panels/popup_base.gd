class_name PopupBase
extends Control

signal closed
signal top_pressed

var grabbed := false
var mouse_pressed := false
var mouse_pos : Vector2
var grab_threshold := 5
var grab_offset : Vector2


func _ready() -> void:
	%Top.gui_input.connect(_topbar_gui_input)
	#%PopupClose.pressed.connect(func() -> void: closed.emit())
	%PopupClose.pressed.connect(_closed)


func _physics_process(delta: float) -> void:
	if grabbed:
		var screen_size := DisplayServer.screen_get_size()
		self.global_position = get_global_mouse_position() - grab_offset
		self.global_position.x = clamp(self.global_position.x, -self.size.x * 0.9, screen_size.x * 0.9)
		self.global_position.y = clamp(self.global_position.y, 0, screen_size.y * 0.9)


func _topbar_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grab_offset = event.position
			mouse_pressed = true
			mouse_pos = get_global_mouse_position()
			get_viewport().set_input_as_handled()
			top_pressed.emit()
			self.move_to_front()
		elif event.is_released():
			grabbed = false
			grab_offset = Vector2.ZERO
			mouse_pressed = false
			mouse_pos = Vector2.ZERO
	elif event is InputEventMouseMotion and mouse_pressed:
		if mouse_pos.distance_to(get_global_mouse_position()) >= grab_threshold:
			grabbed = true


func _closed() -> void:
	closed.emit()
	self.queue_free()
