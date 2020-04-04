tool
extends MenuButton


var BASE_CONTROL_VBOX : VBoxContainer
var INTERFACE : EditorInterface
var DFM_BUTTON : ToolButton
var initial_screen_changed_to_script : bool = true


func _ready() -> void:
	get_popup().connect("index_pressed", self, "_on_PopupMenu_index_pressed")
	get_popup().connect("hide", self, "_on_PopupMenu_hide")


func _on_PopupMenu_index_pressed(index : int) -> void:
	get_popup().set_item_checked(index, not get_popup().is_item_checked(index))


func _on_PopupMenu_hide() -> void:
	_save_setting()


func _on_MenuButton_pressed() -> void:
	load_settings()


func _on_DFM_BUTTON_pressed() -> void:
	_show_docks()


func _on_main_screen_changed(new_screen : String) -> void:
	yield(get_tree(), "idle_frame")
	if initial_screen_changed_to_script:
		if get_popup().is_item_checked(1):
			if new_screen == "Script":
				DFM_BUTTON.emit_signal("pressed")
				initial_screen_changed_to_script = false
		else:
			initial_screen_changed_to_script = false
	_show_docks()


func _show_docks(tab : int = -1) -> void: # called via via DFM button pressed and dock tab changed
	if DFM_BUTTON.pressed:
		var vis_tabcontainer : Array
		# show tabs
		for index in get_popup().get_item_count() - 1: # - 1 because bottom panel is last
			var dock = _get_dock(get_popup().get_item_text(index))
			if dock:
				if get_popup().is_item_checked(index):
					dock.get_parent().show()
					dock.get_parent().get_parent().show()
					dock.get_parent().get_parent().get_parent().show()
					if not dock.get_parent() in vis_tabcontainer:
						vis_tabcontainer.push_back(dock.get_parent())
				else:
					dock.get_parent().set_tab_disabled(dock.get_index(), true)
		# change tab to active one
		for tabcontainer in vis_tabcontainer:
			if tabcontainer.get_tab_disabled(tabcontainer.current_tab):
				for idx in tabcontainer.get_tab_count():
					if not tabcontainer.get_tab_disabled(idx):
						tabcontainer.current_tab = idx
						break
		# bottom panel
		if get_popup().is_item_checked(get_popup().get_item_count() - 1):
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(1).show()
	
	else:
		for index in get_popup().get_item_count() - 1: # - 1 because bottom panel is last
			var dock = _get_dock(get_popup().get_item_text(index))
			if dock:
				dock.get_parent().set_tab_disabled(dock.get_index(), false)


func _get_dock(dclass : String) -> Node: # dclass : "FileSystemDock" || "ImportDock" || "NodeDock" || "SceneTreeDock" || "InspectorDock" are defaults
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(0).get_children(): # LEFT left
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return dock
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_children(): # LEFT right
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return dock
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_children(): # RIGHT left
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return dock
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_children(): # RIGHT right
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return dock
	
	return null


func _save_setting() -> void:
	var config = ConfigFile.new()
	for index in get_popup().get_item_count():
		config.set_value(get_popup().get_item_text(index), "checked", get_popup().is_item_checked(index) if get_popup().is_item_checked(index) else "")
	config.save("user://custom_dfm_settings.cfg")


func load_settings() -> void:
	get_popup().clear()
	get_popup().rect_size = Vector2(1, 1)
	get_popup().add_check_item("Use DFM on editor start")
	get_popup().add_check_item("Use DFM in \"Script\" screen on editor start")
	get_popup().add_separator("  Options  ")
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(0).get_children(): # LEFT left
		for dock in tabcontainer.get_children():
			get_popup().add_check_item(dock.get_class() if dock.get_class().findn("Dock") != -1 else dock.name)
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_children(): # LEFT right
		for dock in tabcontainer.get_children():
			get_popup().add_check_item(dock.get_class() if dock.get_class().findn("Dock") != -1 else dock.name)
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_children(): # RIGHT left
		for dock in tabcontainer.get_children():
			get_popup().add_check_item(dock.get_class() if dock.get_class().findn("Dock") != -1 else dock.name)
	
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_children(): # RIGHT right
		for dock in tabcontainer.get_children():
			get_popup().add_check_item(dock.get_class() if dock.get_class().findn("Dock") != -1 else dock.name)
	
	get_popup().add_check_item("Bottom Panel") # Bottom panel needs to be the last one
	
	var config = ConfigFile.new()
	var error = config.load("user://custom_dfm_settings.cfg")
	if error == OK:
		for index in get_popup().get_item_count():
			get_popup().set_item_checked(index, config.get_value(get_popup().get_item_text(index), "checked", false) as bool)
