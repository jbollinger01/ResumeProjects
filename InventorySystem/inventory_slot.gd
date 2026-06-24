class_name InventorySlot extends Resource

"""
-> The slot hold the items

Purpose:
	This is the per slot data:
		what item is in this slot
		how many if any
	includes functionaility of the slot
		clearing, and more to be added
	this cleans up things because I can
		slot.item to get the item
		slot.quantity to get the amount
		slot.clear() to clear the slot
		
		else i would have to:
			if inventory[i].["item"] == null
		how i can
			if inventory[i].is_empty()
"""


@export var item: InventoryItem
@export var quantity: int = 0



func clear() -> void:
	item = null
	quantity = 0

func set_item(new_item: InventoryItem, new_quantity: int = 1) -> void:
	item = new_item
	quantity = new_quantity
	
	if item == null or quantity <= 0:
		clear()

func is_empty() -> bool:
	return item == null or quantity <= 0

func can_stack_with(incoming_item: InventoryItem) -> bool:
	if is_empty():
		return false
	if incoming_item == null:
		return false
	if item != incoming_item:
		return false
	if quantity >= item.max_stack:
		return false
	
	return true

func can_split() -> bool:
	return not is_empty() and quantity > 1
