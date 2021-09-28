class_name TBCombatCharacterController
extends Node

export(NodePath) var hp_bar_path

onready var _hp_bar = get_node(hp_bar_path)


func init_character(data, combat_controller):
    if _hp_bar != null:
        init_hp(data)


func init_hp(data):
    _hp_bar.min_value = 0
    _hp_bar.max_value = data.max_hp
    set_hp(data.current_hp)


func set_hp(amount):
    _hp_bar.value = amount


func enable_control(enable: bool):
    pass
