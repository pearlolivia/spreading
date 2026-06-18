extends Control

@onready var life_1 = $LivesLeft/Lives/HeartContainer/Heart1
@onready var life_2 = $LivesLeft/Lives/HeartContainer2/Heart2
@onready var life_3 = $LivesLeft/Lives/HeartContainer3/Heart3
@onready var wave_bar = $Wave/WaveProgress
@onready var wave_timer = $Wave/WaveTimer

@onready var empty_heart = preload("res://assets/ui/heart-empty.png")

func _process(delta: float) -> void:
	# monitor wave progress
	wave_bar.value  = wave_timer.time_left
	
	# update lives
	match (Global.LIVES):
		2:
			life_3.texture = empty_heart
		1:
			life_2.texture = empty_heart
		0:
			life_1.texture = empty_heart
