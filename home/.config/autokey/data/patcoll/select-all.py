import re

store.set_global_value('hotkey', '<ctrl>+a')

if re.match('.*(nvPY)', window.get_active_class()):
    engine.set_return_value('<ctrl>+?')
else:
    engine.set_return_value('<ctrl>+a')

engine.run_script('combo')