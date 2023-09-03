extends ScrollContainer


func _process(delta: float) -> void:
	$'..'.size = $'../..'.size
	size = $'..'.size
	$'..'.position =  $'..'.size * .5 - $Container/GridContainer.size  * .5
	$'..'.size -= $'..'.position
	
