"""
The first 3 items in the list are non-dock items (here docks are = all editor docks + bottom panel). Then come the docks for the 2D/3D viewport followed by a separator (non-dock item).
After that, all docks will be listed again for the Script viewport. That means in total there are 4 non-dock items. So the PopupMenu's structure looks like size (top to bottom): 
(3 x non-dock items) + (dock_count x dock items) + (non-dock separator) + (dock_count x dock items)
"""

tool
extends MenuButton


var BASE_CONTROL_VBOX : VBoxContainer
var INTERFACE : EditorInterface
var DFM_BUTTON : ToolButton
var settings_updated : bool = false
var dock_count : int = 0 # includes bottom panel
var current_main_screen : String
var rhsplit_visible : bool
var leftleft_visible : bool
var leftright_visible : bool
var first_change_to_script_view : bool = true
var dfm_enabled_on_scene : bool = false
var dfm_enabled_on_script : bool = false


func _ready() -> void:
	get_popup().connect("index_pressed", self, "_on_PopupMenu_index_pressed")
	get_popup().connect("hide", self, "_on_PopupMenu_hide")
	get_popup().hide_on_checkable_item_selection = false
	icon = get_icon("Collapse", "EditorIcons")


func _on_PopupMenu_index_pressed(index : int) -> void:
	get_popup().toggle_item_checked(index)
	settings_updated = true


func _on_PopupMenu_hide() -> void:
	if settings_updated:
		save_settings()
		DFM_BUTTON.emit_signal("pressed")
		yield(get_tree(), "idle_frame")
		DFM_BUTTON.emit_signal("pressed")
		settings_updated = false


func _on_MenuButton_pressed() -> void:
	load_settings()


func _on_DFM_BUTTON_pressed() -> void:
	match current_main_screen: # for node selection/script opening via SceneTreeDock
		"2D", "3D": 
			if DFM_BUTTON.pressed:
				dfm_enabled_on_scene = true
			else:
				dfm_enabled_on_scene = false
		"Script":
			if DFM_BUTTON.pressed:
				dfm_enabled_on_script = true
			else:
				dfm_enabled_on_script = false
	
	update_dock_visibility()


func _on_main_screen_changed(new_screen : String) -> void:
	current_main_screen = new_screen
	if first_change_to_script_view and get_popup().get_item_count() > 2: # to autoswitch to DFM when switching to "Script" view the first time, if it is enabled
		if get_popup().is_item_checked(1):
			if new_screen == "Script":
				DFM_BUTTON.emit_signal("pressed")
				first_change_to_script_view = false
		else:
			first_change_to_script_view = false
	
	if not dfm_enabled_on_scene and DFM_BUTTON.pressed and current_main_screen in ["2D", "3D"]: # for node selection via SceneTreeDock
		DFM_BUTTON.pressed = false
	if dfm_enabled_on_script and not DFM_BUTTON.pressed and current_main_screen == "Script": # for script opening via SceneTreeDock
		DFM_BUTTON.pressed = true
	
	yield(get_tree(), "idle_frame")
	update_dock_visibility()


func update_dock_visibility(tab : int = -1) -> void: # called via signals on DFM button press or tab change of dock
	for index in dock_count - 1:
		var dock = get_dock(get_popup().get_item_text(index + 3))
		dock[0].get_parent().set_tab_disabled(dock[0].get_index(), false)
	
	if DFM_BUTTON.pressed:
		var visible_tabcontainer : Array
		rhsplit_visible = false
		leftleft_visible = false
		leftright_visible = false
		
		# show tabs
		for index in dock_count - 1: 
			var idx = 3 + index  if current_main_screen in ["2D", "3D"] else 3 + index + dock_count + 1
			var dock = get_dock(get_popup().get_item_text(idx))
			if get_popup().is_item_checked(idx):
				
				if dock[1].begins_with("Right"):
					rhsplit_visible = true
				elif dock[1] == "Left left":
					leftleft_visible = true
				elif dock[1] == "Left right":
					leftright_visible = true
				
				dock[0].get_parent().show()
				dock[0].get_parent().get_parent().show()
				if not dock[0].get_parent() in visible_tabcontainer:
					visible_tabcontainer.push_back(dock[0].get_parent())
			else:
				dock[0].get_parent().set_tab_disabled(dock[0].get_index(), true)
		
		if rhsplit_visible:
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).show()
		else:
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).hide()
		if leftleft_visible:
			BASE_CONTROL_VBOX.get_child(1).get_child(0).show()
		else:
			BASE_CONTROL_VBOX.get_child(1).get_child(0).hide()
		if leftright_visible:
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).show()
		else:
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).hide()
		
		# change tab to active one
		for tabcontainer in visible_tabcontainer:
			if tabcontainer.get_tab_disabled(tabcontainer.current_tab):
				for idx in tabcontainer.get_tab_count():
					if not tabcontainer.get_tab_disabled(idx):
						tabcontainer.current_tab = idx
						break
		
		# bottom panel
		var idx = get_popup().get_item_count() - 1 if current_main_screen == "Script" else 3 + dock_count - 1
		if get_popup().is_item_checked(idx):
			BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(1).show()

	else:
		# for node selection via SceneTreeDock
		for index in dock_count - 1: 
			var dock = get_dock(get_popup().get_item_text(index + 3))
			dock[0].get_parent().show()
			dock[0].get_parent().get_parent().show()
			dock[0].get_parent().get_parent().get_parent().show() 


func get_dock(dclass : String): # dclass : "FileSystemDock" || "ImportDock" || "NodeDock" || "SceneTreeDock" || "InspectorDock" are defaults
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(0).get_children(): # LEFT left
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return [dock, "Left left"]
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(0).get_children(): # LEFT right
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return [dock, "Left right"]
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(0).get_children(): # RIGHT left
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return [dock, "Right left"]
	for tabcontainer in BASE_CONTROL_VBOX.get_child(1).get_child(1).get_child(1).get_child(1).get_child(1).get_children(): # RIGHT right
		for dock in tabcontainer.get_children():
			if dock.get_class() == dclass or dock.name == dclass:
				return [dock, "Right right"]
	return null


func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("Usage", get_popup().get_item_text(0).replace(" ", "_"), "true" if get_popup().is_item_checked(0) else "")
	config.set_value("Usage", get_popup().get_item_text(1).replace(" ", "_"), "true" if get_popup().is_item_checked(1) else "")
	for index in dock_count: 
		# scene editor
		config.set_value("Scene_Editor", get_popup().get_item_text(3 + index).replace(" ", "_"), "true" if get_popup().is_item_checked(3 + index) else "")
		# script editor
		config.set_value("Script_Editor", get_popup().get_item_text(3 + index + dock_count + 1).replace(" ", "_"), "true" if get_popup().is_item_checked(3 + index + dock_count + 1) else "")
	config.save("user://custom_dfm_settings.cfg")


func load_settings() -> void:
	get_popup().clear()
	get_popup().rect_size = Vector2(1, 1)
	get_popup().add_check_item("Use DFM in scene viewport on editor start")
	get_popup().add_check_item("Use DFM in script viewport on editor start")
	get_popup().add_separator("  2D/3D Settings  ")
	
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
	get_popup().add_check_item("Bottom Panel") 
	
	get_popup().add_separator("  Script Settings  ")
	for index in get_popup().get_item_count() - 4: 
		get_popup().add_check_item(get_popup().get_item_text(index + 3))
	
	dock_count = (get_popup().get_item_count() - 4) / 2
	
	var config = ConfigFile.new()
	var error = config.load("user://custom_dfm_settings.cfg")
	if error == OK:
		get_popup().set_item_checked(0, config.get_value("Usage", get_popup().get_item_text(0).replace(" ", "_"), false) as bool)
		get_popup().set_item_checked(1, config.get_value("Usage", get_popup().get_item_text(1).replace(" ", "_"), false) as bool)
		for index in dock_count:
			get_popup().set_item_checked(3 + index, config.get_value("Scene_Editor", get_popup().get_item_text(index + 3).replace(" ", "_"), false) as bool)
			get_popup().set_item_checked(3 + index + dock_count + 1, config.get_value("Script_Editor", get_popup().get_item_text(index + 3).replace(" ", "_"), false) as bool)
