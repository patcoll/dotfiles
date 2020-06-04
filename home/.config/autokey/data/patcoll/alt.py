# turning this on makes kitty sad :(
# note: I should get better at Linux-specific UI controls :(

import re
store.set_global_value('hotkey', '<alt>+<left>')
if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty).*', window.get_active_class()):
    engine.set_return_value('<alt>+b')
#elif re.match('.*(Chromium|Firefox)', window.get_active_class()):
#    engine.set_return_value('<alt>+<left>')
else:
    engine.set_return_value('<ctrl>+<left>')
engine.run_script('combo')