extends Control


signal beginning_complete()
signal select_skill(caster, skill_id)
signal next_action()
signal end_turn()

const SLOT_POSITION_X = [420, 960, 1500]
const FADE_IN_DURATION = 0.3
const SHAKE_DURATION = 0.25


export(String, FILE) var ally_file_path
export(String, FILE) var enemy_file_path
export(NodePath) var ally_holder_path = "AllyHolder"
export(NodePath) var enemy_holder_path = "EnemyHolder"
export(NodePath) var log_path = "Log"
export(NodePath) var input_area_path = "InputArea"
export(NodePath) var end_turn_button_path = "EndTurnButton"

onready var _ally_holder = get_node(ally_holder_path)
onready var _enemy_holder = get_node(enemy_holder_path)
onready var _log = get_node(log_path)
onready var _input_area = get_node(input_area_path)
onready var _end_turn_button = get_node_or_null(end_turn_button_path)
onready var _tween = get_node_or_null("Tween")

# onready var _turn_order_holder = $TurnOrderList
# onready var _general_action_button_holder = $BottomWindow/GeneralActionButtons
# onready var _target_indicator = $TargetIndicator
# onready var _target_indicator_animator = $TargetIndicator/AnimatedSprite
# onready var _action_buttons = $BottomWindow/CharacterActionButtons.get_children()


# var _current_skill: SkillData
# var _current_target
var _controllers = {}
var _effect_animating = false
var _text_animating = false

var _is_picking_target: bool = false
var _game_state = CombatGameState.Begin

enum CombatGameState { Begin, Combat, Ended }


func _ready():
	_input_area.connect("gui_input", self, "_on_InputArea_gui_input")

	if _tween == null:
		_tween = Tween.new()
		add_child(_tween)
	_tween.connect("tween_completed", self, "_on_tween_completed")

	if _end_turn_button != null:
		_end_turn_button.connect("tween_completed", self, "_on_end_turn_button_click")
		
	# _action_buttons = $BottomWindow/CharacterActionButtons.get_children()


func add_ally(data):
	var ally = load(ally_file_path).instance()
	_ally_holder.add_child(ally)
	_controllers[data.combat_id] = ally
	ally.init_character(data, self)
	data.controller = ally


func add_enemy(data):
	var enemy = load(enemy_file_path).instance()
	_enemy_holder.add_child(enemy)
	_controllers[data.combat_id] = enemy
	enemy.init_character(data, self)


func start_select_target(can_target_ally: bool, can_target_enemy: bool):
	pass


func cast_skill(caster, skill, targets):
	_show_log(skill.cast_log(caster, targets))
	_controllers[caster.combat_id].set_hp(caster.current_hp)
	for target in targets:
		_controllers[target.combat_id].set_hp(target.current_hp)


# func _set_action_buttons(action_names: Array):
#     for i in 4:
#         var action_button = _action_buttons[i]
#         if i < action_names.size() && action_names[i] != null:
#             action_button.visible = true
#             action_button.text = action_names[i]
#         else:
#             action_button.visible = false


# func _set_actions(actions: Array):
#     var action_names = []
#     for action in actions:
#         if action != null:
#             action_names.append(action.skill_name)
#     _set_action_buttons(action_names)


# func _clear_actions():
#     _set_action_buttons([])


# func _show_general_actions(show: bool):
#     _general_action_button_holder.visible = show


# func _show_enemy_target_indicator(enemy):
#     _target_indicator.visible = true
#     _target_indicator.rect_position = Vector2(enemy.rect_position.x, get_viewport().size.y * 0.5)
#     _target_indicator_animator.frame = 0
#     _target_indicator_animator.play()


# func _hide_enemy_target_indicator():
#     _target_indicator.visible = false
#     _target_indicator_animator.stop()


# func _play_skill_animation(target, animation_name):
#     _effect_animating = true
#     var frames = load(ResourcePaths.GFX_ANIMATION_PATH + animation_name + ResourceManager.RESOURCE_FILE_EXTENTION)
#     var gfx_player = OneTimeAnimatedSprite.new()
#     add_child(gfx_player)
#     gfx_player.frames = frames
#     gfx_player.play()
#     gfx_player.position = Vector2(target.rect_position.x, get_viewport().size.y * 0.5)
#     gfx_player.scale = Vector2(1.5, 1.5)
#     gfx_player.connect('animation_finished', self, '_on_effect_animation_finished')



# func _show_skill_log_missed(source, target, skill_data: SkillData):
#     var message = _get_skill_cast_text(source, target, skill_data)
#     message += "\nSkill missed"
#     _show_log(message)


func _show_log(message):
	_log.text = message
	_log.percent_visible = 0.0
	_tween.interpolate_property(_log, 'percent_visible', 0.0, 1.0, message.length() / 100.0)
	_tween.start()
	_text_animating = true
	_input_area.visible = true


func _clear_log():
	_log.text = ''
	_input_area.visible = false


func _fast_forward_skill_log():
	_text_animating = false
	_tween.remove(_log, 'percent_visible')
	_log.percent_visible = 1.0


# func _update_turn_order_list():
#     for i in range(_character_list.size()):
#         var node = _character_list[i].turn_order_node
#         node.move_to(i)


# Signal handler
# func _on_ActionButton_pressed(index: int):
#     # TODO: get action data by index
#     if _is_picking_target:
#         _cancel_targeting()
#     else:
#         _selected_action(_current_character.get_action(index))


func _on_tween_completed(object: Object, key: NodePath):
	if object == _log:
		_text_animating = false


func _on_InputArea_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if _text_animating:
			_fast_forward_skill_log()
		elif !_effect_animating:
			_clear_log()
			emit_signal("next_action")


func _on_cast_skill(caster, skill_id):
	emit_signal("select_skill", caster, skill_id)


func _on_end_turn_button_click():
	emit_signal("end_turn")
