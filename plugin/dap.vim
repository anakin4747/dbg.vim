
" Describe the debugging experience you want.
"
" - provide 2 ways of debugging, one with the dap repl and the other with gdb
"   repl for languages that support gdb
" - a way to jump back to current line being debugged
" - application either open up to the right or in a new tab with <esc><esc>
"   disabled
" - support for external terminal for launching process
" - at the bottom the gdb prompt is open with preset settings at a set height
" - a temporary buffer which contains the backtrace indented so that folds can
"   work for you
" - a temporary buffer which contains variables that can be treated like folds
"   - the scope of the variables can be chosen explicitly to be local, global,
"   or both
" - treesitter highlighting in the gdb terminal
" - a way to show variables in the specific scope and be able to
"   increase/decrease the depth of the scope
" - launch commands for debugger can be configured
" - launch commands for debuggee can be configured
" - save launch commands for specific repos
" - setup defaults for your most common languages
" - a way to highlight a section of code and debug that section
" - maybe have a way to read .vscode/launch.json files
" - cool to tell you if the application you are trying to debug does not have
"   debug symbols
"
" dap.vim - A Debug Adapter Protocol client the Vim way
" Maintainer:   Anakin Childerhose
" Version:      0.1


" COMMANDS TO ADD
"
" DbgStart
" - No arguments tries its best to run last debug session in that repo
" - Ask for application to debug if none yet provided
" - Restarts your debugging session if there is one
" - The repo specific config needs to be merged with the debugger configs so
"   that the repo specific configs can override the global config
" DbgStart <program>
" - Starts debugging that program but first saves the config for running in
"   that directory so that you don't need to respecify the program
" DbgStart <program> <core>
" - Starts debugging that program with that core dump, updates the application
"   to debug for that repo but not necessarily the core dump
" - Maybe store reference to coredump to be able to reuse most recent core
"   dump(s) (maybe a history of coredumps used for that repo)
"   (maybe a history of debuggees used for that repo)
" DbgStart <pid>
" - Attach to pid to debug
" - Will have a history of all last calls of DbgStart so that it uses the
"   settings of your most recent invocation of any way of calling DbgStart
"   overlaid with the rest of the config that was stored for that repo
" - Check if the arg is an int and that int is a process
" DbgStart <ip> <port>
" - Soft check that ip matches close enough to an ip address and the port is an
"   int in the port ranges
" - Attach to ip address and port
" - Let gdb do most of the talking you know, like if gdb cant find the ip
"   address just let that be sent to the gdb window so that I know why it
"   failed to connect. Saves you from having to implement it yourself
" - Possibly support telnet connections
"
" _DbgSaveConfig_ (Maybe not, it should just build up automatically)
" - Saves a config for that repo
" - Hash on the remote and figure out how git hashes are stored so that you can
"   keep track of every config for every remote
" - On updates to the config, commit each internally to have a history for all
"   changes, that way you can have a repo of all your configs as it grows
" - Maybe track repo configurations by their remote so you check the remote to
"   know which configuration to use
"
" DbgEditRepoConfig
" - Edits the config for that repo
"
" DbgEditConfig
" - Edits the config for the debuggers
"
" DbgJump2CurrentLine
" - Jump to the current line being debugged


" DbgStart arg parsing logic
"
" If no args, look to last item in history, if no history, prompt for an
" application to debug
" - return action "prompt"
"
" If one argument is passed see if it is a number, if so treat it as a pid
" - set pid and return action "attach-to-pid"
"
" If one arg and a path is provided
" - set the "program" and return action "launch"


"if exists('g:loaded_dap')
"    finish
"endif
"let g:loaded_dap = 1


function! SetGlobalConfig()
lua << EOF
    package.loaded["dbg-cfg"] = nil -- Invalidate cache
    vim.api.nvim_set_var("dbg_cfg", require("dbg-cfg"))
EOF
endfunction

let g:dbg_cfg = {}
echo g:dbg_cfg
call SetGlobalConfig()
echo g:dbg_cfg


" TODO: Add runtime test to make sure all of these features are supported in
" gdb
let g:gdb_args = "-quiet -iex set pagination off -iex set mi-async on"

" repo local configs need to be stored in a file somewhere
"
" like have one file that stores the repos root dir in the first column and the
" second column is just the config vimscript dict

function s:ValidateConfig(config) abort
    for [ft, ft_config] in items(a:config)
        let cmd = split(ft_config.cmd)[0]
        if !executable(cmd)
            echoerr $"dap.vim: ValidateConfig: bad config for '{ft}', '{cmd}' not executable."
        endif
    endfor
endfunction

"call s:ValidateConfig(g:dap_config)

let repo_config = #{
    \ coredump_path: "",
    \ program_path: "",
    \ target: #{ ip: "", pid: -1, port: -1, },
    \}

let state = #{
    \ config: [g:dbg_cfg, repo_config],
    \ server: #{ pty_id: -1 },
    \ }

"lua << EOF
"    local var = vim.api.nvim_get_var("state")
"    print(vim.inspect(var))
"EOF

function s:InitDebugServer(s)
    let a:s.server.pty_id = termopen('tail -f /dev/null;#gdb program')
    if a:s.server.pty_id == 0
        echoerr 'invalid argument (or job table is full) while opening terminal window'
        finish
    elseif a:s.server.pty_id == -1
        echoerr 'Failed to open the program terminal window'
        finish
    endif
endf

function! s:TryLaunch(args, cfg)
    let prog = get(a:args, 0, get(a:cfg, "program_path", ""))

    " Cannot use executable() since it searches $PATH
    if getfperm(prog) =~ '..x......'
        let core = get(a:args, 1, get(a:cfg, "coredump_path", ""))
        if filereadable(core)
            return #{action: "launch", program_path: prog, coredump_path: core}
        endif
        return #{action: "launch", program_path: prog}
    endif
endf

function! s:TryAttachIP(args, cfg)
    let ip = get(a:args, 0, get(a:cfg, "ip", ""))

    if ip =~ '\v^(\d{1,3}\.){3}\d{1,3}$'
        let port = str2nr(get(a:args, 1, get(a:cfg, "port", -1)))
        if port < 65535 && port > 0
            return #{action: "attach-ip", ip: ip, port: port}
        endif
        return #{action: "attach-ip", ip: ip}
    endif
endf

function! s:TryAttachPid(args, cfg)
    let max_pid = '/proc/sys/kernel/pid_max'->readfile()[0]->str2nr()

    let pid = str2nr(get(a:args, 0, get(a:cfg, "pid", "-1")))

    if pid < max_pid && pid > 0
        return #{action: "attach-pid", pid: pid}
    endif
endf

function! s:TryAttachProc(args, cfg)
    let proc = get(a:args, 0, get(a:cfg, "proc", ""))

    " Maybe we won't just want the first one in the future
    let pid = $"pgrep {proc}"->system()->split()[0]->str2nr()

    let max_pid = '/proc/sys/kernel/pid_max'->readfile()[0]->str2nr()

    if pid < max_pid && pid > 0
        return #{action: "attach-pid", pid: pid}
    endif
endf

function! GetAction(cfg, args = "")
    if empty(a:cfg) && empty(a:args)
        return #{action: "prompt"}
    endif

    let args = split(a:args)

    for action_to_try in ['s:TryLaunch', 's:TryAttachIP', 's:TryAttachPid', 's:TryAttachProc']
        let action = call(action_to_try, [args, a:cfg])
        if !empty(action)
            return action
        endif
    endfor
endf

" TODO: smarter tab completion
command -nargs=* -complete=file DbgStart call s:DbgStart("<args>")

function! s:DbgStart(args = "")
    let action = GetAction({}, a:args)
    echo action
endf

