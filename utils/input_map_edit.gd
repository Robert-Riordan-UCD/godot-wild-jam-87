extends Node
class_name InputMapEdit

# Returns a dictionary of actions mapped to arrays of removed events
static func remove_input_actions() -> Dictionary[StringName, Array]:
	var removed_actions: Dictionary[StringName, Array]
	for action in InputMap.get_actions():
		if action.begins_with("ui_"): continue
		for event in InputMap.action_get_events(action):
			removed_actions[action] = removed_actions.get(action, Array()) + [event]
			InputMap.action_erase_event(action, event)
	return removed_actions


static func restore_input_actions(actions: Dictionary[StringName, Array]) -> void:
	for action in actions:
		restore_input_action(action, actions[action])


static func remove_input_action(action: StringName) -> void:
	for event in InputMap.action_get_events(action):
		InputMap.action_erase_event(action, event)


static func restore_input_action(action: StringName, events: Array) -> void:
	for event in events:
		InputMap.action_add_event(action, event)
