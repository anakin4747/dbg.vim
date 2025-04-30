
Still a WIP project at the moment.

# dbg.vim

A debugger plugin for Neovim that configures itself.

Inspired by the most canonical debugger plugin: `termdebug.vim`.

# Motivation

I wanted to write a debugger plugin that fits my needs for debugging embedded C
applications that would be easy to configure repo specific debug
configurations (ideally no configuration required).

I wanted a codebase that would be easy to read and maintain by loosely
following the Linux kernel coding style.

I want to be able to easily switch between debuggers for the same language and
different languages.

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
- [ ] node inspect support
- [ ] External terminal support
- [ ] launch.json support
- [ ] Config git history auto generated
- [ ] Selecting new debug settings from history

# Notes

Assume you have a C and rust codebase which also has python scripts. You want
to be able to debug C and rust both with gdb and lldb, you also want to be able
to debug python with pdb and debugpy.

For example in the linux codebase there are a bunch of scripts in bash, python,
perl, as well as code written in c, rust and assembly.

How will you make this easy to configure.



The action history will need to be debugger specific


Plan the sources of config ahead of time to think about how they will be merged
and saved.


:Dbg will assume the last filetype when one cannot be detected from the current
buffer

:Dbgr
- Shows current debugger
:Dbgr lldb
- set current debugger for repo and filetype
- do this by saving a custom config in the config of that repo,
  custom configs will always have priority over the defaults.
- Need a history of debuggers configured for that repo, so that when you change
  the debugger a second time the new one takes priority but the previous still
  takes higher priority than the default. (Could this priority be used to list
  which ones first in tab completion? Where else will this priority be used?
  Its only really for the first one right?)
:Dbgrs
- Shows all debuggers available for that filetype

So when a user starts using it they should have to do the least amount of
config as possible. That means default debuggers will need to be choosen for
each language so that the user doesn't have to choose. But the user will want a
way to change the current debugger being used. The user should be able to pick
between a few preselected debugger configs for the current filetype. I want it
plain simple and easy, try to avoid making the user edit the config file but
also allow them to as well.

What is the easiest way to choose between the debugger options.
Maybe like :Dbgr <Tab> completion of the possible debuggers for that
filetype.

The history of actions needs to be scoped to either one type of debugger or one
filetype. (filetype since hopefully the actions available should be
language specific and hopefully not dubegger specific)

Need to think out more how the action history will be stored with respect to
the debugger configs. You always want the actions to be available. Maybe the
actions can try to stay debugger agnostic so that switching debuggers doesn't
require making a new action.

Maybe have a way to prioritize actions from the current debugger (or filetype)
but have action histories from all the debuggers.

Action histories should probably be scoped with filetypes to try to be agnostic
between the different debuggers available for that filetype.

Also for user experience you need to think about how you will allow configuring
of layouts/tabs this will also need to be stored in the repo's config.



You will need handlers for each type of backend like
MI
DAP
Pulling info off the buffer
Unique debuggers


- Debugger sessions for each filetype so that you can be debugging two
  different languages at the same time


- Add a way to provide better in vim docs for each debugger

- Be able to highlight a portion of code to pass to debugger to loop around on
  and automatically set a break point and start debugging at it.


## UX for Kernel Development

The kernel has source code of several languages.

I want to be able to save debug information for C, C++, ASM, Rust, Python,
Bash, Awk, and Perl.

How do I set the precmds and postcmds?

:compiler integration?

- Breakpoints listed in quickfix list to take advantage of :cn, :cc, :cp,
  :clist, etc
  :Cbreak
- Breakpoints for the current file can use locationlists
  :Lbreak

<!-- vim: set spell : -->
