import re
store.set_global_value('hotkey', '<alt>+<right>')
if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<alt>+f')
else:
    engine.set_return_value('<ctrl>+<right>')
engine.run_script('combo')