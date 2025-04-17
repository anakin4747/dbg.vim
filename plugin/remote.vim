" Given the current file, get the remote of that repo
function! GetRemote(file) abort
    if type(a:file) != v:t_string
        return ""
    endif

    if a:file =~ "^term://"
        let pid = a:file->bufnr()->getbufvar('terminal_job_pid')
        let dirname = $"/proc/{pid}/cwd"->resolve()
    elseif a:file =~ "^/tmp"
        let dirname = getcwd()
    else
        let dirname = fnamemodify(a:file, ":p:h")
    endif

    try
        return $"git -C {dirname} remote -v"->system()->split()[1]
    catch
        return ""
    endtry
endf
