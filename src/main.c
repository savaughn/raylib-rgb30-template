#include "rgb30_controller.h"

#define SCREEN_WIDTH 720
#define SCREEN_HEIGHT 720

void draw_screen(void)
{
    BeginDrawing();
    ClearBackground(BLACK);

    DrawText("RGB30 raylib template", SCREEN_WIDTH / 2 - MeasureText("RGB30 raylib template", 20) / 2, 10, 20, WHITE);
    for (int i = 0; i < RGB30_BUTTON_COUNT; i++)
    {
        if (i == _UNUSED_MIDDLE_BUTTON)
        {
            continue;
        }
        IsGamepadButtonDown(0, i) ? DrawRectangle(10, 40 + i * 30, 100, 20, GREEN) : DrawRectangle(10, 40 + i * 30, 100, 20, RED);
        DrawText(rgb30_button_names[i], 10, 40 + i * 30, 20, WHITE);

        if (is_button_pressed(i))
        {
            DrawCircle(SCREEN_WIDTH *0.75, SCREEN_HEIGHT / 4, 50, GREEN);
            DrawText(rgb30_button_names[i], SCREEN_WIDTH *0.75 - MeasureText(rgb30_button_names[i], 20) / 2, SCREEN_HEIGHT / 4 - 10, 20, WHITE);
            last_button_pressed = i;
        }
    }

    if (last_button_pressed != RGB30_BUTTON_UNKNOWN)
    {
        DrawText("Last button pressed:", SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 20, WHITE);
        DrawText(rgb30_button_names[last_button_pressed], SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 30, 20, WHITE);
    }

    DrawText("Press start + select to exit", SCREEN_WIDTH / 2 - MeasureText("Press start + select to exit", 20) / 2, 680, 20, WHITE);

    EndDrawing();
}

int main(void)
{

    InitWindow(720, 720, "RGB30 raylib template");
    SetTargetFPS(60);

    // SetExitKey() doesn't work on RGB30, so we need to use a different method
    bool should_close = false;

    while (!should_close)
    {
        // Required for is_button_pressed() to work on RGB30
        update_button_state();

        draw_screen();

        if (IsGamepadButtonDown(0, RGB30_BUTTON_MIDDLE_RIGHT) && IsGamepadButtonDown(0, RGB30_BUTTON_MIDDLE_LEFT))
        {
            should_close = true;
        }

        // Required for is_button_pressed() to work on RGB30
        refresh_button_state();
    }

    CloseWindow();

    return 0;
}
