
runtime cmd.vim

" So I want to be able to build the command that will be run to invoke the
" debugger
"
" This should accept an action dictionary like the one returned from GetAction
"
" BuildDebuggerCmd(action-dict, command, args)
"
" So

function TestBuildDebuggerCmdNoAction()
    let expected = []
    let actual = BuildDebuggerCmd({}, "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

" TODO: The tty needs to be passed to BuildDebuggerCmd for it to be in the
" right order
function TestBuildDebuggerCmdLaunch()
    let expected = [
        \ 'gdb',
        \ '-quiet',
        \ '-iex', 'set pagination off',
        \ '-iex', 'set print pretty on',
        \ '-iex', 'set mi-async on',
        \ '/bin/bash'
        \ ]
    let actual = BuildDebuggerCmd(
        \ #{action: "launch", program_path: "/bin/bash"},
        \ "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

"function TestBuildDebuggerCmdLaunchWithArgs()
"    let expected =
"        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' --args /bin/bash -c ls"
"    let actual = BuildDebuggerCmd(
"        \ #{action: "launch", program_path: "/bin/bash", program_args: ["-c", "ls"]},
"        \ "gdb", g:default_gdb_args)
"    call assert_equal(expected, actual)
"endf
"
"function TestBuildDebuggerCmdLaunchWithCore()
"    let expected =
"        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' /bin/bash /etc/group"
"    let actual = BuildDebuggerCmd(
"        \ #{action: "launch", program_path: "/bin/bash", coredump_path: "/etc/group"},
"        \ "gdb", g:default_gdb_args)
"    call assert_equal(expected, actual)
"endf
"
"function TestBuildDebuggerCmdAttachPid()
"    let expected =
"        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' -p 31892"
"    let actual = BuildDebuggerCmd(
"        \ #{action: "attach-pid", pid: 31892},
"        \ "gdb", g:default_gdb_args)
"    call assert_equal(expected, actual)
"endf
