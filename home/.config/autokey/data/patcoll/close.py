import re

store.set_global_value('hotkey', '<f20>')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+w')
else:
    engine.set_return_value('<ctrl>+w')

engine.run_script('combo')