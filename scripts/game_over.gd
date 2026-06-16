extends Node2D

@onready var Score = $Control/VBoxContainer2/Score
@onready var Slimes = $Control/ScoreCard/Slimes
@onready var Plants = $Control/ScoreCard2/Plants

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Score.text = str(Global.SCORE)
	Slimes.text = str(Global.SLIMES_KILLED)
	
	var plants_saved = Global.TOTAL_PLANTS - Global.PLANTS_DESTROYED
	Plants.text = str(plants_saved) + '/' + str(Global.TOTAL_PLANTS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("attack")):
		reset()

func reset():
	Global.LIVES = 3
	Global.SCORE = 0
	Global.SLIMES_KILLED = 0
	Global.PLANTS_DESTROYED = 0
	Global.WAVE = 1
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
