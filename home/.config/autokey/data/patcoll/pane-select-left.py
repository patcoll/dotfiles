import re

store.set_global_value('hotkey', '<shift>+<ctrl>+h')

if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<page_down>')
else:
    engine.set_return_value('<shift>+<ctrl>+h')

engine.run_script('combo')