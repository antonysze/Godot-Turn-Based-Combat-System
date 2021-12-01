class_name TBCombatIPGameMode
extends TBCombatBaseGameMode


var priority_key = "priority"
var speed_key = "speed"

var current_character = null


func _init(combat_manager).(combat_manager):
    for character in manager.character_list:
        init_priority(character)


func start_turn():
    var character_list = manager.character_list
    character_list.sort_custom(self, "sort_character_priority")
    current_character = character_list.pop_front()
    var min_priority = current_character.meta_data[priority_key]
    for character in manager.character_list:
        character.meta_data[priority_key] -= min_priority
    current_character.meta_data[priority_key] = 0

    current_character.start_turn()

    if is_ally_turn():
        restore_action_point()
    else:
        enemy_take_action()


func end_turn():
    current_character.end_turn()


func init_priority(character_node):
    character_node.meta_data[priority_key] = -character_node.stats[speed_key]


func sort_character_priority(a, b):
    if a.meta_data[priority_key] < b[0].meta_data[priority_key]:
        return true
    return false


func is_ally_turn() -> bool:
    return current_character.is_ally


func restore_action_point():
    # individual ap
    var max_ap = manager.setting.max_action_point
    manager.set_action_point(max_ap, max_ap)
