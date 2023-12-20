#include "rgb30_controller.h"

/**
 * Raylib's IsGamepadButtonPressed function doesn't work on RGB30, so we need to
 * keep track of the button state ourselves. Sometimes, it will work, but it's
 * not reliable.
*/
bool is_button_pressed(int button)
{
    return button_state[button] == 0 && prev_button_state[button] == 1;
}

void update_button_state(void)
{
    for (int i = 0; i < RGB30_BUTTON_COUNT; i++)
    {
        if (IsGamepadButtonDown(0, i))
        {
            button_state[i] = 1;
        }
    }
}

void refresh_button_state(void)
{
    for (int i = 0; i < RGB30_BUTTON_COUNT; i++)
    {
        prev_button_state[i] = button_state[i];
        button_state[i] = 0;
    }
}
