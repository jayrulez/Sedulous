# Sedulous
Sedulous is a framework that can be used to create games and other applications.
It is designed to be modular, allowing you to use just the bits you want.

Sedulous comprises of the following modules:

### Sedulous.Foundation
This is a standalone library providing math, collections and logging utilities, as well as useful type extensions.

### Sedulous.Core
This is the heart of the framework and builds on the foundation library. It houses the framework context and provides access to the framework lifecycle,  resources and systems.

### Sedulous.RHI
This is a library providing abstract low level access to graphics resources.

### Sedulous.RHI.OpenGL
The OpenGL implementation of the RHI abstractions.

### Sedulous.Audio
This library provides access to the audio device, audio resource management, and audio playback.

### Sedulous.Audio.OpenAL
The OpenAL implementation of the audio abtsractions.

### Sedulous.Graphics
This is a high level graphics library built on top of the RHI. It supports PBR and is used for rendering meshes, sprites, particles, etc...

### Sedulous.Platform
This library is an abstraction over platform concerns like windowing, input, etc...
These abstractions are expected to be implemented by a backend targeting a specific OS or platform.

### Sedulous.SDL2
This library provides implementations for some platform abstractions. 
It is expected that this library will be extended by another library that targets a specific platform class. E.g.: Desktop, Web, etc...

### Sedulous.Platform.Desktop
The desktop implementation of platform. It makes use of the SDL2 support library for implementing most platform concerns.

# Note
This library is in the very early stages of development and is not yet useful for others.

Below is a list of items that are currently being worked on.

### Foundation
- [x] Collections
- [x] Extensions
- [x] Job System
- [x] Logging
- [x] Mathematics
- [x] Utilities
- [x] Events

### Core
- [x] Context/Life Cycle
- [x] Subsystems
- [ ] Asset System

### Platform
- [ ] Windowing
- [ ] Keyboard
- [ ] Mouse
- [ ] Game Pad
- [ ] Touch
- [ ] Desktop Backend
- [ ] Web Backend

### RHI
- [ ] Abstraction
- [ ] Vulkan
- [ ] OpenGL
- [ ] DX12

### Audio
- [ ] Abstraction
- [ ] OpenAL

### Graphics
- [ ] Mesh Rendering
- [ ] Font Rendering
- [ ] Sprite Rendering
- [ ] Particle Systems

### SDL2
- [x] Bindings
- [ ] Windowing
- [ ] Input
- [ ] Context hosting