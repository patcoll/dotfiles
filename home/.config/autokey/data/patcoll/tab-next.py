import re

store.set_global_value('hotkey', '<shift>+<ctrl>+]')

if re.match('.*(Chromium|Firefox|Sublime Text|Sublime Merge)', window.get_active_class()):
#    engine.set_return_value('<ctrl>+<tab>')
    engine.set_return_value('<ctrl>+<page_down>')
elif re.match('.*(Slack).*', window.get_active_class()):
    engine.set_return_value('<alt>+<right>')
else:
    engine.set_return_value('<shift>+<ctrl>+]')

engine.run_script('combo')