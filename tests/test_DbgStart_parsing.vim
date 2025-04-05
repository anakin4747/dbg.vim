
runtime dap.vim

" DONT YOU STILL NEED AN ELF EVEN IF YOU ATTACH? might need to consider that
"
" debugable file is recommended but not required
"
" For prompt, after the file has been set proceed to a different action

" Should it be called GetAction? How do I know if the function is doing too much
" Do I separate parsing the command line from GetAction? likely right?
"
"
" So the prompt will ask you to fill in the necessary fields and choose the
" action in the config
"
" Or just manage the prompting in another section
"
"
" state: misconfigured
"        V
"    action: prompt
"        V
" state: configuration
"        V
"    action: select action
"        V
"    action: launch || attach-*
"        V
" state: running

function! TestNoArgsNoConfig()
    let expected = #{action: "prompt"}
    let actual = GetAction({}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithProg()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction(#{program_path: "/bin/bash"}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithProgCore()
    let expected = #{
        \ action: "launch",
        \ program_path: "/bin/bash",
        \ coredump_path: "/etc/group",
        \}
    let actual = GetAction(#{
        \ program_path: "/bin/bash",
        \ coredump_path: "/etc/group",
        \}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithPid()
    let expected = #{action: "attach-pid", pid: 31892}
    let actual = GetAction(#{pid: 31892}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithIp()
    let expected = #{action: "attach-ip", ip: "192.168.20.34"}
    let actual = GetAction(#{ip: "192.168.20.34"}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithIpPort()
    let expected = #{action: "attach-ip", ip: "192.168.20.34", port: 44009}
    let actual = GetAction(#{ip: "192.168.20.34", port: 44009}, "")
    call assert_equal(expected, actual)
endfunction

function! TestNoArgsWithIpBadPort()
    let expected = #{action: "attach-ip", ip: "192.168.20.34"}
    let actual = GetAction(#{ip: "192.168.20.34", port: -1}, "")
    call assert_equal(expected, actual)
endfunction

function! TestProgArgNoConfig()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction({}, "/bin/bash")
    call assert_equal(expected, actual)
endfunction

function! TestProgArgWithSpaceNoConfig()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction({}, " /bin/bash ")
    call assert_equal(expected, actual)
endfunction

function! TestProgCoreArgNoConfig()
    let expected = #{
        \ action: "launch",
        \ program_path: "/bin/bash",
        \ coredump_path: "/etc/group"
        \}
    let actual = GetAction({}, "/bin/bash /etc/group")
    call assert_equal(expected, actual)
endfunction

function! TestPidArgNoConfig()
    let expected = #{action: "attach-pid", pid: 31892}
    let actual = GetAction({}, "31892")
    call assert_equal(expected, actual)
endfunction

function! TestIpArgNoConfig()
    let expected = #{action: "attach-ip", ip: "192.168.30.23"}
    let actual = GetAction({}, "192.168.30.23")
    call assert_equal(expected, actual)
endfunction

function! TestIpPortArgNoConfig()
    let expected = #{
        \ action: "attach-ip",
        \ ip: "192.168.30.23",
        \ port: 31892,
        \}
    let actual = GetAction({}, "192.168.30.23 31892")
    call assert_equal(expected, actual)
endfunction

function! TestProgArgBeatsConfig()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction(#{program_path: "/usr/bin/zsh"}, "/bin/bash")
    call assert_equal(expected, actual)
endfunction

function! TestProgArgBeatsConfig()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction(#{program_path: "/usr/bin/zsh"}, "/bin/bash")
    call assert_equal(expected, actual)
endfunction

function! TestProgArgBeatsConfig()
    let expected = #{action: "launch", program_path: "/bin/bash"}
    let actual = GetAction(#{program_path: "/usr/bin/zsh"}, "/bin/bash")
    call assert_equal(expected, actual)
endfunction

" TODO: Repeat the above test for the other situation
"
" What priority of things in the config should be
"
" Choose ip over pid
"
" if there is an ip
" - choose the ip
" - program_path is always useful
" - ip and port
