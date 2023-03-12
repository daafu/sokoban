#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "SDL";

#scope_module

GamepadButton :: enum u8 {
    SOUTH;
    EAST;
    NORTH;
    WEST;

    DPAD_LEFT;
    DPAD_RIGHT;
    DPAD_UP;
    DPAD_DOWN;

    BACK;
    OPTIONS;
    START;
    TOUCHPAD;
}

#scope_file
gamepad : *SDL_GameController = null;

button_mapping : [12] SDL_GameControllerButton = .[
    SDL_CONTROLLER_BUTTON_A,
    SDL_CONTROLLER_BUTTON_B,
    SDL_CONTROLLER_BUTTON_Y,
    SDL_CONTROLLER_BUTTON_X,

    SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
    SDL_CONTROLLER_BUTTON_DPAD_UP,
    SDL_CONTROLLER_BUTTON_DPAD_DOWN,

    SDL_CONTROLLER_BUTTON_BACK,
    SDL_CONTROLLER_BUTTON_GUIDE,
    SDL_CONTROLLER_BUTTON_START,
    20, // Touchpad
];

#scope_module
gamepad_init :: () {
    SDL_Init(SDL_INIT_GAMECONTROLLER);
    gamepad_check_connected();
}

gamepad_check_connected :: () {
    prev_gamepad := gamepad;
    gamepad = SDL_GameControllerOpen(0);

    if gamepad != prev_gamepad {
        if gamepad == null {
            audio_play_sound(sound_cancel, true);
            print("gamepad disconnected\n");
        }
        else {
            audio_play_sound(sound_select, true);
            print("gamepad connected\n");
        }
    }
}

gamepad_update :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        if event.type == {
            case SDL_CONTROLLERDEVICEADDED; #through;
            case SDL_CONTROLLERDEVICEREMOVED; #through;
            case SDL_CONTROLLERDEVICEREMAPPED;
                gamepad_check_connected();
        }
    }
}

gamepad_get_analog :: () -> Vector2 {
    if !gamepad return .{0, 0};

    analog : Vector2 = .{0, 0};

    axis : s16 = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_LEFTX);
    if axis >= 0 analog.x = cast(float)axis / cast(float)S16_MAX;
    else analog.x = cast(float)axis / (-cast(float)S16_MIN);

    axis = SDL_GameControllerGetAxis(gamepad, SDL_CONTROLLER_AXIS_LEFTY);
    if axis >= 0 analog.y = cast(float)axis / cast(float)S16_MAX;
    else analog.y = cast(float)axis / (-cast(float)S16_MIN);

    return analog;
}

gamepad_get_button :: (btn : GamepadButton) -> bool {
    if !gamepad return false;
    return ifx SDL_GameControllerGetButton(gamepad, button_mapping[btn]) != 0 then true else false;
}