" Given the current file, get the remote of that repo
function! GetRemote(file) abort
    call LogDebug($"a:file: {a:file}")

    if type(a:file) != v:t_string
        call LogError("GetRemote() expects a string")
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

    call LogDebug($"dirname: {dirname}")

    try
        return $"git -C {dirname} remote -v"->system()->split()[1]
    catch
        call LogError("Failed to get remote")
        return ""
    endtry
endf
