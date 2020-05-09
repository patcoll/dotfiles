import re

store.set_global_value('hotkey', '<shift>+<ctrl>+<alt>+c')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty).*', window.get_active_class()):
    engine.set_return_value('<shift>+<ctrl>+c')
else:
    engine.set_return_value('<ctrl>+c')

engine.run_script('combo')