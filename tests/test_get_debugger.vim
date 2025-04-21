" So the debugger should be determined by the filetype but if there is a
" debugger configured that takes priority
"
" The debugger configured for the repo is filetype dependent since a codebase
" may have many different languages and need different debuggers accordingly

function TestGetDebuggerConfiguredHasPriority()

    let configured_debugger = #{c: "lldb"}
    let default_debugger = #{c: "gdb"}

    let expected = "lldb"
    let actual = GetDebugger("c", configured_debugger, default_debugger)

    call assert_equal(expected, actual)
endf
