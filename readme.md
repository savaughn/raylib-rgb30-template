# Raylib Game Template for Powkiddy RGB30

This is a template project for creating games with [raylib](https://www.github.com/raysan5/raylib) on the Powkiddy RGB30 Linux arm64 handheld running JELOS using an arm64 Linux development machine. While cross-compiling is possible, it's outside the scope of this template.

![screenshot000](https://github.com/savaughn/raylib-rgb30-template/assets/25937456/782759a7-2b84-495b-8aa2-750318e60af0)

## Setup Linux dev environment

```bash
./setup_linux.sh
```
This will allow you to save your device's SSH IP and password, install dev dependencies required to compile your game for aarch64 PLATFORM_DRM using OpenGL ES 2.0. It will call initialize_rgb30 in the makefile which will access your device over ssh to create the required folder in ports and add a launch script.

NOTE: Be sure that your device is on, connected to same network as your development machine, and ssh is enabled.

 - Local IP: Start > Network Settings > Information > IP Address
 - Enable SSH: Start > Network Settings > Network Services > Enable SSH
 - Password: Start > System Settings > Authentication > Root Password

## Raylib dependency

Packaged with this template is raylib-5.0 compiled for PLATFORM_DRM. If you wish to run your builds on desktop during development, then you'll need to include a pre-built copy of raylib for PLATFORM_DESKTOP.

## Building for RGB30

To build specifically for the RGB30, use the following command:

```bash
make rgb30
```
Doing so keeps the raylib makefile relatively stock to facilitate development/testing on desktop.

## Sending build to device

To send the build to device over ssh, use the following command:

```bash
make send
```

## Additional Commands

To build and send to device, use:

```bash
make rgb30 send
```
## Custom controller implementation

- When compiled for PLATFORM_DRM, the rcore function, `IsGamepadButtonPressed`, doesn't return true when a button is pressed. Instead use `is_button_pressed` which returns a boolean on button press in conjunction with `update_button_state` before draw and `refresh_button_state` after draw. These functions emulate the raylib core implementation.

- The default value from raylib, `GAMEPAD_BUTTON_UNKNOWN = 0`, conflicts with the RGB30's keyinput values where RIGHT_FACE_DOWN ("B") reports as 0. The enum `rgb30_buttons` arranges the buttons by the keyinput value reported on the device.

## Known Issues
- Does not work on Rocknix due to graphics driver changes. I have to investigate further to determine the cause.

## Working Example
### [savaughn/vertical30](https://github.com/savaughn/vertical30)