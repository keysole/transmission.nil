class_name Radar
extends Control

signal target_revealed(target_data : TargetData)
signal finished_radial_scan
signal finished_directional_scan

@export var small_draw_radius = 50
@export var big_draw_radius = 5000.0
@export var draw_angle = 20.0
@export var direct_speed = 300.0
@export var targets : Dictionary[World.Sequence, Control]

const WAVE = preload('res://test/radio_wave.tscn')
const TARGET_DATA_PANEL = preload('res://panels/target/target_data_panel.tscn')

var frequency_start = 136
var mouse_on_target := false

@export var circle_draw_speed = 350.0
@export var sector_fill_color := Color.GREEN
var circle_rad := 10.0

var drawing_circle := false
var drawing_sector := false

var directional_scan_active := false

var draw_angle_start = 40
var draw_radius = small_draw_radius


func _ready() -> void:
	connect_targets()
	%ScanAreaRadial.area_entered.connect(_scan_area_radial_entered)
	%ScanAreaDirectional.area_entered.connect(_scan_area_directional_entered)
	
	for t in targets.values():
		t.hide()


func show_radial_scan() -> void:
	drawing_circle = true


func _process(delta: float) -> void:
	if drawing_circle:
		circle_rad += circle_draw_speed * delta
		%CollisionShapeRadial.shape.radius = circle_rad
		queue_redraw()
		
		if (self.size.x - circle_rad * 2) < -100:
			drawing_circle = false
			circle_rad = 10.0
			finished_radial_scan.emit()
			queue_redraw()
	elif drawing_sector:
		if directional_scan_active:
			draw_radius += delta * direct_speed
		queue_redraw()
		
		if draw_radius >= big_draw_radius:
			draw_radius = small_draw_radius
			directional_scan_active = false
			finished_directional_scan.emit()
			queue_redraw()


func _draw() -> void:
	if drawing_circle:
		draw_circle(%Center.position, circle_rad, Color.GREEN, false, 4.0)
	elif drawing_sector:
		draw_sector()
		if directional_scan_active:
			draw_sector_poly(%Center.position, draw_radius, draw_angle_start - draw_angle, draw_angle_start + draw_angle, sector_fill_color, 2)
			


func draw_sector() -> void:
	var outline_color = Color.GREEN
	var line_width = 2
	var draw_radius = 150
	var fill_color = Color.GREEN
	
	
	draw_circle_arc(%Center.position, small_draw_radius, draw_angle_start - draw_angle, draw_angle_start + draw_angle, outline_color, line_width)
	draw_circle_arc(%Center.position, big_draw_radius, draw_angle_start - draw_angle, draw_angle_start + draw_angle, outline_color, line_width)
	
	var start_pos = %Center.position - Vector2.RIGHT.rotated(deg_to_rad(draw_angle_start - draw_angle) + PI/2.0) * small_draw_radius
	var end_pos = %Center.position - Vector2.RIGHT.rotated(deg_to_rad(draw_angle_start - draw_angle) + PI/2.0) * big_draw_radius
	draw_line(end_pos, start_pos, outline_color, line_width, true)
	
	start_pos = %Center.position - Vector2.RIGHT.rotated(deg_to_rad(draw_angle_start + draw_angle) + PI/2.0) * small_draw_radius
	end_pos = %Center.position - Vector2.RIGHT.rotated(deg_to_rad(draw_angle_start + draw_angle) + PI/2.0) * big_draw_radius
	draw_line(end_pos, start_pos, outline_color, line_width, true)


func draw_circle_arc(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color, line_width : float) -> void:
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, line_width, true)
		

func draw_sector_poly(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color, line_width : float):
	var nb_points = 32
	var sector_polygon = PackedVector2Array()
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		sector_polygon.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * small_draw_radius)
	for i in range(nb_points, -1, -1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		sector_polygon.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * draw_radius)
	draw_polygon(sector_polygon, colors)

	var col_polygon = PackedVector2Array()
	for p in sector_polygon:
		col_polygon.append(p - %Center.position)
	%CollisionPolygon2D.polygon = col_polygon


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 24
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points )
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)



func connect_targets() -> void:
	var targets = get_tree().get_nodes_in_group(&'targets')
	for t : Target in targets:
		t.mouse_entered.connect(func() -> void: mouse_on_target = true) ## _input_event is always last
		t.mouse_exited.connect(func() -> void: mouse_on_target = false)
		t.clicked.connect(_show_target_data_panel)


func _show_target_data_panel(target_data : TargetData) -> void:
	var target_data_panel = TARGET_DATA_PANEL.instantiate() as TargetDataPanel
	target_data_panel.set_frequency_data(target_data, frequency_start)
	%Panels.add_child(target_data_panel)
	%PanelSfx.play()


func hide_targets(sequence : World.Sequence) -> void:
	if targets.get(sequence) != null:
		var current_target = targets.get(sequence)
		current_target.hide()

		for t : Target in current_target.get_children():
			t.set_active(false) 


func show_targets(sequence : World.Sequence) -> void:
	%CollisionPolygon2D.polygon = PackedVector2Array()
	%CollisionShapeRadial.shape.radius = 0
	
	if targets.get(sequence) != null and sequence != World.Sequence.SIXTH:
		var current_target = targets.get(sequence)
		current_target.show()
		
		for t : Target in current_target.get_children():
			t.set_active(true) 
	elif targets.get(sequence) != null and sequence == World.Sequence.SIXTH:
		var current_target = targets.get(sequence)
		current_target.show()
		%MovingTarget.set_active(true)


func set_draw_sector(value : bool) -> void:
	drawing_sector = value
	queue_redraw()


func _scan_area_directional_entered(area : Area2D) -> void:
	if !(area is Target):
		return
	
	var target = area as Target
	
	if World.is_target_detected(target.target_data.frequencies):
		target.reveal()
		target_revealed.emit(target.target_data)


func _scan_area_radial_entered(area : Area2D) -> void:
	if !(area is Target):
		return
	
	var target = area as Target
	
	if World.is_target_detected(target.target_data.frequencies) and target.target_data.distance <= World.radial_scan_max_range:
		target.reveal()
		target_revealed.emit(target.target_data)
