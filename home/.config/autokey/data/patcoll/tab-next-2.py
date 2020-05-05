import re

store.set_global_value('hotkey', '<alt>+<ctrl>+<right>')

if re.match('.*(Chromium|Firefox)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<page_up>')
else:
    engine.set_return_value('<alt>+<ctrl>+<right>')

engine.run_script('combo')