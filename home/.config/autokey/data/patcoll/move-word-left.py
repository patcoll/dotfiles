import re
store.set_global_value('hotkey', '<alt>+<left>')
if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<alt>+b')
else:
    engine.set_return_value('<ctrl>+<left>')
engine.run_script('combo')