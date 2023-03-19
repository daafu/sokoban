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

ButtonState :: struct {
    pressed : bool;
    frame : int;
}

button_was_pressed : [128] ButtonState;
button_pressed: [128] ButtonState;

input_handle_keyboard_event :: (ev: Event) {
    key := ev.key_code;

    // Don't handle key repeats
    if ev.repeat return;

    if key == {
        case .ARROW_LEFT; update_button(.LEFT, xx ev.key_pressed);
        case .ARROW_RIGHT; update_button(.RIGHT, xx ev.key_pressed);
        case .ARROW_UP; update_button(.UP, xx ev.key_pressed);
        case .ARROW_DOWN; update_button(.DOWN, xx ev.key_pressed);

        case #char "A"; update_button(.LEFT, xx ev.key_pressed);
        case #char "D"; update_button(.RIGHT, xx ev.key_pressed);
        case #char "W"; update_button(.UP, xx ev.key_pressed);
        case #char "S"; update_button(.DOWN, xx ev.key_pressed);

        case .ENTER; update_button(.SELECT, xx ev.key_pressed);
        case .SPACEBAR; update_button(.SELECT, xx ev.key_pressed);

        case .BACKSPACE; update_button(.RESET, xx ev.key_pressed);

        case .ESCAPE; {
            update_button(.ESCAPE, xx ev.key_pressed);
            update_button(.CANCEL, xx ev.key_pressed); // reusing ESCAPE
        }
    }
}

input_handle_gamepad :: () {
    dead_zone :: 0.35;
    analog := gamepad_get_analog();

    if abs(analog.x) > abs(analog.y) {
        if analog.x < -dead_zone update_button(.LEFT, true);
        else if analog.x > dead_zone update_button(.RIGHT, true);
    }
    else {
        if analog.y < -dead_zone update_button(.UP, true);
        else if analog.y > dead_zone update_button(.DOWN, true);
    }

    if gamepad_get_button(.DPAD_LEFT) update_button(.LEFT, true);
    if gamepad_get_button(.DPAD_RIGHT) update_button(.RIGHT, true);
    if gamepad_get_button(.DPAD_UP) update_button(.UP, true);
    if gamepad_get_button(.DPAD_DOWN) update_button(.DOWN, true);

    if gamepad_get_button(.SOUTH) update_button(.SELECT, true);
    if gamepad_get_button(.EAST) update_button(.CANCEL, true);
    if gamepad_get_button(.NORTH) update_button(.RESET, true);

    if gamepad_get_button(.TOUCHPAD) update_button(.ESCAPE, true);
    if gamepad_get_button(.OPTIONS) update_button(.ESCAPE, true);
    if gamepad_get_button(.START) update_button(.ESCAPE, true);
    if gamepad_get_button(.BACK) update_button(.ESCAPE, true);
}

input_frame_end :: () {
    memcpy(*button_was_pressed, *button_pressed, button_was_pressed.count);

    // Reset only pressed state, not timestamp
    for i : 0..button_pressed.count - 1 {
        button_pressed[i].pressed = false;
    }
}

input_button_down :: (btn : Button) -> bool {
    return button_pressed[cast (int) btn].pressed;
}

input_button_up :: (btn : Button) -> bool {
    return !button_pressed[cast (int) btn].pressed;
}

input_button_pressed :: (btn : Button) -> bool {
    return button_pressed[cast (int) btn].pressed && !button_was_pressed[cast (int) btn].pressed;
}

input_button_pressed :: (btn : Button, repeat_frames: int) -> bool {
    return input_button_pressed(btn);

    // TODO: Support key repeat sometime, currently this doesnt work because keyboard states are reset each
    // frame and then only updated again when keyboard event comes in, so they never remain pressed in the
    // key_pressed array

    /*
    if button_pressed[cast (int) btn].pressed && !button_was_pressed[cast (int) btn].pressed {
        print("% pressed\n", btn);
        return true;
    }
    else if button_pressed[cast (int) btn].pressed {
        print("% frames since % pressed\n", (frame_count - button_pressed[cast (int) btn].frame), btn);
        if (frame_count - button_pressed[cast (int) btn].frame) % repeat_frames == 0 {
            return true;
        }
    }

    return false;
    */
}

input_button_released :: (btn : Button) -> bool {
    return !button_pressed[cast (int) btn].pressed && button_was_pressed[cast (int) btn].pressed;
}

#scope_file
update_button :: (btn : Button, pressed: bool) {
    button_pressed[cast(int)btn].pressed = pressed;

    if pressed && !button_was_pressed[cast(int)btn].pressed {
        button_pressed[cast(int)btn].frame = frame_count;
    }
    else if !pressed && button_was_pressed[cast(int)btn].pressed {
        button_pressed[cast(int)btn].frame = 0;
    }
}