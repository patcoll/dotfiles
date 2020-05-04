import re

store.set_global_value('hotkey', '<alt>+f')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+f')
else:
    engine.set_return_value('<ctrl>+f')

engine.run_script('combo')