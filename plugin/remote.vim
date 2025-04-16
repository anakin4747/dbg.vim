" Given the current file, get the remote of that repo
function! GetRemote(file)

    if a:file =~ "^term://"
        let pid = a:file->bufnr()->getbufvar('terminal_job_pid')
        let dirname = $"/proc/{pid}/cwd"->resolve()
    else
        let dirname = fnamemodify(a:file, ":p:h")
    endif

    try
        return $"git -C {dirname} remote -v"->system()->split()[1]
    catch
        return ""
    endtry
endf
