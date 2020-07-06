import re

store.set_global_value('hotkey', '<ctrl>+[')

if re.match('.*(Chromium|Firefox)', window.get_active_class()):
    engine.set_return_value('<alt>+<left>')
elif re.match('.*(Slack).*', window.get_active_class()):
    engine.set_return_value('<alt>+<left>')
else:
    engine.set_return_value('<ctrl>+[')

engine.run_script('combo')