
let s:repo = "dbg.vim"

if !exists('s:DbgLogging')
    let s:DbgLogging = v:false
endif

function! ToggleDbgLogging()
    let s:DbgLogging = !s:DbgLogging
endf

function! GetCallingFunc(sfile = expand('<sfile>')) abort
    return a:sfile->substitute('function ', '', '')
                \ ->split('\.\.')[-2]
                \ ->substitute('^<SNR>\d\+_', 's:', '')
endf

function! LogDebug(msg)
    if !s:DbgLogging
        return
    endif

    echohl QuickFixLine
    echom $"{s:repo}: debug: {GetCallingFunc()}: {a:msg}"
    echohl None
endf

function! LogInfo(msg)
    echohl ModeMsg
    echom $"{s:repo}: info: {a:msg}"
    echohl None
endf

function! LogWarning(msg)
    echohl WarningMsg
    echom $"{s:repo}: warning: {a:msg}"
    echohl None
endf

function! LogError(msg)
    echohl ErrorMsg
    echom $"{s:repo}: error: {GetCallingFunc()}: {a:msg}"
    echohl None
endf

function! PrintUsage()
    " TODO: Make usage more usage like
    echohl Title
    echom 'Try one of:'
    echom ' :Dbg /path/to/program'
    echom ' :Dbg <pid>'
    echom ' :Dbg <name of process>'
    echom ' :Dbg <ip> <port>'
    echom 'Then:'
    echom ' :Dbg'
    echohl None
endf

function! PrintFiletypeUsage()
    call LogWarning("no &filetype set")
    call LogInfo("make sure the &filetype option is properly set to the filetype you wish to debug")
    echohl Title
    echom "To read the filetype option try: ':set filetype?' or ':echo &filetype'"
    echohl None
endf
