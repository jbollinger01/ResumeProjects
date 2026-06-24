class_name InventoryGridSystem extends Control
"""
Transfer receiver contract:
	
	The inventory is a logistics/accounting system. It tracks item references,
	slot placement, and quantities. It does not decide how items are used,
	equipped, consumed, sold, crafted, or destroyed. External systems own these
	decisions and call the inventory public API hwne item counts need to change.
	
	The inventory system has been designed to be fully decoupled from other systems.
	
	The inventory system may send items to any external receiver.
	The receiver decides how many items it accepts.
	The inventory only removes items after the receiver confirms acceptance.
	
	The inventory may also receive items from any external sender.
	The inventory decides how many offered items it can accept based on space.
	
	Transfer data should use:
		offered_quantity = amount sender is offering
		accepted_quantity = amount receiver agrees to take
	
	Drag/Drop UI data may still use:
		quantity = amount currently being dragged by the UI
	
	External receivers should implement
		get_accepted_transfer_quantity(transfer_data: Diectionary) -> int
			returns how many items this target is willing to accept
		can_accept_transfer(transfer_data: Dictionary) -> bool
			returns true if the finalized accepted_quantity is valid
		accept_transfer(transfer_data: Dictionary) -> bool
			performs the receiving action and returns true if successful
	
	The inventory should not check for specific receiver types such as:
		EquipmentSlot, StorageChest, Hotbar Slot, TrashCan, etc.
	Basically it asks:
		"can you take this/these"
		waits for response of:
			Yes and the number to take
			No transfer rejected
		Inventory decides what to do with the response:
			Reduce the quantity being held / clear the slot if taken
			Keep the amount (or all) if needed or refused with a flyback animation

# ----------------------------------------------------------------
# PUBLIC INVENTORY API
# Safe for outside systems to call
# ----------------------------------------------------------------
	try_transfer_item_to_target(item: InventoryItem, amount: int, target: Object) -> bool
	try_transfer_slot_to_target(slot_index: int, amout: int, target: Object) -> bool
	
	try_add_item(item: InventoryItem, quantity: int) -> bool
	can_add_item(item: InventoryItem, quantity: int) -> bool
	add_item(item, quantity) -> bool
	
	try_remove_item(item: InventoryItem, quantity: int) -> bool
	can_remove_item(item: InventoryItem, quantity: int) -> bool
	remove_item(item: InventoryItem, quantity: int) -> bool
	
	has_item(item: InventoryItem, amount: int =1 ) -> bool
	get_item_count(item: InventoryItem) -> int
	
	can_accept_transfer(transfer_data: Dictionary) -> bool
	get_accepted_transfer_quantity(transfer_data: Dictionary) -> int
	accept_transfer(transfer_data: Dictionary) -> bool
"""



"""
TODO Known issues: 
	right click drag should drop the item when right click is released.


desired controls:
	right click on empty square (while holding item with left click):
		place one of held item
	Done: right click on stack:
		pick up 1/2 the stack
	double left click:
		gather all of one item type until 
		it hit max size or all in the inventory
	shift + left click:
		transfer item to open chest

________________________________
possible additions:
	use of item from inventory
	auto sort
	search and filter bar
	grid rotation for inventory that is tetris style
	mass transfers and speed:
		one button stash dump
		mark as trash/favorites
		multi-select
		direct crafting from storage
	rarity color code (this should be on the icon of the item unless i am reusing the icon)
		grey > white > green > blue > purple > gold
	new item indicator
	stat comparison
________________________________
Style games:
	survival horror > tetris style (resident evil franchise)
	survival, craft and looter games (terraria is the gold standard)
	narrative-drive action and open world RPGs (i'm thinking weight based fallout and elder scroll franchises and maybe WoW)
"""


signal inventory_changed
#signal item_use_requested(slot_index: int, item: InventoryItem, quantity: int)
#signal item_transfer_requested(transfer_data: Dictionary)

@onready var grid: DragDropGrid = $PanelContainer/GridContainer
@onready var slot_count: int = grid.get_slot_count()
var inventory: Array[InventorySlot] = []

@export var failed_drag_return_time: float = 0.3

var active_split_drag: bool = false
var split_drag_from_index: int = -1
var held_split_slot: InventorySlot = null


# TODO for testing only
@export var test_item_1: InventoryItem
@export var test_item_2: InventoryItem
@export var test_item_3: InventoryItem
@export var test_item_4: InventoryItem
@export var test_item_5: InventoryItem



# ----------------------------------------------------------------
# SETUP
# ----------------------------------------------------------------
func _ready() -> void:
	create_empty_inventory()
	grid.dragged.connect(_on_grid_dragged)
	grid.drag_failed.connect(_on_grid_drag_failed)
	grid.split_drag_started.connect(_on_grid_split_drag_started)
	grid.set_source_inventory(self)
	
	# TODO testing only
	add_test_objects() 
	
	refresh_inventory_ui()



# ----------------------------------------------------------------
# GRID SIGNAL HANDLERS
# ----------------------------------------------------------------
func _on_grid_dragged(from: Vector2i, to: Vector2i, split_drag: bool) -> void:
	var from_index := grid_to_index(from)
	var to_index := grid_to_index(to)
	
	if split_drag:
		var success := finish_half_stack_drag(to_index)
		
		if not success:
			var release_position := get_viewport().get_mouse_position()
			animate_failed_drag_return_for_slot(held_split_slot, split_drag_from_index, release_position, true)
			return
	else:
		handle_slot_drop(from_index, to_index)
		
	refresh_inventory_ui()

func _on_grid_split_drag_started(from: Vector2i) -> void:
	var from_index := grid_to_index(from)
	begin_half_stack_drag(from_index)

func _on_grid_drag_failed(from: Vector2i, release_global_position: Vector2, split_drag: bool) -> void:
	if split_drag:
		if not active_split_drag:
			return
		animate_failed_drag_return_for_slot(
			held_split_slot,
			split_drag_from_index,
			release_global_position,
			true
		)
		return
	
	var from_index := grid_to_index(from)
	
	if not is_valid_slot(from_index):
		return
	var from_slot: InventorySlot = inventory[from_index]
	
	if from_slot == null or from_slot.is_empty():
		return
	animate_failed_drag_return(from_index, release_global_position)

func _on_failed_drag_return_finished(ghost: TextureRect, should_restore_split_after_tween: bool) -> void:
	if is_instance_valid(ghost):
		ghost.queue_free()
	if should_restore_split_after_tween:
		return_active_split_drag_to_original()
	else:
		refresh_inventory_ui()


# ----------------------------------------------------------------
# FAILED DRAG AND DROP ANIMATION
# ----------------------------------------------------------------
func animate_failed_drag_return(from_index: int, start_global_position: Vector2) -> void:
	if not is_valid_slot(from_index):
		return
	var from_slot: InventorySlot = inventory[from_index]
	
	if from_slot == null or from_slot.is_empty():
		return
	
	animate_failed_drag_return_for_slot(
		from_slot,
		from_index,
		start_global_position,
		false
	)

# TODO RAW NUMBERS BELOW
func animate_failed_drag_return_for_slot(
	slot_to_animate: InventorySlot,
	return_index: int,
	start_global_position: Vector2, 
	should_restore_split_after_tween: bool = false
	) -> void:
	
	if slot_to_animate == null or slot_to_animate.is_empty():
		return
	if slot_to_animate.item == null:
		return
	if slot_to_animate.item.icon == null:
		return
	if not is_valid_slot(return_index):
		return
	
	var target_global_position := grid.get_cell_global_center(return_index)
	
	
	var ghost := TextureRect.new()
	ghost.texture = slot_to_animate.item.icon
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost.size = Vector2(64, 64)
	ghost.pivot_offset = ghost.size * 0.5
	add_child(ghost)
	
	ghost.global_position = start_global_position - ghost.pivot_offset
	ghost.scale = Vector2.ONE
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		ghost,
		"global_position",
		target_global_position,
		failed_drag_return_time
	)
	tween.tween_property(
		ghost,
		"scale",
		Vector2.ZERO,
		failed_drag_return_time
	)
	tween.finished.connect(_on_failed_drag_return_finished.bind(ghost, should_restore_split_after_tween))


# ----------------------------------------------------------------
# INTERNAL SLOT MOVEMENT
# ----------------------------------------------------------------
func handle_slot_drop(from_index: int, to_index: int) -> void:
	if not is_valid_slot(from_index):
		return
	if not is_valid_slot(to_index):
		return
	if from_index == to_index:
		return
	
	var from_slot: InventorySlot = inventory[from_index]
	var to_slot: InventorySlot = inventory[to_index]
	
	if from_slot == null:
		return
	
	if to_slot == null:
		return
	
	if from_slot.is_empty():
		return
	
	if to_slot.is_empty():
		swap_inventory_slots(from_index, to_index)
		return
	
	if can_merge_slots(from_slot, to_slot):
		merge_slots(from_slot, to_slot)
		return
	
	swap_inventory_slots(from_index, to_index)


func merge_slots(from_slot: InventorySlot, to_slot: InventorySlot) -> void:
	if from_slot == null:
		return
	if to_slot == null:
		return
		
	if from_slot.is_empty():
		return
	if to_slot.is_empty():
		return
	
	if from_slot.item != to_slot.item:
		return
	
	if to_slot.quantity >= to_slot.item.max_stack:
		return
	
	var space_left: int = to_slot.item.max_stack - to_slot.quantity
	var amount_to_move: int = min(from_slot.quantity, space_left)
	
	if amount_to_move <= 0:
		return
	
	to_slot.quantity += amount_to_move
	from_slot.quantity -= amount_to_move
	
	
	if from_slot.quantity <= 0:
		from_slot.clear()
	notify_inventory_changed()

func swap_inventory_slots(from_index, to_index) -> void:
	var temp := inventory[to_index]
	inventory[to_index] = inventory[from_index]
	inventory[from_index] = temp
	notify_inventory_changed()

# ----------------------------------------------------------------
# SPLIT-STACK DRAGGING
# ----------------------------------------------------------------
func move_half_stack_to_empty_slot(from_slot: InventorySlot, to_index: int, amount_to_move: int) -> void:
	from_slot.quantity -= amount_to_move
	
	var new_slot := InventorySlot.new()
	new_slot.set_item(from_slot.item, amount_to_move)
	
	inventory[to_index] = new_slot
	notify_inventory_changed()

func move_half_stack_into_existing_stack(from_slot: InventorySlot, to_slot: InventorySlot, amount_to_move: int) -> void:
	var space_left: int = to_slot.item.max_stack - to_slot.quantity
	var actual_move_to_amount: int = min(amount_to_move, space_left)
	
	if actual_move_to_amount <= 0:
		return
	
	to_slot.quantity += actual_move_to_amount
	from_slot.quantity -= actual_move_to_amount
	notify_inventory_changed()

func begin_half_stack_drag(from_index: int) -> bool:
	if active_split_drag:
		return false
	if not is_valid_slot(from_index):
		return false
	
	var from_slot: InventorySlot = inventory[from_index]
	
	if from_slot == null or from_slot.is_empty():
		return false
	if from_slot.quantity <= 1: 
		return false
	
	var held_amount: int = ceili(from_slot.quantity / 2.0)
	var remaining_amount: int = floori(from_slot.quantity / 2.0)
	
	held_split_slot = InventorySlot.new()
	held_split_slot.set_item(from_slot.item, held_amount)
	
	from_slot.quantity = remaining_amount
	
	if from_slot.quantity <= 0:
		from_slot.clear()
	active_split_drag = true
	split_drag_from_index = from_index
	
	refresh_inventory_ui()
	notify_inventory_changed()
	
	return true

func finish_half_stack_drag(to_index: int) -> bool:
	if not active_split_drag:
		return false
	if held_split_slot == null or held_split_slot.is_empty():
		return false
	if not is_valid_slot(to_index):
		return false
	
	var to_slot: InventorySlot = inventory[to_index]
	
	if to_slot == null or to_slot.is_empty():
		inventory[to_index] = held_split_slot
		clear_active_split_drag()
		notify_inventory_changed()
		return true
	
	if can_merge_item_into_slot(held_split_slot.item, to_slot):
		var space_left: int = to_slot.item.max_stack - to_slot.quantity
		var amount_to_move: int = min(held_split_slot.quantity, space_left)
		
		if amount_to_move <= 0:
			return false
		
		to_slot.quantity += amount_to_move
		held_split_slot.quantity -= amount_to_move
		
		if held_split_slot.quantity <= 0:
			clear_active_split_drag()
			notify_inventory_changed()
			return true
			
		# partial merge and some remains
		# will treat as currently unresolved
		return false
	
	return false

func return_active_split_drag_to_original() -> void:
	if not active_split_drag:
		return
	if held_split_slot == null or held_split_slot.is_empty():
		clear_active_split_drag()
		return
	if not is_valid_slot(split_drag_from_index):
		clear_active_split_drag()
		return
	var original_slot: InventorySlot = inventory[split_drag_from_index]
	
	if original_slot == null or original_slot.is_empty():
		inventory[split_drag_from_index] = held_split_slot
	else: 
		original_slot.quantity += held_split_slot.quantity
	
	clear_active_split_drag()
	notify_inventory_changed()

func clear_active_split_drag():
	active_split_drag = false
	split_drag_from_index = -1
	held_split_slot = null



# ----------------------------------------------------------------
# TRANSFER API WRAPPERS
# ----------------------------------------------------------------
func try_transfer_slot_to_target(source_slot_index: int, amount: int, target: Object) -> bool:
	if not is_valid_slot(source_slot_index):
		return false
	if amount <= 0:
		return false
	if target == null:
		return false
	
	return request_external_transfer(source_slot_index, amount, target)

func try_transfer_item_to_target(item: InventoryItem, amount: int, target: Object) -> bool:
	if item == null:
		return false
	if amount <= 0: 
		return false
	if target == null:
		return false
	if not is_valid_transfer_target(target):
		return false
	if not can_remove_item(item, amount):
		return false
	
	var transfer_data := make_item_transfer_data(item, amount, target)
	if transfer_data.is_empty:
		return false
	
	var accepted_quantity := get_target_accepted_transfer_quantity(target, transfer_data)
	if accepted_quantity <= 0:
		return false
	
	transfer_data["accepted_quantity"] = accepted_quantity
	
	if not target.can_accept_transfer(transfer_data):
		return false
	
	var accepted: bool = target.accept_transfer(transfer_data)
	if not accepted:
		return false
	return try_remove_item(item, accepted_quantity)


# ----------------------------------------------------------------
# TRANSFER SENDING
# Inventory is the sender
# ----------------------------------------------------------------

func request_external_transfer_from_drag_data(drag_data: Dictionary, target: Object) -> bool:
	if drag_data == null:
		return false
	if target == null:
		return false
	if drag_data.get("source_inventory") != self:
		return false
	
	var split_drag: bool = drag_data.get("split_drag", false)
	if split_drag: 
		return request_external_split_transfer(target)
	
	var from_position: Vector2i = drag_data.get("from", Vector2i(-1, -1))
	var source_slot_index := grid_to_index(from_position)
	var quantity: int = drag_data.get("quantity", 0)
	
	return request_external_transfer(source_slot_index, quantity, target)

func request_external_transfer(source_slot_index: int, amount: int, target: Object) -> bool:
	if not is_valid_slot(source_slot_index):
		return false
	if not is_valid_transfer_target(target):
		return false
	if amount <= 0:
		return false
	
	var source_slot: InventorySlot = inventory[source_slot_index]

	if source_slot == null or source_slot.is_empty():
		return false
	if source_slot.quantity <= 0:
		return false
	
	var transfer_data := make_transfer_data(source_slot_index, amount, target, false)
	if transfer_data.is_empty():
		return false
	
	var accepted_quantity := get_target_accepted_transfer_quantity(target, transfer_data)
	if accepted_quantity <= 0:
		return false
	
	transfer_data["accepted_quantity"] = accepted_quantity
		
	if not target.can_accept_transfer(transfer_data):
		return false
	
	var accepted: bool = target.accept_transfer(transfer_data)
	if not accepted:
		return false
	
	var removed := remove_from_slot(source_slot_index, accepted_quantity)
	if not removed:
		return false
	
	return true

func request_external_split_transfer(target: Object) -> bool:
	if not is_valid_transfer_target(target):
		return false
	
	var transfer_data := make_split_transfer_data(target)
	if transfer_data.is_empty():
		return false
	
	var accepted_quantity := get_target_accepted_transfer_quantity(target, transfer_data)
	if accepted_quantity <= 0:
		return false
	
	transfer_data["accepted_quantity"] = accepted_quantity
	
	if not target.can_accept_transfer(transfer_data):
		return false
	
	var accepted: bool = target.accept_transfer(transfer_data)
	if not accepted:
		return false
	
	held_split_slot.quantity -= accepted_quantity
	if held_split_slot.quantity <= 0:
		clear_active_split_drag()
	else:
		return_active_split_drag_to_original()
	
	notify_inventory_changed()
	return true

func reject_external_transfer(source_slot_index: int, release_global_position: Vector2, split_drag: bool = false) -> void:
	if split_drag:
		if not active_split_drag:
			refresh_inventory_ui()
			return
		animate_failed_drag_return_for_slot(
			held_split_slot,
			split_drag_from_index, 
			release_global_position,
			true
		)
		return
	
	if not is_valid_slot(source_slot_index):
		refresh_inventory_ui()
		return
	
	var source_slot: InventorySlot = inventory[source_slot_index]
	
	if source_slot == null or source_slot.is_empty():
		refresh_inventory_ui()
		return
	
	animate_failed_drag_return(
		source_slot_index,
		release_global_position
	)

func is_valid_transfer_target(target: Object) -> bool:
	if target == null:
		return false
	if not target.has_method("can_accept_transfer"):
		return false
	if not target.has_method("accept_transfer"):
		return false
	
	return true

# receiver side: learns how much another system accepts
func get_target_accepted_transfer_quantity(target: Object, transfer_data: Dictionary) -> int:
	if target == null:
		return 0
	
	var offered_quantity := get_transfer_offered_quantity(transfer_data)
	if offered_quantity <= 0:
		return 0
	
	if target.has_method("get_accepted_transfer_quantity"):
		var accepted_quantity: int = target.get_accepted_transfer_quantity(transfer_data)
		return clamp(accepted_quantity, 0, offered_quantity)
	
	return offered_quantity


# ----------------------------------------------------------------
# TRANSFER RECEIVING
# Inventory is the receiver
# ----------------------------------------------------------------
# sender side: tells how much this system accepts
func get_accepted_transfer_quantity(transfer_data: Dictionary) -> int:
	var item: InventoryItem = transfer_data.get("item")
	var offered_quantity := get_transfer_offered_quantity(transfer_data)
	
	if item == null:
		return 0
	if offered_quantity <= 0:
		return 0
	
	var available_space := get_available_quantity_for_item(item)
	return clamp(offered_quantity, 0, available_space)

func get_available_quantity_for_item(item: InventoryItem) -> int:
	if item == null:
		return 0
	
	var available_space := 0
	
	for slot in inventory:
		if slot == null or slot.is_empty():
			available_space += item.max_stack
			continue
		
		if slot.item == item:
			available_space += max(item.max_stack - slot.quantity, 0)
	
	return available_space

func can_accept_transfer(transfer_data: Dictionary) -> bool:
	var item: InventoryItem = transfer_data.get("item")
	var accepted_quantity := get_transfer_quantity_to_accept(transfer_data)
	
	if item == null:
		return false
	if accepted_quantity <= 0:
		return false
	
	return can_add_item(item, accepted_quantity)

func accept_transfer(transfer_data: Dictionary) -> bool:
	var item: InventoryItem = transfer_data.get("item")
	var accepted_quantity := get_transfer_quantity_to_accept(transfer_data)
	
	if item == null:
		return false
	if accepted_quantity <= 0:
		return false
	if not can_accept_transfer(transfer_data): 
		return false
	
	var leftover_quantity: int = try_add_item(item, accepted_quantity)
	return leftover_quantity == 0



# ----------------------------------------------------------------
# TRANSFER UTILITIES
# ----------------------------------------------------------------
func make_transfer_data(source_slot_index: int, amount: int, target: Object, split_drag: bool = false) -> Dictionary:
	if not is_valid_slot(source_slot_index):
		return {}
	
	var source_slot: InventorySlot = inventory[source_slot_index]
	if source_slot == null or source_slot.is_empty():
		return {}
	if amount <= 0:
		return {}
	if source_slot.quantity < amount:
		return {}
	
	return {
		"source_inventory": self,
		"source_slot_index": source_slot_index,
		"item": source_slot.item,
		"offered_quantity": amount,
		"accepted_quantity": 0,
		"target": target,
		"split_drag": split_drag
	}

func make_item_transfer_data(item: InventoryItem, amount: int, target: Object) -> Dictionary:
	if item == null:
		return {}
	if amount <= 0:
		return {}
	if target == null:
		return {}
	if not can_remove_item(item, amount):
		return {}
	
	return {
		"source_inventory": self,
		"source_slot_index": -1,
		"item": item,
		"offered_quantity": amount,
		"accepted_quantity": 0,
		"target": target,
		"split_drag": false
	}

func make_transfer_data_from_drag_data(drag_data: Dictionary, target: Object) -> Dictionary:
	if drag_data == null:
		return {}
	if target == null:
		return {}
	if drag_data.get("source_inventory") != self:
		return {}
	
	var split_drag: bool = drag_data.get("split_drag", false)
	if split_drag:
		return make_split_transfer_data(target)
	
	var from_position: Vector2i = drag_data.get("from", Vector2i(-1, -1))
	var source_slot_index := grid_to_index(from_position)
	var offered_quantity: int = drag_data.get("quantity", 0)
	
	return make_transfer_data(source_slot_index, offered_quantity, target, false)

func get_transfer_offered_quantity(transfer_data: Dictionary) -> int:
	return transfer_data.get("offered_quantity", 0)

func get_transfer_quantity_to_accept(transfer_data: Dictionary) -> int:
	var accepted_quantity: int = transfer_data.get("accepted_quantity", 0)
	if accepted_quantity > 0:
		return accepted_quantity
	return get_transfer_offered_quantity(transfer_data)

func make_split_transfer_data(target: Object) -> Dictionary:
	if not active_split_drag:
		return {}
	if held_split_slot == null or held_split_slot.is_empty():
		return {}
	if target == null:
		return {}
	
	return {
		"source_inventory": self,
		"source_slot_index": split_drag_from_index,
		"item": held_split_slot.item,
		"offered_quantity": held_split_slot.quantity,
		"accepted_quantity": 0,
		"target": target,
		"split_drag": true
	}



# ----------------------------------------------------------------
# ADDING ITEMS
# ----------------------------------------------------------------
func can_add_item(item: InventoryItem, amount: int) -> bool:
	if item == null:
		return false
	if amount <= 0:
		return true
	
	return get_available_quantity_for_item(item) >= amount

func add_item(item: InventoryItem, amount: int) -> bool:
	return try_add_item(item, amount) == 0

# returns how many items were left over
func try_add_item(item: InventoryItem, amount: int) -> int: 
	if item == null:
		return amount
	if amount <= 0:
		return 0
	
	var remaining_quantity := amount
	
	# first i try to add to existing stacks
	for slot in inventory:
		if remaining_quantity <= 0:
			break
		if slot == null or slot.is_empty():
			continue
		if not slot.can_stack_with(item):
			continue
		var available_space: int = item.max_stack - slot.quantity
		
		if available_space <= 0: 
			continue
		
		var amount_to_add: int = min(remaining_quantity, available_space)
		slot.quantity += amount_to_add
		remaining_quantity -= amount_to_add
		
		
	# second i try to add to empty spaces
	for slot in inventory:
		if remaining_quantity <= 0:
			break
		
		if slot == null:
			continue
		if not slot.is_empty():
			continue
		
		var amount_to_add: int = min(remaining_quantity, item.max_stack)
		slot.set_item(item, amount_to_add)
		remaining_quantity -= amount_to_add
		
		
	if remaining_quantity != amount:
		notify_inventory_changed()
	
	return remaining_quantity

# TODO: testing and maintentance
# force an item to a point in the inventory 
func force_set_slot(index: int, item: InventoryItem, amount: int) -> void:
	if not is_valid_slot(index):
		return
	if item == null:
		return
	
	var slot := InventorySlot.new()
	slot.set_item(item, amount)
	
	inventory[index] = slot
	notify_inventory_changed()
	refresh_inventory_ui()



# ----------------------------------------------------------------
# REMOVING ITEMS
# ----------------------------------------------------------------
func can_remove_item(item: InventoryItem, amount: int = 1) -> bool:
	return has_item(item, amount)

func remove_item(item: InventoryItem, amount: int = 1) -> bool:
	if item == null:
		return false
	if amount <= 0:
		return false
	if not has_item(item, amount):
		return false
	
	var amount_left := amount
	
	for slot in inventory:
		if amount_left <= 0:
			break
		if slot == null or slot.is_empty():
			continue
		if slot.item != item:
			continue
		
		var amount_to_remove: int = min(slot.quantity, amount_left)
		slot.quantity -= amount_to_remove
		amount_left -= amount_to_remove
		
		if slot.quantity <= 0:
			slot.clear()
	
	notify_inventory_changed()
	refresh_inventory_ui()
	return true

func try_remove_item(item: InventoryItem, amount: int = 1) -> bool:
	if can_remove_item(item, amount):
		return false
	return remove_item(item, amount)

func remove_from_slot(index: int, amount: int = 1) -> bool:
	if not is_valid_slot(index): 
		return false
	if amount <= 0:
		return false
	var slot: InventorySlot = inventory[index]
	if slot == null or slot.is_empty():
		return false
	if slot.quantity < amount:
		return false
	
	slot.quantity -= amount
	if slot.quantity <= 0:
		slot.clear()
	
	refresh_inventory_ui()
	notify_inventory_changed()
	return true



# ----------------------------------------------------------------
# BACKPACK API
# ----------------------------------------------------------------
func has_item(item: InventoryItem, amount: int = 1) -> bool:
	if item == null:
		return false
	if amount <= 0:
		return true
	return get_item_count(item) >= amount

func is_slot_empty(index: int) -> bool:
	if not is_valid_slot(index):
		return true
	var slot: InventorySlot = inventory[index]
	return slot == null or slot.is_empty()

func get_slot_item(index: int) -> InventoryItem:
	if not is_valid_slot(index):
		return null
	var slot: InventorySlot = inventory[index]
	if slot == null or slot.is_empty():
		return null
	return slot.item

# how many of one item is in the inventory
func get_item_count(item: InventoryItem) -> int:
	if item == null:
		return 0
	var total: int = 0
	
	for slot in inventory: 
		if slot == null or slot.is_empty():
			continue
		if slot.item == item:
			total += slot.quantity
	return total

# how many of one item is in the slot
func get_slot_quantity(index: int) -> int:
	if not is_valid_slot(index):
		return 0
	var slot: InventorySlot = inventory[index]
	if slot == null or slot.is_empty():
		return 0
	return slot.quantity



# ----------------------------------------------------------------
# VALIDATION HELPERS
# ----------------------------------------------------------------
func is_valid_slot(index: int) -> bool:
	return index >= 0 and index < inventory.size()

func can_merge_slots(from_slot: InventorySlot, to_slot: InventorySlot) -> bool:
	if from_slot == null:
		return false
	if to_slot == null:
		return false
		
	if from_slot.is_empty():
		return false
	if to_slot.is_empty():
		return false
	
	if from_slot.item != to_slot.item:
		return false
	
	if to_slot.quantity >= to_slot.item.max_stack:
		return false
	
	return true

func can_merge_item_into_slot(item: InventoryItem, to_slot: InventorySlot) -> bool:
	if item == null: 
		return false
	if to_slot == null:
		return false
	if to_slot.is_empty():
		return false
	if to_slot.item != item:
		return false
	if to_slot.quantity >= to_slot.item.max_stack:
		return false
	return true



# ----------------------------------------------------------------
# UI AND INTERNAL HELPERS
# ----------------------------------------------------------------
func refresh_inventory_ui() -> void:
	for i in inventory.size():
		grid.set_cell_slot(i, inventory[i])

func grid_to_index(this_position: Vector2i) -> int:
	return this_position.y * grid.columns + this_position.x

func create_empty_inventory() -> void:
	inventory.clear()
	
	for i in slot_count:
		var slot := InventorySlot.new()
		inventory.append(slot)

func notify_inventory_changed() -> void:
	refresh_inventory_ui()
	inventory_changed.emit()

func clear_inventory(emit_changed: bool = true) -> void:
	for index in inventory.size():
		var slot := InventorySlot.new()
		inventory[index] = slot
	
	refresh_inventory_ui()
	
	if emit_changed:
		inventory_changed.emit()



# ----------------------------------------------------------------
# PERSISTENCY & SAVE-LOAD SUPPORT
# ----------------------------------------------------------------
func get_save_data() -> Array:
	var save_data: Array = []
	
	for index in inventory.size():
		var slot: InventorySlot = inventory[index]
		
		if slot == null:
			continue
		if slot.is_empty():
			continue
		if slot.item == null:
			continue
		if slot.item.item_id == "":
			push_warning("Inventory save skipped item with empty item_id at slot %s." % index)
			continue
		
		save_data.append({
			"slot_index": index,
			"item_id": slot.item.item_id,
			"quantity": slot.quantity
		})
	
	return save_data

func load_save_data(save_data: Array, item_database: ItemDatabase) -> bool:
	if item_database == null:
		return false
	
	clear_inventory(false)
	
	for entry in save_data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
	
		var slot_index: int = int(entry.get("slot_index", -1))
		var item_id: String = str(entry.get("item_id", ""))
		var quantity: int = int(entry.get("quantity", 0))
		
		if not is_valid_slot(slot_index):
			push_warning("Inventory load skipped invalid slot index: %s." % slot_index)
			continue
		if item_id == "":
			push_warning("Inventory load skipped invalid item ID slot index: %s." % slot_index)
			continue
		if quantity <= 0:
			push_warning("Inventory load skipped invalid quantity slot index: %s." % slot_index)
			continue
		
		var item: InventoryItem = item_database.get_item_by_id(item_id)
		if item == null:
			push_warning("Inventory load skipped unkown item slot index: %s." % item_id)
			continue
		
		var slot := InventorySlot.new()
		slot.item = item
		slot.quantity = clamp(quantity, 1, item.max_stack_size)
		inventory[slot_index] = slot
	
	
	refresh_inventory_ui()
	inventory_changed.emit()
	return true










# TODO testing only
func add_test_objects():
	try_add_item(test_item_1, 3)
	try_add_item(test_item_2, 5)
	try_add_item(test_item_3, 3)
	add_item(test_item_4, 3)
	add_item(test_item_5, 1)
	force_set_slot(15, test_item_1, 8)
	force_set_slot(14, test_item_1, 13)
