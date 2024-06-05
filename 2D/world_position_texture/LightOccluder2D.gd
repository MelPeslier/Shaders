@tool
extends LightOccluder2D

@export var parent: Polygon2D :
	set(_parent):
		parent = _parent
		if parent:
			occluder = OccluderPolygon2D.new()
			occluder.polygon = parent.polygon
