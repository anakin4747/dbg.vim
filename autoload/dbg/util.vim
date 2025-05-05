
function! dbg#util#debuggable()
    if empty(&filetype)
        call dbg#log#filetypeUsage()
        return v:false
    endif

    let remote = dbg#remote#get()
    if empty(remote)
        call dbg#log#warning("failed to get remote")
        call dbg#log#info("make sure you are in a git repo")
        return v:false
    endif

    return v:true
endf
