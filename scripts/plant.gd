class_name Plant extends Node2D

@onready var return_timer = $ReturnTimer
@onready var grow_timer:Timer = $GrowTimer
@onready var sprite:Sprite2D = $Sprite2D
@onready var area:Area2D = $Area2D

@export var seed_tag:String = "plant"
@export var seed_grown_texture:Texture
@export var grow_time:float = 2.0
@export var return_time: float = 1.0
@export var harvest_return: int = 2

#func _get_property_list():
	#var props = []
	#props.append({
		#name="seed_tag",
		#type=TYPE_STRING
	#})
	#props.append({
		#name="seed_grown_texture",
		#type=TYPE_OBJECT,
		#hint=PROPERTY_HINT_RESOURCE_TYPE,
		#hint_string="Texture",
		#useage=PROPERTY_USAGE_DEFAULT
	#})
	#props.append({
		#name="grow_time",
		#type=TYPE_FLOAT
	#})
	#props.append({
		#name="return_time",
		#type=TYPE_FLOAT
	#})
	#props.append({
		#name="harvest_return",
		#type=TYPE_INT
	#})
	#return props

func _ready():
	grow_timer.wait_time = grow_time
	grow_timer.timeout.connect(grow)
	grow_timer.start()

func grow():
	print("grow")
	sprite.texture = seed_grown_texture
	return_timer.wait_time = return_time
	return_timer.timeout.connect(returnHarvest)
	return_timer.start()
	
func returnHarvest():
	print("Harvest")
