extends Node

const CHEMIN_DIGIMON := "res://data/digimon_dmx.json"
const DOSSIER_ICONES := "res://sprites/DigimonXicon/"
const DOSSIER_ART := "res://sprites/DigimonXart/"
const PLAYER_SAVE := "user://player.json"
const PROFILES_FILE: String = "user://profiles.json"

var joueur_data := {}
var digimon_liste: Array = []
var digimon_par_id: Dictionary = {}

func _ready() -> void:
	_charger_digimon()

func _charger_digimon() -> void:
	var fichier := FileAccess.open(CHEMIN_DIGIMON, FileAccess.READ)
	if fichier == null:
		push_error("Impossible d'ouvrir " + CHEMIN_DIGIMON)
		return
	var contenu = JSON.parse_string(fichier.get_as_text())
	if contenu == null or not (contenu is Array):
		push_error("JSON invalide : " + CHEMIN_DIGIMON)
		return
	digimon_liste = contenu
	for d in digimon_liste:
		if d["id"] != "":
			digimon_par_id[d["id"]] = d
	print("Digimon charges : ", digimon_liste.size())

func get_digimon(id: String) -> Dictionary:
	return digimon_par_id.get(id, {})

func get_icone(id: String) -> Texture2D:
	return _charger_sprite(DOSSIER_ICONES, id)

func get_art(id: String) -> Texture2D:
	return _charger_sprite(DOSSIER_ART, id)

func _charger_sprite(dossier: String, id: String) -> Texture2D:
	var d := get_digimon(id)
	if d.is_empty() or d.get("image") == null:
		return null
	var chemin: String = dossier + str(d["image"]) + ".png"
	if ResourceLoader.exists(chemin):
		return load(chemin)
	return null

func sauvegarder_joueur(data: Dictionary) -> void:
	joueur_data = data
	var file: FileAccess = FileAccess.open(PLAYER_SAVE, FileAccess.WRITE)
	if file == null:
		push_error("Impossible d’écrire la sauvegarde joueur : %s" % PLAYER_SAVE)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func charger_joueur() -> bool:
	if not FileAccess.file_exists(PLAYER_SAVE):
		return false
	var file: FileAccess = FileAccess.open(PLAYER_SAVE, FileAccess.READ)
	if file == null:
		push_error("Impossible de lire la sauvegarde joueur : %s" % PLAYER_SAVE)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		joueur_data = parsed
		return true
	return false


## Profils de personnages (nom, apparence et date), indépendants de la sauvegarde active.
func charger_profils() -> Array[Dictionary]:
	var profiles: Array[Dictionary] = []
	if not FileAccess.file_exists(PROFILES_FILE):
		return profiles
	var file: FileAccess = FileAccess.open(PROFILES_FILE, FileAccess.READ)
	if file == null:
		push_error("Impossible de lire les profils : %s" % PROFILES_FILE)
		return profiles
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Array):
		push_error("Le fichier de profils ne contient pas un tableau JSON valide.")
		return profiles
	for entry: Variant in parsed:
		if entry is Dictionary:
			profiles.append(entry.duplicate(true))
	return profiles


func sauvegarder_profil(data: Dictionary) -> bool:
	var profile: Dictionary = data.duplicate(true)
	var profile_name: String = str(profile.get("name", "")).strip_edges()
	if profile_name.is_empty():
		return false
	profile["name"] = profile_name
	var now: String = Time.get_datetime_string_from_system()
	var profiles: Array[Dictionary] = charger_profils()
	var existing_created_at: String = ""
	for existing: Dictionary in profiles:
		if str(existing.get("name", "")).to_lower() == profile_name.to_lower():
			existing_created_at = str(existing.get("created_at", ""))
			break
	if not profile.has("created_at"):
		profile["created_at"] = existing_created_at if not existing_created_at.is_empty() else now
	profile["saved_at"] = now
	profile["updated_at"] = now
	var replaced: bool = false
	for index: int in range(profiles.size()):
		if str(profiles[index].get("name", "")).to_lower() == profile_name.to_lower():
			profiles[index] = profile
			replaced = true
			break
	if not replaced:
		profiles.append(profile)
	var file: FileAccess = FileAccess.open(PROFILES_FILE, FileAccess.WRITE)
	if file == null:
		push_error("Impossible d’écrire les profils : %s" % PROFILES_FILE)
		return false
	file.store_string(JSON.stringify(profiles, "\t"))
	file.close()
	return true


## Profils triés par dernière sauvegarde, ancien format created_at compris.
func profils_tries() -> Array[Dictionary]:
	var profiles: Array[Dictionary] = charger_profils()
	profiles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _profil_timestamp(a) > _profil_timestamp(b)
	)
	return profiles


func _profil_timestamp(profile: Dictionary) -> int:
	var stamp: String = _date_profil_source(profile)
	if stamp.is_empty():
		return 0
	var parts: Dictionary = Time.get_datetime_dict_from_datetime_string(stamp, false)
	if parts.is_empty():
		return 0
	return int(Time.get_unix_time_from_datetime_dict(parts))


func formater_date_profil(profile: Dictionary) -> String:
	var stamp: String = _date_profil_source(profile)
	if stamp.is_empty():
		return "Date inconnue"
	var parts: Dictionary = Time.get_datetime_dict_from_datetime_string(stamp, false)
	if parts.is_empty():
		return stamp
	return "%02d/%02d/%04d %02d:%02d" % [
		int(parts.get("day", 0)),
		int(parts.get("month", 0)),
		int(parts.get("year", 0)),
		int(parts.get("hour", 0)),
		int(parts.get("minute", 0)),
	]


func _date_profil_source(profile: Dictionary) -> String:
	var stamp: String = str(profile.get("saved_at", ""))
	if stamp.is_empty():
		stamp = str(profile.get("updated_at", ""))
	if stamp.is_empty():
		stamp = str(profile.get("created_at", ""))
	return stamp


func activer_profil(profile: Dictionary) -> void:
	joueur_data = profile.duplicate(true)
	sauvegarder_joueur(joueur_data)
