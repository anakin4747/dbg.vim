
Still a WIP project at the moment.

# dbg.vim

A debugger plugin for Neovim that configures itself.

Inspired by the most canonical debugger plugin: `termdebug.vim`.

# Motivation

I wanted to write a debugger plugin that fits my needs for debugging embedded C
applications that would be easy to configure repo specific debug
configurations.

I wanted a codebase that would be easy to read and maintain by loosely
following the Linux kernel coding style.

# Features

- [x] Launching
- [x] Launching with a coredump file
- [ ] Attaching to a PID
- [ ] Attaching to a process by name
- [ ] Attaching to an IP address
- [ ] Attaching to an IP address and port number
- [x] Repo specific configurations
- [ ] MI support
- [ ] DAP support
- [ ] External terminal support
- [ ] launch.json support
- [ ] Config git history auto generated
