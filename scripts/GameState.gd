extends Node

# Fichier propre à GameState : player.json appartient à Donnees (apparence du joueur)
# et est réécrit en entier par la sauvegarde automatique.
const SAVE_PATH: String = "user://game_state.json"
const STARTING_MONEY: int = 500

var money: int = STARTING_MONEY
var inventory: Dictionary = {}
var opened_chests: Dictionary = {}  # id du coffre -> true


func _ready() -> void:
	load_game()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func reset() -> void:
	money = STARTING_MONEY
	inventory.clear()
	opened_chests.clear()
	_save()


func is_chest_opened(chest_id: String) -> bool:
	return opened_chests.has(chest_id)


## Ouvre un coffre une seule fois : ajoute l'argent et les objets, puis sauvegarde.
func open_chest(chest_id: String, gold: int, items: Dictionary) -> bool:
	if chest_id.is_empty() or opened_chests.has(chest_id):
		return false
	opened_chests[chest_id] = true
	money += maxi(0, gold)
	for item_id: String in items:
		inventory[item_id] = int(inventory.get(item_id, 0)) + int(items[item_id])
	_save()
	return true


func can_afford(price: int) -> bool:
	return price >= 0 and money >= price


func buy_item(item_id: String, price: int) -> bool:
	if item_id.is_empty() or not can_afford(price):
		return false
	money -= price
	inventory[item_id] = int(inventory.get(item_id, 0)) + 1
	_save()
	return true


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		money = maxi(0, int(parsed.get("money", STARTING_MONEY)))
		var saved_inventory: Variant = parsed.get("inventory", {})
		inventory = saved_inventory if saved_inventory is Dictionary else {}
		var saved_chests: Variant = parsed.get("chests", {})
		opened_chests = saved_chests if saved_chests is Dictionary else {}


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Impossible de sauvegarder la partie : " + SAVE_PATH)
		return
	file.store_string(JSON.stringify({"money": money, "inventory": inventory, "chests": opened_chests}, "\t"))
	file.close()
