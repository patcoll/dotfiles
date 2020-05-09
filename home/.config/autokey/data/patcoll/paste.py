import re

store.set_global_value('hotkey', '<shift>+<ctrl>+<alt>+v')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty).*', window.get_active_class()):
    engine.set_return_value('<shift>+<ctrl>+v')
else:
    engine.set_return_value('<ctrl>+v')

engine.run_script('combo')
