import re

store.set_global_value('hotkey', '<ctrl>+<super>+[')

if re.match('.*(Chromium|Firefox|Sublime Text|Sublime Merge)', window.get_active_class()):
#    engine.set_return_value('<shift>+<ctrl>+<tab>')
    engine.set_return_value('<ctrl>+<page_up>')
elif re.match('.*(Slack).*', window.get_active_class()):
    engine.set_return_value('<alt>+<left>')
else:
    engine.set_return_value('<ctrl>+<super>+[')

engine.run_script('combo')