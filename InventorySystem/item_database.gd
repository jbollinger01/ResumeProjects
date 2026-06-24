class_name ItemDatabase extends Resource

@export var items: Array[InventoryItem] = []

func get_item_by_id(item_id: String) -> InventoryItem:
	if item_id == "":
		return null
	for item in items:
		if item == null:
			continue
		if item.item_id == item_id:
			return item
	
	return null
