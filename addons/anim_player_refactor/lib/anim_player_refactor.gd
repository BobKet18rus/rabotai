## Core utility class to handle all refactoring logic

const EditorUtil := preload("res://addons/anim_player_refactor/lib/editor_util.gd")

var _editor_plugin: EditorPlugin
var _undo_redo: EditorUndoRedoManager

func _init(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_undo_redo = editor_plugin.get_undo_redo()

# Nodes
func rename_node_path(anim_player: AnimationPlayer, old: NodePath, new: NodePath):
	if old == new:
		return

	var callback := func(animation: Animation):
		var count := 0
		for i in animation.get_track_count():
			var path := animation.track_get_path(i)
			var node_path := path.get_concatenated_names()

			if node_path == old.get_concatenated_names():
				var new_path := new.get_concatenated_names() + ":" + path.get_concatenated_subnames()
				animation.track_set_path(i, NodePath(new_path))
				count += 1
		return count

	edit_animations(anim_player, callback, "Refactor node tracks")


func remove_node_path(anim_player: AnimationPlayer, node_path: NodePath):

	var callback := func(animation: Animation):
		var count := 0
		for i in range(animation.get_track_count() - 1, -1, -1):
			var path = animation.track_get_path(i)
			if NodePath(path.get_concatenated_names()) == node_path:
				animation.remove_track(i)
				count += 1
		return count

	edit_animations(anim_player, callback, "Remove node tracks")

# Tracks

func rename_track_path(anim_player: AnimationPlayer, old: NodePath, new: NodePath):
	if old == new:
		return

	var callback = func(animation: Animation):
		var count := 0
		for i in animation.get_track_count():
			var path = animation.track_get_path(i)
			if path == old:
				animation.track_set_path(i, new)
				count += 1
		return count

	edit_animations(anim_player, callback, "Refactor track paths")


func remove_track_path(anim_player: AnimationPlayer, property_path: NodePath):
	var callback := func(animation: Animation):
		var count = 0
		for i in range(animation.get_track_count() - 1, -1, -1):
			var path = animation.track_get_path(i)
			if path == property_path:
				animation.remove_track(i)
				count += 1
		return count
	
	edit_animations(anim_player, callback, "Remove tracks")


# Method tracks
func rename_method(anim_player, old: NodePath, new: NodePath):
	if old == new:
		return

	var node_path := NodePath(old.get_concatenated_names())
	var old_method := old.get_concatenated_subnames()
	var new_method := new.get_concatenated_subnames()

	var callback = func(animation: Animation):
		var count := 0
		for i in animation.get_track_count():
			if (
				animation.track_get_type(i) == Animation.TYPE_METHOD
				and animation.track_get_path(i) == node_path
			):
				for j in animation.track_get_key_count(i):
					var name := animation.method_track_get_name(i, j)
					if name == old_method:
						var method := {
							"method": new_method,
							"args": animation.method_track_get_params(i, j)
						}

						animation.track_set_key_value(i, j, method)
						count += 1

		return count

	edit_animations(anim_player, callback, "Rename method keys")


func remove_method(anim_player: AnimationPlayer, method_path: NodePath):
	var callback = func(animation: Animation):
		var count := 0
		for i in animation.get_track_count():
			if (
				animation.track_get_type(i) == Animation.TYPE_METHOD
				and StringName(animation.track_get_path(i)) == method_path.get_concatenated_names()
			):
				for j in range(animation.track_get_key_count(i) - 1, -1, -1):
					var name := animation.method_track_get_name(i, j)
					if name == method_path.get_concatenated_subnames():
						animation.track_remove_key(i, j)
						count += 1
		return count

	edit_animations(anim_player, callback, "Remove method keys")


# Root
func change_root(anim_player: AnimationPlayer, new_path: NodePath):
	var current_root: Node = anim_player.get_node(anim_player.root_node)
	var new_root: Node = anim_player.get_node_or_null(new_path)

	if new_root == null:
		return

	var callback := func(animation: Animation):
		var count := 0
		for i in animation.get_track_count():
			var path := animation.track_get_path(i)
			var node := current_root.get_node_or_null(NodePath(path.get_concatenated_names()))

			if node == null:
				push_warning("Invalid path: %s. Skipping root change." % path)
				continue
			
			var updated_path = str(new_root.get_path_to(node)) + ":" + path.get_concatenated_subnames()
			animation.track_set_path(i, updated_path)
		return count
		
	var change_root_callback := func():
		_undo_redo.add_do_property(anim_player, "root_node", new_path)
		_undo_redo.add_undo_property(anim_player, "root_node", anim_player.root_node)

	edit_animations(anim_player, callback, "Changed animation player root", [change_root_callback])
	


# Helper methods

## Edit animations and store history
## 	callback: (Animation) -> void
func edit_animations(
		anim_player: AnimationPlayer, 
		callback: Callable, 
		commit_msg: String,
		extra_actions: Array[Callable] = []
	) -> void:
	# Get snapshot of previous animations
	var previous_states: Dictionary = anim_player.get("libraries").duplicate(true)
	var new_states := _edit_animations(anim_player, callback)
	
	# Hide bottom panel
	_editor_plugin.hide_bottom_panel()
	# Commit undo history
	_undo_redo.create_action(commit_msg, UndoRedo.MERGE_ALL, anim_player)
	
	_undo_redo.add_do_property(anim_player, "libraries", new_states)
	_undo_redo.add_undo_property(anim_player, "libraries", previous_states)

	for action in extra_actions:
		action.call()

	_undo_redo.commit_action()

	# Show bottom panel
	_editor_plugin.make_bottom_panel_item_visible(
		EditorUtil.find_editor_control_with_class(
			_editor_plugin.get_editor_interface().get_base_control(),
			"AnimationPlayerEditor"
		)
	)


## Edits all animation with callback and returns the updated libraries
func _edit_animations(anim_player: AnimationPlayer, callback: Callable) -> Dictionary:
	var libs := {}
	
	for lib_name in anim_player.get_animation_library_list():
		var lib: AnimationLibrary = anim_player.get_animation_library(lib_name)
		var key := str(lib_name)
		libs[key] = AnimationLibrary.new()
		
		for animation_name in lib.get_animation_list():
			var animation := lib.get_animation(animation_name).duplicate(true)
			callback.call(animation)
			libs[key].add_animation(animation_name, animation)
	return libs
