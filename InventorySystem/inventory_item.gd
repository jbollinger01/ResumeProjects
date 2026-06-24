class_name InventoryItem extends Resource

"""
-> items are held by a slot

Purpose:
	the item describes itself
	how many there are is a job for the inventory slot class
"""

# these should be changed to fit
# also change in the inventory_grid_system.gd 
#	function can_request_item_use
# TODO: Item System Checks
enum ItemType {
	MISC,
	CONSUMABLE,
	EQUIPMENT,
	MATERIAL,
	QUEST
}

@export var item_id: String = ""
@export var display_name: String
@export var icon: Texture2D
@export var max_stack: int = 1
@export var item_type: ItemType = ItemType.MISC
