" dbg.vim - Debugger plugin inspired by termdebug.vim
"
" Author:    Anakin Childerhose
" Copyright: Vim license applies, see ":help license"
" Version:   0.1

"if exists('g:loaded_dbg')
"    finish
"endif
"let g:loaded_dbg = 1

" TODO: smarter tab completion
command! -nargs=* -complete=file Dbg call Dbg("<args>")
command! -nargs=0 DbgStop call dbg#mi#stop(g:DbgState)
" TODO: needs filetype check
command! -nargs=0 DbgCleanConfig call CleanConfig()
" TODO: needs filetype check
command! -nargs=0 DbgShowConfig echom GetOrInitConfig()
command! -nargs=0 DbgLogToggle call dbg#log#toggle()
command! -nargs=* -complete=customlist,GetDebuggers Dbgr call Dbger("<args>")

function! GetDebuggers(_, __, ___)
    return [ "rust-gdb", "rust-lldb", "gdb", "lldb", "lldb-mi", "lldb-dap" ]
endf

" No prompts or messages
let default_gdb_args = "-quiet"
" Print it all out so I can page with vim
let default_gdb_args .= " -iex 'set pagination off'"
" Pretty printing is pretty important for folding
let default_gdb_args .= " -iex 'set print pretty on'"
" https://sourceware.org/gdb/current/onlinedocs/gdb.html/Asynchronous-and-non_002dstop-modes.html
let default_gdb_args .= " -iex 'set mi-async on'"

if !exists("g:DbgState")
    let g:DbgState = {}
endif

function! Dbg(args = "") abort

    if empty(&filetype)
        call dbg#log#filetypeUsage()
        return
    endif

    let remote = dbg#remote#get()
    if empty(remote)
        call dbg#log#warning("failed to get remote")
        call dbg#log#info("make sure you are in a git repo")
        return
    endif

    let config = GetOrInitConfig(GetConfigFile(remote))
    call dbg#log#debug($"config: {config}")

    let last_action = dbg#action#last(config)
    call dbg#log#debug($"last_action: {last_action}")

    let action = dbg#action#next(last_action, a:args)
    call dbg#log#debug($"action: {action}")

    if empty(action)
        call dbg#log#warning($"unable to perform any action for filetype: {&filetype}")
        call dbg#log#usage()
        return
    endif

    call dbg#action#save(action)

    if dbg#mi#running(g:DbgState)
        call dbg#log#info("restarting debugging session")
        call dbg#mi#stop(g:DbgState)
    endif

    let cmd = dbg#cmd#build(action, "gdb", g:default_gdb_args)
    call dbg#log#debug($"cmd: {cmd}")
    if empty(cmd)
        call dbg#log#error($"failed to build debugger command: {action} {g:default_gdb_args}")
        return
    endif

    let g:DbgState = dbg#mi#start(cmd)

endf
