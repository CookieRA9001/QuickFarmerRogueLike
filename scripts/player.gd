extends CharacterBody2D 
## COMPONENTS
@onready var sprite = $Smoothing2D/Sprite
@onready var click_input_delay_timer = $InteractInputDelayTimer
@onready var scroll_delay_timer = $ScrollDelayTimer
@onready var action_delay_timer = $ActionDelayTimer
## PREFABS
const TILE_CURSOR = preload("res://objects/tile_cursor.tscn")
## ENUMS
enum CURSER_MODES {TILE_SELECT, FIRE_DIRECTION}
## VALUES
var speed_unit = 16
var speed = speed_unit * 5 # unit * speed
var axis = Vector2.ZERO
var curserMode:CURSER_MODES = CURSER_MODES.TILE_SELECT
var seeds = [
	{"name": "hoe", "qty": INF, "delay": 0.5},
	{"name": "carrot", "qty": 10, "delay": 0.25},
	{"name": "potato", "qty": 5, "delay": 2}
]
var currentSeedIndex = 0
## REFS
var tileCurserRef:Node2D = null

func _ready():
	tileCurserRef = TILE_CURSOR.instantiate()
	get_tree().get_root().add_child.call_deferred(tileCurserRef)

func updateCurrentSeed():
	scroll_delay_timer.start()
	currentSeedIndex = currentSeedIndex % seeds.size()

func useSelectedSeed():
	var seed = seeds[currentSeedIndex]
	action_delay_timer.wait_time = seed.delay
	action_delay_timer.start()
	
	match seed.name:
		"hoe":
			pass
		"carrot":
			pass
		"potato":
			pass

func _process(delta):
	if Input.is_action_pressed("interact") and click_input_delay_timer.is_stopped():
		curserMode = CURSER_MODES.TILE_SELECT if curserMode == CURSER_MODES.FIRE_DIRECTION else CURSER_MODES.FIRE_DIRECTION
		click_input_delay_timer.start()
	
	if scroll_delay_timer.is_stopped():
		if Input.is_action_just_released("select_up"):
			currentSeedIndex+=1
			updateCurrentSeed()
		if Input.is_action_just_released("select_down"):
			currentSeedIndex-=1
			updateCurrentSeed()
			
	if action_delay_timer.is_stopped() and Input.is_action_pressed("use"):
		if curserMode == CURSER_MODES.TILE_SELECT:
			useSelectedSeed()
	
	var mouse_pos = get_global_mouse_position() + Vector2(8,8)
	mouse_pos = (mouse_pos/16).floor()*16
	tileCurserRef.position = mouse_pos
	tileCurserRef.visible = curserMode == CURSER_MODES.TILE_SELECT
	
	
func _physics_process(delta):
	axis.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	axis.y = Input.get_action_strength("down")-Input.get_action_strength("up")

	axis = axis.normalized() * speed

	velocity = velocity.lerp(axis, 0.1)

	move_and_slide()
