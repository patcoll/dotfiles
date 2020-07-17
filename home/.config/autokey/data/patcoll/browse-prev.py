app = window.get_active_class()

if 'Chromium' in app or 'Firefox' in app:
    keyboard.send_keys('<alt>+<left>')
elif 'Slack' in app:
    keyboard.send_keys('<alt>+<left>')
else:
    keyboard.send_keys('<ctrl>+[')