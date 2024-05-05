extends ItemList
class_name StagesItemList

func _ready():
	self.clear()
	for stage in DataProvider.stage_list:
		var stage_id: int = stage["ID"]
		var stage_no: int = stage["StageNo"]
		add_item("%s [%s]" % [tr(str("STAGE_NAME_",stage_id)), stage_id])
		set_item_metadata(get_item_count()-1, stage_no)
