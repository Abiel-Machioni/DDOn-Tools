extends PanelContainer
class_name GenericSetPlacemark

onready var _original_zoom : float = get_tree().get_nodes_in_group("camera")[0].original_zoom
onready var _original_scale := rect_scale
onready var selected_indices = []

func _ready():
	SelectedListManager.connect("set_revealed_hidden", self, "_to_unhide")

func _process(_delta):
	var camera_zoom: float = get_tree().get_nodes_in_group("camera")[0].zoom.x
	rect_scale = _original_scale * clamp(camera_zoom, 0, _original_zoom)
	
func _to_hide():
	self.modulate = Color(1, 1, 1, 0.25)  # Lowering the transparency to 25%
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_mouse_filter_to_children(self, Control.MOUSE_FILTER_IGNORE)

func _to_unhide():
	self.modulate = Color(1, 1, 1, 1)  # Raising the transparency to 100%
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	_apply_mouse_filter_to_children(self, Control.MOUSE_FILTER_PASS)

func _apply_mouse_filter_to_children(node, filter):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter
		_apply_mouse_filter_to_children(child, filter)
