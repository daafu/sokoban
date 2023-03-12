#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Input";

Button :: enum {
    ESCAPE;

    LEFT;
    RIGHT;
    UP;
    DOWN;

    SELECT;
    CANCEL;

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

        case .ENTER; button_pressed[cast (int) Button.SELECT] = xx ev.key_pressed;
        case .SPACEBAR; button_pressed[cast (int) Button.SELECT] = xx ev.key_pressed;

        case .BACKSPACE; button_pressed[cast (int) Button.RESET] = xx ev.key_pressed;

        case .ESCAPE; {
            button_pressed[cast (int) Button.ESCAPE] = xx ev.key_pressed;
            button_pressed[cast (int) Button.CANCEL] = xx ev.key_pressed; // reusing ESCAPE
        }
    }
/*
                if key == .ARROW_LEFT   key_left  = event.key_pressed;
                if key == .ARROW_RIGHT  key_right = event.key_pressed;
                if key == .ARROW_DOWN   key_down  = event.key_pressed;
                if key == .ARROW_UP     key_up    = event.key_pressed;

                if key == .SHIFT        if event.key_pressed maybe_fire_bullets();
                */

}

input_handle_gamepad :: () {
    dead_zone :: 0.35;
    analog := gamepad_get_analog();

    if abs(analog.x) > abs(analog.y) {
        if analog.x < -dead_zone button_pressed[cast (int) Button.LEFT] = true;
        else if analog.x > dead_zone button_pressed[cast (int) Button.RIGHT] = true;
    }
    else {
        if analog.y < -dead_zone button_pressed[cast (int) Button.UP] = true;
        else if analog.y > dead_zone button_pressed[cast (int) Button.DOWN] = true;
    }

    if gamepad_get_button(.DPAD_LEFT) button_pressed[cast (int) Button.LEFT] = true;
    if gamepad_get_button(.DPAD_RIGHT) button_pressed[cast (int) Button.RIGHT] = true;
    if gamepad_get_button(.DPAD_UP) button_pressed[cast (int) Button.UP] = true;
    if gamepad_get_button(.DPAD_DOWN) button_pressed[cast (int) Button.DOWN] = true;

    if gamepad_get_button(.SOUTH) button_pressed[cast (int) Button.SELECT] = true;
    if gamepad_get_button(.EAST) button_pressed[cast (int) Button.CANCEL] = true;
    if gamepad_get_button(.NORTH) button_pressed[cast (int) Button.RESET] = true;

    if gamepad_get_button(.TOUCHPAD) button_pressed[cast (int) Button.ESCAPE] = true;
    if gamepad_get_button(.OPTIONS) button_pressed[cast (int) Button.ESCAPE] = true;
    if gamepad_get_button(.START) button_pressed[cast (int) Button.ESCAPE] = true;
    if gamepad_get_button(.BACK) button_pressed[cast (int) Button.ESCAPE] = true;

    /*
    if gamepad.left_stick.x < 0.2 {
        //button_pressed[cast (int) Button.LEFT] = true;
    }
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
