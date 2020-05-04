import re

store.set_global_value('hotkey', '<alt>+t')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+t')
else:
    engine.set_return_value('<ctrl>+t')

engine.run_script('combo')