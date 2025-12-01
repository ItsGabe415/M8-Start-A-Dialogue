extends Control

var expressions := {
	"happy": preload ("res://assets/emotion_happy.png"),
	"regular": preload ("res://assets/emotion_regular.png"),
	"sad": preload ("res://assets/emotion_sad.png"),
}

var bodies := {
	"sophia": preload ("res://assets/sophia.png"),
	"pink": preload ("res://assets/pink.png")
}

## An array of dictionaries. Each dictionary has three properties:
## - expression: a [code]Texture[/code] containing an expression
## - text: a [code]String[/code] containing the text the character says
## - character: a [code]Texture[/code] representing the character
@export var dialogue_items: Array[DialogueItem] = []




@onready var rich_text_label: RichTextLabel = %RichTextLabel

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

@onready var body: TextureRect = %Body

@onready var expression: TextureRect = %Expression
@onready var action_buttons_vbox_container: VBoxContainer = %ActionButtonsVboxContainer


func _ready() -> void:
	show_text(0)


func show_text(current_item_index: int) -> void:
	
	var current_item := dialogue_items[current_item_index]

	rich_text_label.text = current_item.text
	expression.texture = current_item.expression
	body.texture = current_item.character
	create_buttons(current_item.choices)
	
	rich_text_label.visible_ratio = 0.0

	var tween := create_tween()
	
	var text_appearing_duration: float = current_item["text"].length() / 30.0

	tween.tween_property(rich_text_label, "visible_ratio", 1.0, text_appearing_duration)
	
	var sound_max_offset := audio_stream_player.stream.get_length() - text_appearing_duration
	
	var sound_start_position := randf() * sound_max_offset

	audio_stream_player.play(sound_start_position)
	# We make sure the sound stops when the text finishes displaying
	tween.finished.connect(audio_stream_player.stop)

	slide_in()


func create_buttons(choices_data: Array[DialogueChoice]):
	for button in action_buttons_vbox_container.get_children():
		button.queue_free()
	# We loop over all the dictionary keys
	for choice in choices_data:
		var button := Button.new()
		action_buttons_vbox_container.add_child(button)
		button.text = choice.text
		if choice.is_quit == true:
			button.pressed.connect(get_tree().quit)
		else:
			var target_line_idx := choice.target_line_idx
			button.pressed.connect(show_text.bind(target_line_idx))

func slide_in() -> void:
	var slide_tween := create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	body.position.x = get_viewport_rect().size.x / 7
	slide_tween.tween_property(body, "position:x", 0, 0.3)
	body.modulate.a = 0
	slide_tween.parallel().tween_property(body, "modulate:a", 1, 0.2)
