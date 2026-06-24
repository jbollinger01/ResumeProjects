class_name DragDropGrid extends GridContainer
# TODO QUESTION: should this file automate the number of inventory slots made?
"""
purpose: 
	manages the grid of inventory slots. as an array of DragDropCells
	passes the signal when a drag/drop has been completed by the drag_and_drop_cell.gd
		so other scripts can connect the signal via the inventory_grid_system.gd

"""

signal dragged(from: Vector2i, to: Vector2i, split_drag: bool)
signal drag_failed(from: Vector2i, release_global_position: Vector2, split_drag: bool)
signal split_drag_started(from: Vector2i)

var cells: Array[DragDropCell] = []
@export var rows: int = 4
var source_inventory: Object = null


func _ready() -> void:
	var row: int = 0
	var column: int = 0
	
	# TODO QUESTION: Here
	# should i automate the creation of the cells?
	for child in get_children():
		var cell := child as DragDropCell
		if cell == null:
			continue
		
		cells.append(cell)
		
		cell.grid_position = Vector2i(column, row)
		cell.dragged.connect(dragged.emit)
		cell.drag_failed.connect(drag_failed.emit)
		cell.split_drag_started.connect(split_drag_started.emit)
		cell.source_inventory = source_inventory
		
		column += 1
		if column >= columns:
			column = 0
			row += 1


func set_cell_slot(index: int, slot: InventorySlot) -> void:
	if index < 0 or index >= cells.size():
		return
	cells[index].set_slot(slot)


# TODO RAW NUMBER BELOW
func get_cell_global_center(index: int) -> Vector2:
	if index < 0 or index >= cells.size():
		return global_position
	var cell := cells[index]
	return cell.global_position + cell.size * 0.5


func get_slot_count() -> int: 
	return cells.size()


func set_source_inventory(new_source_inventory: Object) -> void:
	source_inventory = new_source_inventory
	
	for cell in cells:
		if cell == null:
			continue
		cell.source_inventory = source_inventory
