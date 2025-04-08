" Given the current file, get the remote of that repo
function! GetRemote(file)
    let dirname = fnamemodify(a:file, ":p:h")
    try
        return $"git -C {dirname} remote -v"->system()->split()[1]
    catch
        return ""
    endtry
endf
