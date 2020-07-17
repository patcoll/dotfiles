app = window.get_active_class()

if 'Chromium' in app or 'Firefox' in app:
    keyboard.send_keys('<alt>+<right>')
elif 'Slack' in app:
    keyboard.send_keys('<alt>+<right>')
else:
    keyboard.send_keys('<ctrl>+]')