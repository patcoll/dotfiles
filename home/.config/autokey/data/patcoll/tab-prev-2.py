import re

store.set_global_value('hotkey', '<alt>+<ctrl>+<left>')

if re.match('.*(Chromium|Firefox)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<page_up>')
else:
    engine.set_return_value('<alt>+<ctrl>+<left>')

engine.run_script('combo')