# Raylib Game Template for Powkiddy RGB30

This is a template project for creating games with [raylib](https://www.github.com/raysan5/raylib) on the Powkiddy RGB30 Linux arm64 handheld.

## Setup Linux dev environment

```bash
./setup_linux.sh
```
This will allow you to save your device's SSH IP and password, install dev dependencies required to compile your game for aarch64 PLATFORM_DRM using OpenGL ES 2.0. It will call initialize_rgb30 in the makefile which will access your device over ssh and create the required folder in ports, add a launch script, and update the gameslist.xml with your project's entry.

NOTE: Be sure that your device is on, connected to same network as your development machine, and ssh is enabled.

 - Local IP: Start > Network Settings > Information > IP Address
 - Enable SSH: Start > Network Settings > Network Services > Enable SSH
 - Password: Start > System Settings > Authentication > Root Password

## Raylib dependency

Packaged with this template is raylib-5.1 compiled for PLATFORM_DRM. If you wish to run your builds on desktop during development, then you'll need to include a pre-built copy of raylib for PLATFORM_DESKTOP.

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
