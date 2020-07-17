#import re
#store.set_global_value('hotkey', '<alt>+<right>')
#if re.match('.*(Emacs|Guake|Gnome-terminal|Gvim|Eclipse|io.elementary.terminal|kitty).*', window.get_active_class()):
#    engine.set_return_value('<alt>+f')
#elif re.match('.*(Chromium|Firefox)', window.get_active_class()):
#    engine.set_return_value('<alt>+<right>')
#else:
#    engine.set_return_value('<ctrl>+<right>')
#engine.run_script('combo')

keyboard.send_keys('<ctrl>+<right>')