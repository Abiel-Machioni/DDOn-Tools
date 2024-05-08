extends GenericSetPlacemark
class_name EnemySetPlacemark

export (PackedScene) var enemy_placemark_packed_scene: PackedScene = preload("res://UI/Marker/EnemyPlacemark.tscn")

export (Resource) var enemy_set: Resource

onready var _enemy_set := enemy_set as EnemySet


func _ready() -> void:
	_enemy_set.connect("changed", self, "_on_enemy_set_changed")
	_on_enemy_set_changed()
	
func _on_enemy_set_changed() -> void:
	# Rebuild children elements
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		
	for index in _enemy_set.get_enemies().size():
		var enemy: Enemy = _enemy_set.get_enemies()[index]
		enemy.connect("changed", self, "_on_enemy_changed", [enemy])
		var enemy_placemark: EnemyPlacemark = enemy_placemark_packed_scene.instance()
		enemy_placemark.enemy = enemy
		enemy_placemark.connect("placemark_removed", self, "_on_enemy_removed", [enemy, index])
		$VBoxContainer.add_child(enemy_placemark)
		
	_check_max_positions_exceeded()

func _on_enemy_changed(enemy: Enemy) -> void:
	_check_max_positions_exceeded()

func _on_enemy_removed(enemy: Enemy, index: int) -> void:
	if enemy.is_connected("changed", self, "_on_enemy_changed"):
		enemy.disconnect("changed", self, "_on_enemy_changed")
	_enemy_set.remove_enemy(index)
	

func add_enemy(enemy: Enemy) -> void:
	_enemy_set.add_enemy(enemy)

func clear_enemies() -> void:
	_enemy_set.clear_enemies()

func get_enemies() -> Array:
	return _enemy_set.get_enemies()

# Drag and drop functions
func can_drop_data(_position, data):
	return data is EnemyType
	
func drop_data(_position, data):
	add_enemy(Enemy.new(data))
	print_debug("Placed %s at %s (%d %d %d %d) " % [tr(data.name), tr(str("STAGE_NAME_",_enemy_set.stage_id)), _enemy_set.stage_id, _enemy_set.layer_no, _enemy_set.group_id, _enemy_set.subgroup_id])


func _check_max_positions_exceeded() -> void:
	var exceeded := _enemy_set.effective_enemy_count() > _enemy_set.max_positions
	$WarningLabel.visible = exceeded
	if exceeded:
		$WarningLabel.mouse_filter = Control.MOUSE_FILTER_PASS


# Bad homemade tooltip-like behavior since the normal tooltip doesnt shot up
func _on_WarningLabel_mouse_entered():
	$WarningLabel.visible_characters = -1

func _on_WarningLabel_mouse_exited():
	$WarningLabel.visible_characters = 1

func _on_WarningLabel_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		_on_WarningLabel_mouse_exited()
		$WarningLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
