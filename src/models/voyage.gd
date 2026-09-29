extends RefCounted

var origin_id: String
var destination_id: String
var duration: int
var elapsed: int
var status: String

func _init(p_origin_id: String, p_destination_id: String, p_duration: int) -> void:
	origin_id = p_origin_id
	destination_id = p_destination_id
	duration = p_duration
	elapsed = 0
	status = "SAILING"
