extends Control

@onready var seed_select = $SeedSelect
@onready var selected_txt:Label = $SeedSelect/SelectedTxt
@onready var next_up_txt:Label = $SeedSelect/NextUpTxt
@onready var next_down_txt:Label = $SeedSelect/NextDownTxt

# Called when the node enters the scene tree for the first time.
func _ready():
	GM.player_seed_select_change.connect(updateSeedSelect)
	
func updateSeedSelect(player):
	var pseed = player.seeds[player.currentSeedIndex]
	var pseed_up = player.seeds[(player.currentSeedIndex+1) % player.seeds.size()]
	var pseed_down = player.seeds[(player.currentSeedIndex-1) % player.seeds.size()]
	selected_txt.text = "Selected: " + pseed.name + " [" + str(pseed.qty) + "]"
	next_up_txt.text = "Scroll Up: " + pseed_up.name + " [" + str(pseed_up.qty) + "]"
	next_down_txt.text = "Scroll Down: " + pseed_down.name + " [" + str(pseed_down.qty) + "]"


