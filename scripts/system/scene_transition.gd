extends CanvasLayer

@onready var fade: ColorRect = $Fade

@export var fade_duration: float = 0.35

var changing_scene: bool = false


func _ready() -> void:
	fade.visible = true
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene(scene_path: String) -> void:
	if changing_scene:
		return

	changing_scene = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP

	var fade_out := create_tween()
	fade_out.tween_property(
		fade,
		"modulate:a",
		1.0,
		fade_duration
	)

	await fade_out.finished

	var error := get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error(
			"Não foi possível carregar a cena: " + scene_path
		)

		var recovery_tween := create_tween()
		recovery_tween.tween_property(
			fade,
			"modulate:a",
			0.0,
			fade_duration
		)

		await recovery_tween.finished

		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		changing_scene = false
		return

	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(
		fade,
		"modulate:a",
		0.0,
		fade_duration
	)

	await fade_in.finished

	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	changing_scene = false
