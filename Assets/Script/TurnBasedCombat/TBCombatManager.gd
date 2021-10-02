class_name TBCombatManager
extends Node


signal combat_start(manager)
signal start_turn(ally_turn)
signal end_turn(ally_turn)
signal cast_skill(caster, skill, target)


export(Resource) var setting
export(bool) var debug_mode := false
export(NodePath) var ui_node_path

onready var ui = get_node(ui_node_path)

# Character data
var character_list: Array
var ally_slots: Array
var enemy_slots: Array


var ally_turn: bool
var current_character = null
var selected_caster = null
var selected_skill = null

var current_action_point = -1


var game_mode_manager
var game_state
enum CombatGameState { Begin, Combat, Won, Lost }


func _ready():
	if ui != null:
		ui.connect("select_skill", self, "_on_select_skill")
		ui.connect("end_turn", self, "end_turn")

	if debug_mode:
		var ally1 = TBCombatCharacterNode.new()
		ally1.name = "ally1"
		ally1.max_hp = 50
		ally1.current_hp = ally1.max_hp

		var skills = []
		ally1.skills = skills
		var skill1 = TBCombatDamageSkill.new()
		skill1.skill_id = 1;
		skill1.damage = 5
		skill1.skill_name = "skill_one"
		skill1.cooldown = 1
		skill1.cast_cost = 2
		skill1.target_type = TBCombatBaseSkill.TargetType.AllEnemy
		skills.append(skill1)
		var skill2 = TBCombatDamageSkill.new()
		skill2.skill_id = 2;
		skill2.damage = 10
		skill2.skill_name = "skill_two"
		skill2.cooldown = 2
		skill2.cast_cost = 4
		skill2.target_type = TBCombatBaseSkill.TargetType.AllEnemy
		skills.append(skill2)

		var ally2 = TBCombatCharacterNode.new()
		ally2.name = "ally2"
		ally2.max_hp = 20
		ally2.current_hp = ally2.max_hp
		ally2.skills = skills

		var enemy1 = TBCombatCharacterNode.new()
		enemy1.name = "enemy1"
		enemy1.max_hp = 40
		enemy1.current_hp = enemy1.max_hp
		enemy1.skills = skills
		skills = []
		enemy1.skills = skills
		var skill3 = TBCombatDamageSkill.new()
		skill3.skill_id = 3;
		skill3.damage = 5
		skill3.skill_name = "skill_one"
		skill3.cooldown = 1
		skill3.cast_cost = 2
		skill3.target_type = TBCombatBaseSkill.TargetType.AllEnemy
		skills.append(skill3)

		init([ally1, ally2], [enemy1], setting)
		
		start_combat()


func init(allies: Array, enemies: Array, setting: TBCombatSetting = null):
	for ally in allies:
		add_ally(ally)
	for enemy in enemies:
		add_enemy(enemy)
	if setting != null:
		self.setting = setting
	match setting.combat_mode:
		TBCombatSetting.CombatMode.TeamSwitch:
			game_mode_manager = TBCombatTSGameMode.new(self)
		TBCombatSetting.CombatMode.TeamPrioritized:
			game_mode_manager = TBCombatTPGameMode.new(self)
		TBCombatSetting.CombatMode.IndividualPrioritized:
			game_mode_manager = TBCombatIPGameMode.new(self)
		_:
			game_mode_manager = TBCombatBaseGameMode.new(self)


func add_ally(ally_data, position: int = -1):
	ally_data.combat_id = "ally_" + String(position)
	ally_data.is_ally = true
	add_character(ally_data, ally_slots, position)
	ui.add_ally(ally_data)


func add_enemy(enemy_data, position: int = -1):
	enemy_data.combat_id = "enemy_" + String(position)
	enemy_data.is_ally = false
	add_character(enemy_data, enemy_slots, position)
	ui.add_enemy(enemy_data)


func add_character(character_node, slots, position: int = -1):
	character_list.append(character_node)
	if position < 0:
		slots.append(character_node)
	else:
		if slots[position] != null:
			printerr('Try to add character to slot %d which is occupied' % position)
			return
		slots[position] = character_node


func start_combat():
	game_state = CombatGameState.Begin
	ally_turn = true
	emit_signal("combat_start", self)
	if ui != null:
		ui.start_combat()
		yield(ui, "beginning_complete")
	start_turn()


func exit_combat():
	character_list = []
	ally_slots = []
	enemy_slots = []
	current_action_point = -1


func check_game_end() -> bool:
	var lose = true
	for ally in ally_slots:
		if !ally.is_dead():
			lose = false
			break
	if lose:
		game_state = CombatGameState.Lose
		return true
	var win = true
	for enemy in enemy_slots:
		if !enemy.is_dead():
			win = false
			break
	if win:
		game_state = CombatGameState.Won
		return true
	return false


func check_turn_end(last_action_caster):
	if setting.auto_end:
		return game_mode_manager.check_turn_end(last_action_caster)
	else:
		return false


func start_turn():
	game_mode_manager.start_turn()
	emit_signal("start_turn", ally_turn)


func end_turn():
	emit_signal("end_turn", ally_turn)
	game_mode_manager.end_turn()


func recover_action_point():
	current_action_point = setting.max_action_point


func character_action(caster, skill, target = null):
	skill.cast(caster, target)
	emit_signal("cast_skill", caster, skill, target)
	if ui != null:
		ui.cast_skill(caster, skill, target)
		yield(ui, "next_action")
	if setting.character_act_once:
		caster.end_turn()
	var is_game_ended = check_game_end()
	if !is_game_ended:
		if check_turn_end(caster):
			end_turn()
	else:
		pass #end game


func general_action(caster, skill):
	pass


func _on_select_skill(caster_id, skill_id):
	var caster = null
	var skill = null
	for character in character_list:
		if character.combat_id == caster_id:
			caster = character
			skill = character.get_skill_by_id(skill_id)
			selected_caster = caster
			selected_skill = skill
			break
	if skill == null:
		printerr("Cannot find skill %s by caster %s" % [skill_id, caster_id])
		return
	if skill.is_no_target_selection():
		var target = _pick_skill_target(caster, skill)
		if target == null:
			general_action(caster, skill)
		else:
			character_action(caster, skill, target)
	else:
		var can_target_ally = skill.target_type == TBCombatBaseSkill.TargetType.SingleAny \
			or (caster.is_ally and skill.target_type == TBCombatBaseSkill.TargetType.SingleAlly) \
			or (!caster.is_ally and skill.target_type == TBCombatBaseSkill.TargetType.SingleEnemy)
			
		var can_target_enemy = skill.target_type == TBCombatBaseSkill.TargetType.SingleAny \
			or (!caster.is_ally and skill.target_type == TBCombatBaseSkill.TargetType.SingleAlly) \
			or (caster.is_ally and skill.target_type == TBCombatBaseSkill.TargetType.SingleEnemy)
		ui.start_select_target(can_target_ally, can_target_enemy)


func _pick_skill_target(caster, skill):
	match skill.target_type:
		TBCombatBaseSkill.TargetType.None:
			return []
		TBCombatBaseSkill.TargetType.Self:
			return [caster]
		TBCombatBaseSkill.TargetType.AllAlly:
			return get_members_from_team(caster.is_ally)
		TBCombatBaseSkill.TargetType.AllEnemy:
			return get_members_from_team(!caster.is_ally)
		TBCombatBaseSkill.TargetType.Everyone:
			return character_list
		_:
			printerr("Not supported target type: %d" % skill.target_type)
			return []


func get_members_from_team(ally: bool) -> Array:
	var members = []
	for slot in _get_team_list(ally):
		if slot != null:
			members.append(slot)
	return members


func _get_team_list(ally: bool):
	return ally_slots if ally else enemy_slots
