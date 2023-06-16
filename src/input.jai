#import "Basic"; //()(MEMORY_DEBUGGER=true);

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

input_check_gamepad :: () {
    if !input_gamepad_assigned(0) {
        // Assign new gamepad
        gamepads : [8]InputGamepadInfo;
        num_gamepads := input_get_gamepads(gamepads.data, 8);

        if num_gamepads > 0 {
            input_gamepad_assign(gamepads[0].gamepad_index, 0);
        }
    }
}

input_button_down :: (btn : Button) -> bool {
    if btn == {
        case .ESCAPE;
            return input_scancode_down(.escape) || input_gamepad_button_down(0, .touchpad) || input_gamepad_button_down(0, .back) || input_gamepad_button_down(0, .guide) || input_gamepad_button_down(0, .start);
        case .LEFT;
            return input_scancode_down(.a) || input_scancode_down(.left) || input_gamepad_button_down(0, .dpad_left);
        case .RIGHT;
            return input_scancode_down(.d) || input_scancode_down(.right) || input_gamepad_button_down(0, .dpad_right);
        case .UP;
            return input_scancode_down(.w) || input_scancode_down(.up) || input_gamepad_button_down(0, .dpad_up);
        case .DOWN;
            return input_scancode_down(.s) || input_scancode_down(.down) || input_gamepad_button_down(0, .dpad_down);
        case .SELECT;
            return input_scancode_down(.space) || input_scancode_down(.enter) || input_gamepad_button_down(0, .south);
        case .CANCEL;
            return input_scancode_down(.escape) || input_gamepad_button_down(0, .east);
        case .RESET;
            return input_scancode_down(.backspace) || input_gamepad_button_down(0, .north);
    }

    return false;
}

input_button_up :: (btn : Button) -> bool {
    return !input_button_down(btn);
}

input_button_pressed :: (btn : Button) -> bool {
    if btn == {
        case .ESCAPE;
            return input_scancode_pressed(.escape) || input_gamepad_button_pressed(0, .touchpad) || input_gamepad_button_pressed(0, .back) || input_gamepad_button_pressed(0, .guide) || input_gamepad_button_pressed(0, .start);
        case .LEFT;
            return input_scancode_pressed(.a) || input_scancode_pressed(.left) || input_gamepad_button_pressed(0, .dpad_left);
        case .RIGHT;
            return input_scancode_pressed(.d) || input_scancode_pressed(.right) || input_gamepad_button_pressed(0, .dpad_right);
        case .UP;
            return input_scancode_pressed(.w) || input_scancode_pressed(.up) || input_gamepad_button_pressed(0, .dpad_up);
        case .DOWN;
            return input_scancode_pressed(.s) || input_scancode_pressed(.down) || input_gamepad_button_pressed(0, .dpad_down);
        case .SELECT;
            return input_scancode_pressed(.space) || input_scancode_down(.enter) || input_gamepad_button_pressed(0, .south);
        case .CANCEL;
            return input_scancode_pressed(.escape) || input_gamepad_button_pressed(0, .east);
        case .RESET;
            return input_scancode_pressed(.backspace) || input_gamepad_button_pressed(0, .north);
    }

    return false;
}

input_button_released :: (btn : Button) -> bool {
    if btn == {
        case .ESCAPE;
            return input_scancode_released(.escape) || input_gamepad_button_released(0, .touchpad) || input_gamepad_button_released(0, .back) || input_gamepad_button_released(0, .guide) || input_gamepad_button_released(0, .start);
        case .LEFT;
            return input_scancode_released(.a) || input_scancode_released(.left) || input_gamepad_button_released(0, .dpad_left);
        case .RIGHT;
            return input_scancode_released(.d) || input_scancode_released(.right) || input_gamepad_button_released(0, .dpad_right);
        case .UP;
            return input_scancode_released(.w) || input_scancode_released(.up) || input_gamepad_button_released(0, .dpad_up);
        case .DOWN;
            return input_scancode_released(.s) || input_scancode_released(.down) || input_gamepad_button_released(0, .dpad_down);
        case .SELECT;
            return input_scancode_released(.space) || input_scancode_down(.enter) || input_gamepad_button_released(0, .south);
        case .CANCEL;
            return input_scancode_released(.escape) || input_gamepad_button_released(0, .east);
        case .RESET;
            return input_scancode_released(.backspace) || input_gamepad_button_released(0, .north);
    }

    return false;
}
