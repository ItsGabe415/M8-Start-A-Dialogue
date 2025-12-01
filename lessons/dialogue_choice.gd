@icon("res://assets/dialogue_scene_icon.svg")
class_name DialogueChoice extends Resource
@export var text := ""
@export_range(0, 20) var target_line_idx := 0
@export var is_quit := false
