
runtime cmd.vim

" So I want to be able to build the command that will be run to invoke the
" debugger
"
" This should accept an action dictionary like the one returned from GetAction
"
" dbg#cmd#build(action-dict, command, args)
"
" So

function TestBuildDebuggerCmdNoAction()
    let expected = ""
    let actual = dbg#cmd#build({}, "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

function TestBuildDebuggerCmdLaunch()
    let expected =
        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' /bin/bash"
    let actual = dbg#cmd#build(
        \ #{action: "launch", program_path: "/bin/bash"},
        \ "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

function TestBuildDebuggerCmdLaunchWithArgs()
    let expected =
        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' --args /bin/bash -c ls"
    let actual = dbg#cmd#build(
        \ #{action: "launch", program_path: "/bin/bash", program_args: ["-c", "ls"]},
        \ "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

function TestBuildDebuggerCmdLaunchWithCore()
    let expected =
        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' /bin/bash /etc/group"
    let actual = dbg#cmd#build(
        \ #{action: "launch", program_path: "/bin/bash", coredump_path: "/etc/group"},
        \ "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

function TestBuildDebuggerCmdArgsAndCore()
    let expected = ""
    let actual = dbg#cmd#build(#{
        \ action: "launch",
        \ program_path: "/bin/bash",
        \ coredump_path: "/etc/group",
        \ program_args: ["-c", "ls"]},
        \ "gdb", g:default_gdb_args)
    call assert_equal(expected, actual)
endf

"function TestBuildDebuggerCmdAttachPid()
"    let expected =
"        \ "gdb -quiet -iex 'set pagination off' -iex 'set print pretty on' -iex 'set mi-async on' -p 31892"
"    let actual = dbg#cmd#build(
"        \ #{action: "attach-pid", pid: 31892},
"        \ "gdb", g:default_gdb_args)
"    call assert_equal(expected, actual)
"endf
