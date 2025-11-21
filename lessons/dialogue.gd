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
var dialogue_items: Array[Dictionary] = [
	{
		"expression": expressions["regular"],
		"text": "[wave]Hey, wake up![/wave]\nIt's time to make video games.",
		"character": bodies["sophia"],
		"choices": {
			"Let me sleep a little longer": 2,
			"Let's do it!": 1,
		},
	},
	{
		"expression": expressions["happy"],
		"text": "Great! Your first task will be to write a [b]dialogue tree[/b].",
		"character": bodies["sophia"],
		"choices": {
			"I will do my best": 3,
			"No, let me go back to sleep": 2,
		},
	},
	{
		"expression": expressions["sad"],
		"text": "Oh, come on! It'll be fun.",
		"character": bodies["pink"],
		"choices": {
			"No, really, let me go back to sleep": 0,
			"Alright, I'll try": 1,
		},
	},
	{
		"expression": expressions["happy"],
		"text": "That's the spirit! [wave]You can do it![/wave]",
		"character": bodies["pink"],
		"choices": {"Okay! (Quit)": - 1},
	},
]



@onready var rich_text_label: RichTextLabel = %RichTextLabel

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

@onready var body: TextureRect = %Body

@onready var expression: TextureRect = %Expression
@onready var action_buttons_v_box_container: VBoxContainer = %ActionButtonsVBoxContainer

func _ready() -> void:
	show_text(0)


func show_text(current_item_index: int) -> void:
	
	var current_item := dialogue_items[current_item_index]

	rich_text_label.text = current_item["text"]
	expression.texture = current_item["expression"]
	body.texture = current_item["character"]
	create_buttons(current_item["choices"])
	
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


func create_buttons(choices_data: Dictionary) -> void:
	for button in action_buttons_v_box_container.get_children():
		button.queue_free()
	# We loop over all the dictionary keys
	for choice_text in choices_data:
		var button := Button.new()
		action_buttons_v_box_container.add_child(button)
		button.text = choice_text
		var target_line_idx: int = choices_data[choice_text]
		if target_line_idx == -1:
			button.pressed.connect(get_tree().quit)
		else:
			button.pressed.connect(show_text.bind(target_line_idx))

func slide_in() -> void:
	var slide_tween := create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	body.position.x = get_viewport_rect().size.x / 7
	slide_tween.tween_property(body, "position:x", 0, 0.3)
	body.modulate.a = 0
	slide_tween.parallel().tween_property(body, "modulate:a", 1, 0.2)
