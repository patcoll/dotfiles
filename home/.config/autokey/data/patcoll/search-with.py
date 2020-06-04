import re

store.set_global_value('hotkey', '<ctrl>+e')

if re.match('.*(Chromium)', window.get_active_class()):
    engine.set_return_value('<ctrl>+f')
else:
    engine.set_return_value('<ctrl>+e')

engine.run_script('combo')