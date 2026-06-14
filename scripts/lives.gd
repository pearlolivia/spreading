extends Control

@onready var life_1 = $Lives/HeartContainer/Heart1
@onready var life_2 = $Lives/HeartContainer2/Heart2
@onready var life_3 = $Lives/HeartContainer3/Heart3

@onready var empty_heart = preload("res://assets/ui/heart-empty.png")

func _process(delta: float) -> void:
	match (Global.LIVES):
		2:
			life_3.texture = empty_heart
		1:
			life_2.texture = empty_heart
		0:
			life_1.texture = empty_heart
