@tool
extends EditorScript

## Ajoute des collisions à la scène actuellement éditée sans modifier les TileMapLayers.
## Lancer via Fichier > Exécuter, puis enregistrer la scène (Ctrl+S).

const COLLISION_ROOT_NAME: StringName = &"SolidCollisions"
const TILE_LAYER_NAMES: Array[StringName] = [&"trees", &"House", &"Decor", &"Objects"]
const WATER_LAYER_NAME: StringName = &"water"

func _run() -> void:
	var root := get_scene() as Node2D
	if root == null:
		push_error("Aucune scène éditée. Ouvrez FileCity_TownSquare.tscn avant l'exécution.")
		return

	var tile_size := Vector2(16.0, 16.0)
	var reference_layer := root.get_node_or_null("Ground") as TileMapLayer
	if reference_layer == null:
		reference_layer = root.get_node_or_null("water") as TileMapLayer
	if reference_layer != null and reference_layer.tile_set != null:
		tile_size = Vector2(reference_layer.tile_set.tile_size)

	# Seul le conteneur généré par ce script est remplacé.
	var old_container := root.get_node_or_null(NodePath(String(COLLISION_ROOT_NAME)))
	if old_container != null:
		root.remove_child(old_container)
		old_container.free()

	var container := Node2D.new()
	container.name = COLLISION_ROOT_NAME
	root.add_child(container)
	container.owner = root

	var object_shapes := 0
	var water_shapes := 0
	for layer_name: StringName in TILE_LAYER_NAMES:
		var layer := root.get_node_or_null(NodePath(String(layer_name))) as TileMapLayer
		if layer == null:
			push_warning("TileMapLayer absent, ignoré: %s" % String(layer_name))
			continue
		if layer.tile_set == null:
			push_warning("TileMapLayer sans TileSet, ignoré: %s" % String(layer_name))
			continue
		for cell: Vector2i in layer.get_used_cells():
			var source_id := layer.get_cell_source_id(cell)
			var atlas_coords := layer.get_cell_atlas_coords(cell)
			var footprint := _atlas_footprint(layer, source_id, atlas_coords)
			var base_rows := _base_rows(layer, source_id, atlas_coords)
			_add_rect_collision(root, container, layer, cell, footprint, base_rows, tile_size, "Solid_%s_%d_%d" % [String(layer_name), cell.x, cell.y])
			object_shapes += 1

	var water_layer := root.get_node_or_null(NodePath(String(WATER_LAYER_NAME))) as TileMapLayer
	if water_layer != null:
		for cell: Vector2i in water_layer.get_used_cells():
			_add_rect_collision(root, container, water_layer, cell, Vector2i.ONE, 1, tile_size, "Water_%d_%d" % [cell.x, cell.y])
			water_shapes += 1
	else:
		push_warning("TileMapLayer water absent; aucune collision d'eau ajoutée.")

	print("SolidCollisions: %d collisions d'objets (%d trees/House/Decor/Objects) et %d collisions d'eau; total %d." % [object_shapes, object_shapes, water_shapes, object_shapes + water_shapes])


func _atlas_footprint(layer: TileMapLayer, source_id: int, atlas_coords: Vector2i) -> Vector2i:
	if layer.tile_set != null and layer.tile_set.has_source(source_id):
		var source := layer.tile_set.get_source(source_id) as TileSetAtlasSource
		if source != null and source.has_tile(atlas_coords):
			var size := source.get_tile_size_in_atlas(atlas_coords)
			if size.x > 0 and size.y > 0:
				return size
	return Vector2i.ONE


func _base_rows(layer: TileMapLayer, source_id: int, atlas_coords: Vector2i) -> int:
	# Même logique de l'ancien générateur: maisons sur leurs deux rangs du bas;
	# arbres et objets de décor sur le rang inférieur.
	if layer.name == &"House" and source_id == 0:
		var size := _atlas_footprint(layer, source_id, atlas_coords)
		if size.y >= 5:
			return mini(2, size.y)
	return 1


func _add_rect_collision(root: Node, container: Node2D, layer: TileMapLayer, cell: Vector2i, footprint: Vector2i, base_rows: int, tile_size: Vector2, node_name: String) -> void:
	var safe_footprint := Vector2i(maxi(1, footprint.x), maxi(1, footprint.y))
	var rows := clampi(base_rows, 1, safe_footprint.y)
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 1

	# La cellule de TileMapLayer est le centre du coin supérieur gauche de l'empreinte.
	# Transformer le point vers les coordonnées de la racine respecte les transforms
	# (translation/rotation/échelle) de la couche, sans toucher à son contenu.
	var cell_center: Vector2 = layer.map_to_local(cell)
	var offset_in_layer := Vector2((safe_footprint.x - 1) * tile_size.x * 0.5, (safe_footprint.y - rows) * tile_size.y * 0.5)
	var center_in_root: Vector2 = root.to_local(layer.to_global(cell_center + offset_in_layer))
	body.position = center_in_root

	var shape_node := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(safe_footprint.x * tile_size.x, rows * tile_size.y)
	shape_node.shape = rectangle
	body.add_child(shape_node)
	container.add_child(body)
	# L'owner sur les deux nœuds est nécessaire pour que le conteneur soit sérialisé.
	body.owner = root
	shape_node.owner = root
