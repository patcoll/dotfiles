import re

store.set_global_value('hotkey', '<super>+[')

if re.match('.*(Chromium|Firefox)', window.get_active_class()):
    engine.set_return_value('<ctrl>+<page_up>')
elif re.match('.*(Slack).*', window.get_active_class()):
    engine.set_return_value('<alt>+<left>')
else:
    engine.set_return_value('<super>+[')

engine.run_script('combo')