class_name PauseMenu
extends CanvasLayer
## The pause screen: Resume, Restart, Mute, Fullscreen and Quit. `Esc` opens
## and closes it. It runs while the tree is paused.

@export var root_control: Control
@export var panel: Control
@export var resume_button: Button
@export var restart_button: Button
@export var mute_button: Button
@export var fullscreen_button: Button
@export var quit_button: Button

var _tween: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(close)
	restart_button.pressed.connect(func() -> void:
		var game: Game = get_tree().get_first_node_in_group(&"game") as Game
		if game != null:
			game.restart()
	)
	mute_button.pressed.connect(func() -> void:
		Audio.set_muted(not Audio.muted)
		_refresh()
	)
	fullscreen_button.pressed.connect(func() -> void:
		GameSettings.toggle_fullscreen(get_window())
		_refresh()
	)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	Audio.mute_changed.connect(func(_muted: bool) -> void: _refresh())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	var game: Game = get_tree().get_first_node_in_group(&"game") as Game
	if game == null or not game.playing:
		return
	get_viewport().set_input_as_handled()
	if visible:
		close()
	else:
		open()


func open() -> void:
	visible = true
	get_tree().paused = true
	_refresh()
	root_control.modulate.a = 0.0
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2.ONE * 0.85
	_kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(root_control, "modulate:a", 1.0, 0.18)
	_tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	resume_button.grab_focus()


func close() -> void:
	_kill()
	_tween = create_tween()
	_tween.tween_property(root_control, "modulate:a", 0.0, 0.15)
	_tween.tween_callback(func() -> void:
		visible = false
		get_tree().paused = false
	)


func _refresh() -> void:
	mute_button.text = "Sound: off" if Audio.muted else "Sound: on"
	fullscreen_button.text = "Fullscreen: on" if bool(GameSettings.get_value("fullscreen", false)) else "Fullscreen: off"


func _kill() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
