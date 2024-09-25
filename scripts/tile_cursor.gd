extends Node2D

@onready var soil_check_area = $SoilCheckArea
@onready var plant_check_area = $PlantCheckArea

func hasSoil():
	return soil_check_area.has_overlapping_areas()
	
func hasPlant():
	return plant_check_area.has_overlapping_areas()
	
func getPlant():
	return plant_check_area.get_overlapping_areas()[0].get_parent()
