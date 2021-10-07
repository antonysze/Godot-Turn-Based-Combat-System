class_name TBCombatBaseGameMode
extends Reference


var manager


func _init(combat_manager):
    manager = combat_manager


func start_turn():
    pass


func end_turn():
    pass


func check_turn_end(last_action_caster) -> bool:
    return last_action_caster.turn_finished


func enemy_take_action():
    enemy_take_one_random_action()


func enemy_take_one_random_action():
    var enemies = manager.enemy_slots
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var picked_enemy = enemies[rng.randi() % enemies.size()]
    var skills = picked_enemy.skills
    var picked_skill = skills[rng.randi() % skills.size()]
    manager.enemy_action(picked_enemy, picked_skill)


func is_ally_turn() -> bool:
    return true
