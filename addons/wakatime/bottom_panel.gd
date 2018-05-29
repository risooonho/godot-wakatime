tool
extends Control

onready var btn_api_key = $hbox_container/btn_api_key
onready var btn_config_file = $hbox_container/vbox_container_02/btn_config_file
onready var cb_proj_name = $hbox_container/vbox_container_01/cb_hide_project_name
onready var cb_filenames = $hbox_container/vbox_container_01/cb_hide_filenames

onready var btn_incl = $hbox_container/panel_include/hbox_container_01/btn_include
onready var btn_excl = $hbox_container/panel_exclude/hbox_container_01/btn_exclude
onready var popup_incl_excl = $popup_incl_excl
onready var textedit_incl = $hbox_container/panel_include/hbox_container_01/textedit_include
onready var textedit_excl = $hbox_container/panel_exclude/hbox_container_01/textedit_exclude
onready var popup_textedit_incl_excl = $popup_incl_excl/panel/textedit
onready var btn_incl_excl_close = $popup_incl_excl/panel/btn

var api_key_modal = preload('res://addons/wakatime/api_key_modal.tscn')
var curr_settings = null
var opened_popup = null


func init(settings):
	self.curr_settings = settings

	# Set initial values
	cb_proj_name.pressed = curr_settings.get(curr_settings.HIDE_PROJECT_NAME) or false
	cb_filenames.pressed = curr_settings.get(curr_settings.HIDE_FILENAMES) or false

	var incl = curr_settings.get(curr_settings.INCLUDE)
	if typeof(incl) == TYPE_STRING_ARRAY:
		incl = incl.join('\n')
	textedit_incl.text = incl if incl else ''

	var excl = curr_settings.get(curr_settings.EXCLUDE)
	if typeof(excl) == TYPE_STRING_ARRAY:
		excl = excl.join('\n')
	textedit_excl.text = excl if excl else ''

	# Signals
	btn_api_key.connect('pressed', self, '_on_api_key_btn_pressed')
	btn_config_file.connect('pressed', self, '_on_config_file_pressed')

	cb_proj_name.connect('toggled', self, '_on_flag_change', [curr_settings.HIDE_PROJECT_NAME])
	cb_filenames.connect('toggled', self, '_on_flag_change', [curr_settings.HIDE_FILENAMES])

	btn_incl.connect('pressed', self, '_on_incl_excl_btn_pressed', [curr_settings.INCLUDE, textedit_incl])
	btn_excl.connect('pressed', self, '_on_incl_excl_btn_pressed', [curr_settings.EXCLUDE, textedit_excl])

	btn_incl_excl_close.connect('pressed', self, '_on_incl_excl_close_btn_pressed')
	popup_incl_excl.connect('popup_hide', self, '_on_incl_excl_popup_hide')


func _on_api_key_btn_pressed():
	var prompt = api_key_modal.instance()
	prompt.init(curr_settings)
	add_child(prompt)
	prompt.popup_centered()


func _on_config_file_pressed():
	OS.shell_open(ProjectSettings.globalize_path(curr_settings.SETTINGS_FILE))


func _on_flag_change(is_pressed, key):
	curr_settings.save_setting(key, is_pressed)


func _on_incl_excl_btn_pressed(which, textedit):
	opened_popup = which
	popup_textedit_incl_excl.text = textedit.text
	popup_incl_excl.popup_centered_ratio(0.45)


func _on_incl_excl_close_btn_pressed():
	popup_incl_excl.visible = false


func _on_incl_excl_popup_hide():
	var value = ''
	if opened_popup == curr_settings.INCLUDE:
		value = popup_textedit_incl_excl.text
		textedit_incl.text = value
	if opened_popup == curr_settings.EXCLUDE:
		value = popup_textedit_incl_excl.text
		textedit_excl.text = value
	curr_settings.save_setting(opened_popup, value, true)