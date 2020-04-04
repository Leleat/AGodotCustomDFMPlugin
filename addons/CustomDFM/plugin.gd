tool
extends EditorPlugin


var custom_dfm_button : MenuButton = load("res://addons/CustomDFM/MenuButton.tscn").instance()


func _enter_tree():
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, custom_dfm_button)
	custom_dfm_button.get_parent().move_child(custom_dfm_button, 4)
	var BASE_CONTROL_VBOX = get_editor_interface().get_base_control().get_child(1)
	var DFM_BUTTON = get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)\
			.get_child(0).get_child(get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).\
			get_child(0).get_child(0).get_child(0).get_child(0).get_child(0).get_child_count() - 1)
	
	connect("main_screen_changed", custom_dfm_button, "_on_main_screen_changed")
	DFM_BUTTON.connect("pressed", custom_dfm_button, "_on_DFM_BUTTON_pressed")
	custom_dfm_button.BASE_CONTROL_VBOX = BASE_CONTROL_VBOX
	custom_dfm_button.DFM_BUTTON = DFM_BUTTON
	custom_dfm_button.INTERFACE = get_editor_interface()
	get_editor_interface().get_editor_settings().set_setting("interface/editor/separate_distraction_mode", true)
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(0).get_children(): # LEFT left
		if not tabcontainer.is_connected("tab_changed", custom_dfm_button, "_show_docks"):
			tabcontainer.connect("tab_changed", custom_dfm_button, "_show_docks")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_children(): # LEFT right
		if not tabcontainer.is_connected("tab_changed", custom_dfm_button, "_show_docks"):
			tabcontainer.connect("tab_changed", custom_dfm_button, "_show_docks")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_children(): # RIGHT left
		if not tabcontainer.is_connected("tab_changed", custom_dfm_button, "_show_docks"):
			tabcontainer.connect("tab_changed", custom_dfm_button, "_show_docks")
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_children(): # RIGHT right
		if not tabcontainer.is_connected("tab_changed", custom_dfm_button, "_show_docks"):
			tabcontainer.connect("tab_changed", custom_dfm_button, "_show_docks")


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	custom_dfm_button.load_settings()
	yield(get_tree(), "idle_frame")
	if custom_dfm_button.get_popup().is_item_checked(0):
		get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)\
				.get_child(0).get_child(get_editor_interface().get_base_control().get_child(1).get_child(1).get_child(1).get_child(1).\
				get_child(0).get_child(0).get_child(0).get_child(0).get_child(0).get_child_count() - 1).emit_signal("pressed")


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, custom_dfm_button)
	custom_dfm_button.queue_free()
