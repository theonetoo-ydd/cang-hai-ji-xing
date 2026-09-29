extends Control

@onready var status_label: Label = $Center/Panel/Margin/VBox/StatusLabel
@onready var start_button: Button = $Center/Panel/Margin/VBox/StartButton

func _ready() -> void:
	print("沧海纪行启动成功。")
	status_label.text = "MVP 0.1 · 项目已成功启动"
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	status_label.text = "航线尚未开放：下一步实现 T03–T07 贸易核心。"
	print("Start pressed: trade loop is the next milestone.")
