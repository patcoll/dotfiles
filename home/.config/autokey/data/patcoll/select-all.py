import re

store.set_global_value('hotkey', '<alt>+a')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+a')
else:
    engine.set_return_value('<ctrl>+a')

engine.run_script('combo')