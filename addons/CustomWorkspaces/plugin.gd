tool
extends EditorPlugin


var plugin_scene : MenuButton = load("res://addons/CustomDFM/MenuButton.tscn").instance()
var dfm_button = get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)\
			.get_child(0).get_child(get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).\
			get_child(0).get_child(0).get_child(0).get_child(0).get_child(0).get_child_count() - 1)


func _enter_tree():
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, plugin_scene)
	var BASE_CONTROL_VBOX = get_editor_interface().get_base_control().get_child(1)
	
	connect("main_screen_changed", plugin_scene, "_on_main_screen_changed")
	dfm_button.connect("pressed", plugin_scene, "_on_DFM_BUTTON_pressed")
	plugin_scene.BASE_CONTROL_VBOX = BASE_CONTROL_VBOX
	plugin_scene.DFM_BUTTON = dfm_button
	plugin_scene.INTERFACE = get_editor_interface()
	get_editor_interface().get_editor_settings().set_setting("interface/editor/separate_distraction_mode", true)
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(0).get_children(): # LEFT left
		if not tabcontainer.is_connected("tab_changed", plugin_scene, "update_dock_visibility"):
			tabcontainer.connect("tab_changed", plugin_scene, "update_dock_visibility")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_children(): # LEFT right
		if not tabcontainer.is_connected("tab_changed", plugin_scene, "update_dock_visibility"):
			tabcontainer.connect("tab_changed", plugin_scene, "update_dock_visibility")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_children(): # RIGHT left
		if not tabcontainer.is_connected("tab_changed", plugin_scene, "update_dock_visibility"):
			tabcontainer.connect("tab_changed", plugin_scene, "update_dock_visibility")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_children(): # RIGHT right
		if not tabcontainer.is_connected("tab_changed", plugin_scene, "update_dock_visibility"):
			tabcontainer.connect("tab_changed", plugin_scene, "update_dock_visibility")


func _ready() -> void:
	var BASE_CONTROL_VBOX = get_editor_interface().get_base_control().get_child(1)
	plugin_scene.docks = {
		EditorPlugin.DOCK_SLOT_LEFT_UL : BASE_CONTROL_VBOX.get_child(1).get_child(0).get_child(0),
		EditorPlugin.DOCK_SLOT_LEFT_BL : BASE_CONTROL_VBOX.get_child(1).get_child(0).get_child(1),
		EditorPlugin.DOCK_SLOT_LEFT_UR : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_child(0),
		EditorPlugin.DOCK_SLOT_LEFT_BR : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_child(1),
		EditorPlugin.DOCK_SLOT_RIGHT_UL : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0),
		EditorPlugin.DOCK_SLOT_RIGHT_BL : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(1),
		EditorPlugin.DOCK_SLOT_RIGHT_UR : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_child(0),
		EditorPlugin.DOCK_SLOT_RIGHT_BR : BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_child(1)
		}
	
	yield(get_tree(), "idle_frame")
	plugin_scene.load_settings()
	yield(get_tree(), "idle_frame")
	
	var editor_layout_popup : PopupMenu = BASE_CONTROL_VBOX.get_child(0).get_child(0).get_child(3).get_child(0).get_child(1)
	plugin_scene.EDITOR_LAYOUT_POPUP = editor_layout_popup
	if plugin_scene.get_popup().is_item_checked(0):
		var config_exists = false
		for idx in editor_layout_popup.get_item_count():
			if editor_layout_popup.get_item_text(idx) == "CustomDFMScenes":
				config_exists = true
				break
		if not config_exists:
			editor_layout_popup.emit_signal("id_pressed", 60) # 60 = "Save Layout"
			for child in get_editor_interface().get_base_control().get_children():
				if child.get_class() == "EditorLayoutsDialog":
					child.emit_signal("name_confirmed", "CustomWorkspaceScenes") # create editor layouts if they don't exist
					child.emit_signal("name_confirmed", "CustomWorkspaceScripts") # create editor layouts if they don't exist
					break


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, plugin_scene)
	plugin_scene.queue_free()
