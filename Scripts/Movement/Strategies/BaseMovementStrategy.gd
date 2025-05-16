# res://Scripts/Movement/Strategies/BaseMovementStrategy.gd
# Pastikan file ini ada di path yang benar.
class_name BaseMovementStrategy
extends RefCounted  # Menggunakan RefCounted karena strategi tidak perlu menjadi Node sendiri di scene tree

# Referensi ke MovementManager agar strategi bisa mengakses properti seperti player_body, grid_size, dll.
var manager: Node


# Konstruktor, dipanggil saat strategi dibuat
func _init(movement_manager: Node):
	self.manager = movement_manager


# Fungsi untuk menangani input pemain.
# Kembalikan true jika strategi ini mengenali dan ingin mencoba menangani input saat ini.
func handle_input() -> bool:
	# Implementasi default, akan di-override oleh turunan.
	return false


# Fungsi untuk memeriksa apakah pergerakan yang di-handle bisa dieksekusi.
# Misalnya, mengecek kolisi menggunakan Raycast.
func can_execute() -> bool:
	# Implementasi default, akan di-override oleh turunan.
	return true


# Fungsi yang dipanggil ketika strategi ini menjadi aktif dan mulai mengeksekusi pergerakan.
func enter():
	# Implementasi default, akan di-override oleh turunan.
	pass


# Fungsi yang dipanggil setiap frame fisika jika strategi ini sedang aktif dan bergerak.
# Bertanggung jawab untuk memindahkan player_body.
func process_movement(delta: float):
	# Implementasi default, akan di-override oleh turunan.
	pass


# Fungsi yang dipanggil ketika strategi ini selesai bergerak atau diinterupsi.
# Berguna untuk melakukan cleanup atau finalisasi.
func exit():
	# Implementasi default, akan di-override oleh turunan.
	pass


# Fungsi untuk mengecek apakah strategi ini sedang dalam proses melakukan pergerakan.
func is_moving() -> bool:
	# Implementasi default, akan di-override oleh turunan.
	return false
