import re

store.set_global_value('hotkey', '<alt>+s')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+s')
else:
    engine.set_return_value('<ctrl>+s')

engine.run_script('combo')