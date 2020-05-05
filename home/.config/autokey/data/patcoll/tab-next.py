import re

store.set_global_value('hotkey', '<alt>+<ctrl>+]')

if re.match('.*(Chromium|Firefox)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<page_down>')
else:
    engine.set_return_value('<alt>+<ctrl>+]')

engine.run_script('combo')