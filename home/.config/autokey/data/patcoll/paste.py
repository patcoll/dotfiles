import re

store.set_global_value('hotkey', '<ctrl>+v')

#engine.set_return_value('<ctrl>+v')
if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty).*', window.get_active_class()):
    engine.set_return_value('<ctrl>+<shift>+v')
else:
    engine.set_return_value('<ctrl>+v')

engine.run_script('combo')
