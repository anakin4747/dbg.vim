
let s:repo = "dbg.vim"

if !exists('DbgLogging')
    let DbgLogging = v:false
endif

function! ToggleDbgLogging()
    let g:DbgLogging = !g:DbgLogging
endf

function! LogDebug(msg)
    if !g:DbgLogging
        return
    endif

    echohl QuickFixLine
    echom $"{s:repo}: debug: {a:msg}"
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
    echom $"{s:repo}: error: {a:msg}"
    echohl None
endf
