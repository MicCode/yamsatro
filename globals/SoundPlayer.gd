extends Node

const SFX_BASE_PATH := "res://assets/sounds/"
const MUSIC_BASE_PATH := "res://assets/musics/"
const MAX_SFX_PLAYERS := 16

var music_player: AudioStreamPlayer
var sfx_players := [] # Liste des AudioStreamPlayer actifs pour les SFX
var sfx_cache := {} # Dictionary<String, AudioStream> cache des sons SFX
var music_cache := {} # Cache pour la musique, si besoin

func _ready():
    music_player = AudioStreamPlayer.new()
    add_child(music_player)
    music_player.name = "MusicPlayer"
    music_player.set_autoplay(false)

func _load_sfx_stream(file_name: String) -> AudioStream:
    if sfx_cache.has(file_name):
        return sfx_cache[file_name]

    var path = SFX_BASE_PATH + file_name
    var stream = load(path)
    if stream is AudioStream:
        sfx_cache[file_name] = stream
        return stream
    push_error("Fichier SFX introuvable : " + path)
    return null

func _load_music_stream(file_name: String) -> AudioStream:
    if music_cache.has(file_name):
        return music_cache[file_name]

    var path = MUSIC_BASE_PATH + file_name
    var stream = load(path)
    if stream is AudioStream:
        music_cache[file_name] = stream
        return stream
    push_error("Fichier musique introuvable : " + path)
    return null

func play_sfx(file_name: String, options: Dictionary = {
    pitch = 1.0,
    pitch_variation = 0.0,
    volume = 0.0,
    start_delay_ms = 0.0,
    start_delay_variation_ms = 0.0
}):
    var pitch: float = options.get("pitch", 1.0)
    var pitch_variation: float = options.get("pitch_variation", 0.0)
    var volume: float = options.get("volume", 0.0)
    var start_delay_ms: float = options.get("start_delay_ms", 0.0)
    var start_delay_variation_ms: float = options.get("start_delay_variation_ms", 0.0)
    
    var stream = _load_sfx_stream(file_name)
    if stream == null:
        return

    if sfx_players.size() >= MAX_SFX_PLAYERS:
        var oldest_player = sfx_players.pop_front()
        if is_instance_valid(oldest_player):
            oldest_player.queue_free()

    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = volume
    player.pitch_scale = randf_range(pitch - pitch_variation, pitch + pitch_variation)
    player.name = "SFX_" + str(Time.get_ticks_msec())
    player.finished.connect(_on_sfx_finished.bind(player))

    add_child(player)
    sfx_players.append(player)
    if start_delay_ms + start_delay_variation_ms > 0:
        await get_tree().create_timer(max(0.01, start_delay_ms + randf_range(0.0, start_delay_variation_ms)) / 1000.0).timeout
    player.play()

func _on_sfx_timer_timeout(timer: Timer, player: AudioStreamPlayer):
    if is_instance_valid(player):
        player.play()
    if is_instance_valid(timer):
        timer.queue_free()

func _on_sfx_finished(player: AudioStreamPlayer):
    if sfx_players.has(player):
        sfx_players.erase(player)
    if is_instance_valid(player):
        player.queue_free()

func play_music(file_name: String, volume: float = 0.0, loop: bool = true):
    var stream = _load_music_stream(file_name)
    if stream == null:
        return

    music_player.stop()
    music_player.stream = stream
    music_player.volume_db = volume
    music_player.loop = loop
    music_player.play()

func stop_music():
    music_player.stop()
