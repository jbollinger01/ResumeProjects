class_name DragDropCell extends Button

"""
this only handle the visual aspect of the inventory.
and player interaction with the visual fires off signals.

the icons should be of the same size so the preview_scale will work correctly.

NB:
	the signal is connected to the drag_drop_grid.gd
"""


signal dragged(from: Vector2i, to: Vector2i, split_drag: bool)
signal drag_failed(from: Vector2i, release_global_position: Vector2, split_drag: bool)
signal split_drag_started(from: Vector2i)

var grid_position: Vector2i
@export var preview_scale: float = 1.25

var source_inventory: Object = null

var quantity_label: Label
var drag_in_progress: bool = false
var active_split_drag: bool = false
var current_quantity: int = 0
var split_preview_quantity: int = 0


func _ready() -> void:
	create_quantity_label()


# Called when clicking and starting to drag
func _get_drag_data(_at_position: Vector2) -> Variant:
	if icon == null:
		return null
	
	drag_in_progress = true
	active_split_drag = false
	var preview := create_preview(preview_scale, current_quantity)
	set_drag_preview(preview)
	
	icon = null
	text = ""
	
	if quantity_label != null:
		quantity_label.text = ""
	
	return {
		"source_cell": self,
		"from": grid_position,
		"split_drag": false,
		"source_type": "inventory",
		"quantity": current_quantity,
		"source_inventory": source_inventory
	}



# called when holding drag and hovering over this button
# this is where you drop the logic for "can i drop here" like weapon in the helmet slot.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data == null:
		return false
	if not data is Dictionary:
		return false
	if not data.has("from"):
		return false
	if not data.has("split_drag"):
		return false
	return true


# Called when releasing the mouse button, only if _can_drop_data returned true
# then it fires off the signal that is the to and from info
# the inventory_grid_system handles the move
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var from_position: Vector2i = data["from"]
	var to_position: Vector2i = grid_position
	var split_drag: bool = data["split_drag"]
	
	dragged.emit(from_position, to_position, split_drag)


# right click to pick up half the item stack
# it does not decide what will happen because this file is purely visual
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			if icon == null:
				return
			if current_quantity <= 1:
				return
			split_preview_quantity = ceili(current_quantity / 2.0)
			
			split_drag_started.emit(grid_position)
			call_deferred("start_split_drag")
			accept_event()

func start_split_drag() -> void:
	var preview := create_preview(preview_scale, split_preview_quantity)
	
	drag_in_progress = true
	active_split_drag = true
	
	force_drag({
		"from": grid_position,
		"split_drag": true,
		"source_type": "inventory", 
		"source_cell": self,
		"quantity": split_preview_quantity,
		"source_inventory": source_inventory
	}, preview)

# puts the icon's texture to the control node
func set_slot(slot: InventorySlot) -> void:
	if slot == null or slot.is_empty():
		icon = null
		text = ""
		current_quantity = 0
		
		if quantity_label != null:
			quantity_label.text = ""
		
		return
	
	icon = slot.item.icon
	text = ""
	current_quantity = slot.quantity
	
	if quantity_label == null:
		create_quantity_label()
	
	if slot.quantity > 1: # TODO should i show that there is only one of the item?
		quantity_label.text = str(slot.quantity)
	else:
		quantity_label.text = ""


# TODO RAW NUMBERS BELOW
func create_preview(scale_amount: float, quantity: int = 1) -> Control:
	var preview_root := Control.new()
	preview_root.custom_minimum_size = size
	
	var texture_rect := TextureRect.new()
	texture_rect.texture = icon
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size = size
	texture_rect.scale = Vector2(scale_amount, scale_amount)
	texture_rect.pivot_offset = size * 0.5
	
	preview_root.add_child(texture_rect)
	
	if quantity > 1:
		var quantity_label_drag := Label.new()
		quantity_label_drag.text = str(quantity)
		quantity_label_drag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity_label_drag.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		quantity_label_drag.size = size
		quantity_label_drag.add_theme_font_size_override("font_size", 18)
		
		preview_root.add_child(quantity_label_drag)
	
	return preview_root

# piece used for icon flyback on invalid icon drop
func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAG_END:
		return
	if not drag_in_progress:
		return
	
	var drag_successful := get_viewport().gui_is_drag_successful()
	var release_position := get_viewport().get_mouse_position()
	
	if not drag_successful:
		drag_failed.emit(grid_position, release_position, active_split_drag)
	
	drag_in_progress = false
	active_split_drag = false


func create_quantity_label() -> void:
	quantity_label = Label.new()
	quantity_label.name = "QuantityLabel"
	quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	quantity_label.anchor_left = 0.0
	quantity_label.anchor_top = 0.0
	quantity_label.anchor_right = 1.0
	quantity_label.anchor_bottom = 1.0
	
	quantity_label.offset_left = 0.0
	quantity_label.offset_top = 0.0
	quantity_label.offset_right = -4.0
	quantity_label.offset_bottom = -2.0
	
	quantity_label.add_theme_font_size_override("font_size", 16)
	add_child(quantity_label)
