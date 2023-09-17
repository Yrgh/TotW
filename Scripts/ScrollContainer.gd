extends ScrollContainer


func _process(delta: float) -> void:
	$'..'.size = $'../..'.size
	size = $'..'.size
	$'..'.position.x =  $'..'.size.x * .5 - $Container/GridContainer.size.x  * .5
	$'..'.size.x -= $'..'.position.x
	$'..'.size.y -= 0.0
