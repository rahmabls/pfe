auto_update_enabled = False

def set_auto_update(value: bool):
    global auto_update_enabled
    auto_update_enabled = value

def get_auto_update():
    return auto_update_enabled