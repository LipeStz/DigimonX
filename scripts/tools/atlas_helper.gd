@tool
extends Node
## Outil de diagnostic : attacher à un nœud, choisir le TileSet et source_id,
## puis cliquer le bouton pour afficher toutes les coordonnées de l'atlas.

@export var tile_set: TileSet
@export var source_id: int = 0
@export_tool_button("Lister les coordonnées de l'atlas") var list_button: Callable = list_atlas_coordinates

func list_atlas_coordinates() -> void:
	if tile_set == null:
		push_error("Atlas Helper : renseignez d'abord le TileSet.")
		return
	if not tile_set.has_source(source_id):
		push_error("Atlas Helper : source_id %d absent du TileSet." % source_id)
		return
	var source: TileSetSource = tile_set.get_source(source_id)
	if not source is TileSetAtlasSource:
		push_error("Atlas Helper : la source %d n'est pas un TileSetAtlasSource." % source_id)
		return
	var atlas := source as TileSetAtlasSource
	print("--- TileSet atlas : source_id=%d ; %d tuiles ---" % [source_id, atlas.get_tiles_count()])
	for index: int in range(atlas.get_tiles_count()):
		var coords: Vector2i = atlas.get_tile_id(index)
		var size: Vector2i = atlas.get_tile_size_in_atlas(coords)
		print("source_id=%d, atlas_coords=Vector2i(%d, %d), size=Vector2i(%d, %d)" % [source_id, coords.x, coords.y, size.x, size.y])
