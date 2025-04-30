
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

## TODOs

Think about default repo configs:
```
have a config already made for neovim, with the gdb option
"set follow-fork-mode child"
need to have some default configs to source
```

Change functions to throw errors and rely on abort instead of return values

Figure out how to properly test that a function throws an exception

Provide output for DbgStop to know if it was successful or not
:DbgStop does not stop dap jobs correctly at the moment

Next steps:
- Handle output from comm for mi stuff
add autocmd to enter insert mode when entering the debugger prompt buffer

" When you write the code first the tests you write are no longer black box
" tests, you having implemented the code are now more likely to make tests that
" are too tied into one implementation causing extra rewriting

The JobInit will create the window for the job to be in.
It will need the arguments of the location

Describe the debugging experience you want.

- provide 2 ways of debugging, one with the dap repl and the other with gdb
  repl for languages that support gdb
- a way to jump back to current line being debugged
- application either open up to the right or in a new tab with <esc><esc>
  disabled
- support for external terminal for launching process
- at the bottom the gdb prompt is open with preset settings at a set height
- a temporary buffer which contains the backtrace indented so that folds can
  work for you
- a temporary buffer which contains variables that can be treated like folds
  - the scope of the variables can be chosen explicitly to be local, global,
    or both
- treesitter highlighting in the gdb terminal
- a way to show variables in the specific scope and be able to
  increase/decrease the depth of the scope
- launch commands for debugger can be configured
- launch commands for debuggee can be configured
- save launch commands for specific repos
- setup defaults for your most common languages
- a way to highlight a section of code and debug that section
- maybe have a way to read .vscode/launch.json files
- cool to tell you if the application you are trying to debug does not have
  debug symbols


COMMANDS TO ADD

DbgStart
- No arguments tries its best to run last debug session in that repo
- Ask for application to debug if none yet provided
- Restarts your debugging session if there is one
- The repo specific config needs to be merged with the debugger configs so
  that the repo specific configs can override the global config
DbgStart <program>
- Starts debugging that program but first saves the config for running in
  that directory so that you don't need to respecify the program
DbgStart <program> <core>
- Starts debugging that program with that core dump, updates the application
  to debug for that repo but not necessarily the core dump
- Maybe store reference to coredump to be able to reuse most recent core
  dump(s) (maybe a history of coredumps used for that repo)
  (maybe a history of debuggees used for that repo)
DbgStart <pid>
- Attach to pid to debug
- Will have a history of all last calls of DbgStart so that it uses the
  settings of your most recent invocation of any way of calling DbgStart
  overlaid with the rest of the config that was stored for that repo
- Check if the arg is an int and that int is a process
DbgStart <ip> <port>
- Soft check that ip matches close enough to an ip address and the port is an
  int in the port ranges
- Attach to ip address and port
- Let gdb do most of the talking you know, like if gdb cant find the ip
  address just let that be sent to the gdb window so that I know why it
  failed to connect. Saves you from having to implement it yourself
- Possibly support telnet connections

_DbgSaveConfig_ (Maybe not, it should just build up automatically)
- Saves a config for that repo
- Hash on the remote and figure out how git hashes are stored so that you can
  keep track of every config for every remote
- On updates to the config, commit each internally to have a history for all
  changes, that way you can have a repo of all your configs as it grows
- Maybe track repo configurations by their remote so you check the remote to
  know which configuration to use

DbgEditRepoConfig
- Edits the config for that repo

DbgEditConfig
- Edits the config for the debuggers

DbgCurrentLine
- Jump to the current line being debugged

# Bugs

## DeinitJob tries to close closed windows

If you close the debugger and debuggee windows manually and then StopDebugger
gets called (via :Dbg or :DbgStop) this error occurs:
```
Error detected while processing function <SNR>46_Dbg[39]..StopDebugger[2]..DeinitJob:
line    2:
E5555: API call: Invalid window id: 1582
```
This should be cleanly handled and provide an info message of the situation.

<!-- vim: set spell : -->
