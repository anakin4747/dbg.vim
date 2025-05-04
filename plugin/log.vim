
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
