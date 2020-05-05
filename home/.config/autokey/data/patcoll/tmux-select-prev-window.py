import re

store.set_global_value('hotkey', '<alt>+c')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+c')
else:
    engine.set_return_value('<ctrl>+c')

engine.run_script('combo')