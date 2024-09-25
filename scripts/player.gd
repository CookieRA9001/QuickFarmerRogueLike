extends CharacterBody2D 
## COMPONENTS
@onready var sprite = $Smoothing2D/Sprite
@onready var click_input_delay_timer = $InteractInputDelayTimer
@onready var scroll_delay_timer = $ScrollDelayTimer
@onready var action_delay_timer = $ActionDelayTimer
## PREFABS
const TILE_CURSOR = preload("res://objects/tile_cursor.tscn")
const SOIL = preload("res://objects/soil.tscn")
const PLANT_CARROT = preload("res://objects/plant_carrot.tscn")
const PLANT_POTATO = preload("res://objects/plant_potato.tscn")
## ENUMS
enum CURSER_MODES {TILE_SELECT, FIRE_DIRECTION}
enum TILE_TYPES {EMPTY, SOIL, PLANT}
## VALUES
var speed_unit = 16
var speed = speed_unit * 5 # unit * speed
var axis = Vector2.ZERO
var curserMode:CURSER_MODES = CURSER_MODES.TILE_SELECT
# TODO: Make more modulear outside of the player for ez moding
# TODO: Maybe remove the delay: its not fun and needs extra ui logic to tell the player that its on cooldown
var seeds = [
	{"name": "hoe", "qty": INF, "delay": 0.2, "tile_needed": TILE_TYPES.EMPTY},
	{"name": "scythe", "qty": INF, "delay": 0.2, "tile_needed": TILE_TYPES.PLANT},
	{"name": "carrot", "qty": 10, "delay": 0.2, "tile_needed": TILE_TYPES.SOIL},
	{"name": "potato", "qty": 5, "delay": 0.2, "tile_needed": TILE_TYPES.SOIL}
]
var currentSeedIndex = 0
## REFS
var tileCurserRef:Node2D = null

func _ready():
	tileCurserRef = utilInit(TILE_CURSOR)
	updateCurrentSeed()

func utilInit(prefab, pos = null):
	var node:Node2D = prefab.instantiate()
	get_tree().get_root().add_child.call_deferred(node)
	if pos:
		node.position = pos
	return node

func updateCurrentSeed():
	scroll_delay_timer.start()
	currentSeedIndex = currentSeedIndex % seeds.size()
	GM.player_seed_select_change.emit(self)

func useSelectedSeed():
	var seed = seeds[currentSeedIndex]
	action_delay_timer.wait_time = seed.delay
	action_delay_timer.start()
	
	if !checkUnderTileCurrser(seed.tile_needed):
		print("Seed/tool can't be used")
		return
		
	if seed.qty-1 < 0: # TODO: Add qty/use to items?
		print("Not enough to use")
		return
		
	seed.qty -= 1
	updateCurrentSeed()
	
	match seed.name:
		"hoe":
			utilInit(SOIL, tileCurserRef.position)
		"carrot":
			utilInit(PLANT_CARROT, tileCurserRef.position)
		"potato":
			utilInit(PLANT_POTATO, tileCurserRef.position)
		"scythe":
			tileCurserRef.getPlant().queue_free()

func checkUnderTileCurrser(tile_type:TILE_TYPES):
	match tile_type:
		TILE_TYPES.EMPTY:
			return !(tileCurserRef.hasSoil() or tileCurserRef.hasPlant())
		TILE_TYPES.SOIL:
			return tileCurserRef.hasSoil() and !tileCurserRef.hasPlant()
		TILE_TYPES.PLANT:
			return tileCurserRef.hasPlant()
	return false

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
