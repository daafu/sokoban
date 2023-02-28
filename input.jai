#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Input";

Button :: enum {
    ESCAPE;

    LEFT;
    RIGHT;
    UP;
    DOWN;

    RESET;
}

button_was_pressed : [128] bool;
button_pressed: [128] bool;

input_handle_keyboard_event :: (ev: Event) {
    key := ev.key_code;

    if key == {
        case .ARROW_LEFT; button_pressed[cast (int) Button.LEFT] = xx ev.key_pressed;
        case .ARROW_RIGHT; button_pressed[cast (int) Button.RIGHT] = xx ev.key_pressed;
        case .ARROW_UP; button_pressed[cast (int) Button.UP] = xx ev.key_pressed;
        case .ARROW_DOWN; button_pressed[cast (int) Button.DOWN] = xx ev.key_pressed;

        case #char "A"; button_pressed[cast (int) Button.LEFT] = xx ev.key_pressed;
        case #char "D"; button_pressed[cast (int) Button.RIGHT] = xx ev.key_pressed;
        case #char "W"; button_pressed[cast (int) Button.UP] = xx ev.key_pressed;
        case #char "S"; button_pressed[cast (int) Button.DOWN] = xx ev.key_pressed;

        case .BACKSPACE; button_pressed[cast (int) Button.RESET] = xx ev.key_pressed;
    }
/*
                if key == .ARROW_LEFT   key_left  = event.key_pressed;
                if key == .ARROW_RIGHT  key_right = event.key_pressed;
                if key == .ARROW_DOWN   key_down  = event.key_pressed;
                if key == .ARROW_UP     key_up    = event.key_pressed;

                if key == .SHIFT        if event.key_pressed maybe_fire_bullets();
                */

}

input_frame_end :: () {
    memcpy(*button_was_pressed, *button_pressed, button_was_pressed.count);
    memset(*button_pressed, 0, button_pressed.count);
}

input_button_down :: (btn : Button) -> bool {
    return button_pressed[cast (int) btn];
}

input_button_up :: (btn : Button) -> bool {
    return !button_pressed[cast (int) btn];
}

input_button_pressed :: (btn : Button) -> bool {
    return button_pressed[cast (int) btn] && !button_was_pressed[cast (int) btn];
}

input_button_released :: (btn : Button) -> bool {
    return !button_pressed[cast (int) btn] && button_was_pressed[cast (int) btn];
}
