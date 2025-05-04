
let s:repo = "dbg.vim"

if !exists('s:DbgLogging')
    let s:DbgLogging = v:false
endif

function! dbg#log#toggle()
    let s:DbgLogging = !s:DbgLogging
endf

function! dbg#log#callingFunc(sfile = expand('<sfile>')) abort
    return a:sfile->substitute('function ', '', '')
                \ ->split('\.\.')[-2]
                \ ->substitute('^<SNR>\d\+_', 's:', '')
endf

function! dbg#log#debug(msg)
    if !s:DbgLogging
        return
    endif

    echohl QuickFixLine
    echom $"{s:repo}: debug: {dbg#log#callingFunc()}: {a:msg}"
    echohl None
endf

function! dbg#log#info(msg)
    echohl ModeMsg
    echom $"{s:repo}: info: {a:msg}"
    echohl None
endf

function! dbg#log#warning(msg)
    echohl WarningMsg
    echom $"{s:repo}: warning: {a:msg}"
    echohl None
endf

function! dbg#log#error(msg)
    echohl ErrorMsg
    echom $"{s:repo}: error: {dbg#log#callingFunc()}: {a:msg}"
    echohl None
endf

function! dbg#log#good(msg)
    echohl Title
    echom $"{s:repo}: {a:msg}"
    echohl None
endf

function! dbg#log#usage()
    call dbg#log#good("usage:")
    call dbg#log#good(" first:")
    call dbg#log#good("   :Dbg [ PROGRAM ] [ COREDUMP ]")
    call dbg#log#good("   :Dbg [ PID ]")
    call dbg#log#good("   :Dbg [ PROCESS_NAME ]")
    call dbg#log#good("   :Dbg [ IP ] [ PORT ]")
    call dbg#log#good(" then:")
    call dbg#log#good("   :Dbg")
endf

function! dbg#log#filetypeUsage()
    call dbg#log#warning("no &filetype set")
    call dbg#log#info("make sure the &filetype option is properly set to the filetype you wish to debug")
    call dbg#log#good("To read the filetype option try: ':set filetype?' or ':echo &filetype'")
endf
