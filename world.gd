class_name World
extends Control

@export var debug := false
@export var with_crt := true

@export var targets : Dictionary[Sequence, AllTargetsData]

#@export var first_sequence_targets : Array[TargetData]
@export var answers : Dictionary[Sequence, AnswerData]
@export var comms : Dictionary[Sequence, CommsData]


const TARGET_LIST = preload('res://panels/target/targets_list.tscn')
const TARGET_DATA_PANEL = preload('res://panels/target/target_data_panel.tscn')

enum Sequence 
{
	NONE = -1, 
	FIRST,
	SECOND,
	THIRD,
	FOURTH,
	FIFTH,
	SIXTH,
}

@export var current_sequence := Sequence.NONE

static var current_min_freq := 0
static var current_max_freq := 0

static var freq_step := 30

static var scan_min_freq := 100
static var scan_max_freq := 350

static var directional_scan_min_freq := 10
static var directional_scan_max_freq := 95

static var radial_scan_max_range := 25
static var directional_scan_max_range := 50


func _ready() -> void:
	%QuitButton.pressed.connect(_quit)
	%CollisionPolygon2D.disabled = true
	%SetupPanel.angle_changed.connect(_angle_changed)
	%SetupPanel.changed_mode.connect(_changed_mode)
	%SetupPanel.requested_scan.connect(_requested_scan)
	%TransmissionPanel.requested_transmission.connect(_requested_transmission)
	
	%MapPanel.target_revealed.connect(_target_revealed)
	%MapPanel.finished_radial_scan.connect(_finished_radial_scan)
	%MapPanel.finished_directional_scan.connect(_finished_directional_scan)
	
	if with_crt:
		%CRT.show()
		
	if current_sequence == Sequence.NONE and !debug:
		start_game()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&'dbg') and debug:
		switch_to_next_sequence()
	elif Input.is_action_just_pressed(&'fullscr'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)


func start_game() -> void:
	switch_to_next_sequence()


func _requested_scan(mode : SetupPanel.Mode, min_freq : int, max_freq : int) -> void:
	assert(mode != SetupPanel.Mode.NONE)
	
	if min_freq > max_freq:
		return
	
	current_min_freq = min_freq
	current_max_freq = max_freq
	
	if mode == SetupPanel.Mode.RADIAL:
		%MapPanel.show_radial_scan()
	elif mode == SetupPanel.Mode.DIRECTIONAL:
		%CollisionPolygon2D.disabled = false
		%MapPanel.directional_scan_active = true
		#%MapPanel.set_draw_sector(true,)


func _finished_radial_scan() -> void:
	#%CollisionPolygon2D.disabled = true
	%SetupPanel.set_active(true)
	
#	var target_list = TARGET_LIST.instantiate()
#	target_list.target_selected.connect(_target_selected)
#	var found_targets : Array[TargetData]
	
#	var current_targets = targets.get(current_sequence).list
#	filter_targets(current_targets, found_targets)
	
#	self.add_child(target_list)
#	target_list.set_data(found_targets)


func _finished_directional_scan() -> void:
	%SetupPanel.set_active(true)


func filter_targets(possible_targets : Array[TargetData], found_targets : Array[TargetData]) -> void:
	for t : TargetData in possible_targets:
		if is_target_detected(t.frequencies):
			found_targets.append(t)


static func is_target_detected(frequencies : Dictionary[int, int]) -> bool:
	for freq in frequencies.keys():
		if freq >= current_min_freq and freq <= current_max_freq:
			return true 
	return false


func _target_selected(target_data : TargetData) -> void:
	var target_data_panel = TARGET_DATA_PANEL.instantiate()
	
	target_data_panel.set_frequency_data(target_data, current_min_freq)
	
	self.add_child(target_data_panel)


func _requested_transmission(answer : Array[String]) -> void:
	var is_correct = _check_answer(answer)
	
	if is_correct:
		%SetupPanel.set_active(false)
		%TransmissionPanel.set_active(false)
		await %CommsPanel.show_answer_status_text(comms.get(current_sequence), true)
		switch_to_next_sequence()
	else:
		%TransmissionPanel.set_active(false)
		await %CommsPanel.show_answer_status_text(comms.get(current_sequence), false)
		%CommsPanel.show_current_description()
		%TransmissionPanel.set_active(true)
		%SetupPanel.set_active(true)


func _check_answer(transmission_answer : Array[String]) -> bool:
	if current_sequence == Sequence.NONE:
		return false
	
	var current_answer = answers.get(current_sequence) as AnswerData
	
	
	if current_answer.list.size() != transmission_answer.size():
		return false
	
	for ans_target : TargetData in current_answer.list:
		var code = ans_target.code_name.to_upper() + str(ans_target.code_num)
		
		if !(code in transmission_answer):
			return false
	
	return true


func switch_to_next_sequence() -> void:
	%MapPanel.hide_targets(current_sequence)
	
	%TransmissionPanel.set_active(false)
	%SetupPanel.set_active(false)
	current_sequence += 1
	
	var answer = answers.get(current_sequence)
	if answer != null:
		var answer_count = answer.list.size()
		%TransmissionPanel.set_answer_containers(answer_count)

	
	await %CommsPanel.show_mission_text(comms.get(current_sequence))
	
	if current_sequence != Sequence.SIXTH:
		%TransmissionPanel.set_active(true)
	%SetupPanel.set_active(true)
	%MapPanel.show_targets(current_sequence)
	
	
	#if current_sequence == Sequence.SIXTH:
	#	print('Final')
	#	$AnimationPlayer.play(&'End')


func _changed_mode(mode : SetupPanel.Mode) -> void:
	if mode == SetupPanel.Mode.DIRECTIONAL:
		%MapPanel.set_draw_sector(true)
	else:
		%MapPanel.set_draw_sector(false)


func _angle_changed(angle : float) -> void:
	%MapPanel.draw_angle_start = angle


func _target_revealed(target_data : TargetData) -> void:
	if target_data.code_name == 'ED' and target_data.code_num == 20:
		print('Final')
		$AnimationPlayer.play(&'End')



func _quit() -> void:
	get_tree().quit()
