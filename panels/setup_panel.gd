class_name SetupPanel
extends Panel

signal angle_changed(angle : float)
signal changed_mode(mode : Mode)
signal requested_scan(mode : Mode, min_freq : int, max_freq : int)

enum Mode 
{
	NONE = -1,
	RADIAL,
	DIRECTIONAL
}


var current_mode := Mode.NONE


func _ready() -> void:
	%MinFreq.min_value = World.scan_min_freq
	%MinFreq.max_value = World.scan_max_freq
	%MaxFreq.min_value = World.scan_min_freq
	%MaxFreq.max_value = World.scan_max_freq
	
	%ScanButton.pressed.connect(_requested_scan)
	%ModeSelector.item_selected.connect(_mode_selected)
	
	%RangeContainer.hide()
	%AngleSlider.hide()
	%ScanButton.disabled = true
	
	%MinFreq.value_changed.connect(_min_freq_changed)
	
	%AngleSlider.value_changed.connect(_angle_changed)
	
	_mode_selected(%ModeSelector.selected)


func _mode_selected(ind : int) -> void:
	current_mode = ind
	
	if current_mode != Mode.NONE:
		%RangeContainer.show()
		%RangeLabel.text = str(World.radial_scan_max_range) if current_mode == Mode.RADIAL else str(World.directional_scan_max_range)
		%RangeLabel.text += 'km'
		%ScanButton.disabled = false
	
	%AngleSlider.visible = true if (current_mode == Mode.DIRECTIONAL) else false 
	
	set_frequencies()
	changed_mode.emit(current_mode)


func set_frequencies() -> void:
	if current_mode == Mode.RADIAL:
		%FrequencyLabel.text = 'Frequency %d-%d (MHz):' % [World.scan_min_freq, World.scan_max_freq]
		
		%MinFreq.min_value = World.scan_min_freq
		%MinFreq.max_value = World.scan_max_freq
		%MaxFreq.min_value = World.scan_min_freq
		%MaxFreq.max_value = World.scan_max_freq
	elif current_mode == Mode.DIRECTIONAL:
		%FrequencyLabel.text = 'Frequency %d-%d (MHz):' % [World.directional_scan_min_freq, World.directional_scan_max_freq]

		%MinFreq.min_value = World.directional_scan_min_freq
		%MinFreq.max_value = World.directional_scan_max_freq
		%MaxFreq.min_value = World.directional_scan_min_freq
		%MaxFreq.max_value = World.directional_scan_max_freq


func set_active(active : bool) -> void:
	%AngleSlider.editable = active
	%MinFreq.editable = active
	%ScanButton.disabled = !active
	%ModeSelector.disabled = !active


func _requested_scan() -> void:
	%ScanSfx.play()
	
	var min_freq = int(%MinFreq.value)
	var max_freq = int(%MaxFreq.value)
	set_active(false)
	
	requested_scan.emit(current_mode, min_freq, max_freq)


func _min_freq_changed(value : float) -> void:
	%ButtonSfx.play()
	
	
	var new_freq = roundf(value)
	%MaxFreq.value = new_freq + World.freq_step
	World.current_min_freq = new_freq
	World.current_max_freq = new_freq + World.freq_step


func _angle_changed(angle : float) -> void:
	if !%RotateSfx.playing:
		%RotateSfx.play()
	angle_changed.emit(angle)
