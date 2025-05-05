
function! dbg#config#file(remote = dbg#remote#get())
    let sha = sha256(a:remote)
    return $"{stdpath("data")}/dbg.vim/{sha[0:1]}/{sha[2:]}"
endf

function! dbg#config#clean(config_file = dbg#config#file())

    if !filereadable(a:config_file)
        call dbg#log#info("no config file")
        return
    endif

    try
        call delete(a:config_file)
    catch
        call dbg#log#warning($"failed to delete config file {a:config_file}")
        return
    endtry
    call dbg#log#debug($"deleted config file {a:config_file}")
endf

function! dbg#config#get(file = dbg#config#file()) abort

    if filereadable(a:file)
        return a:file->readfile()->json_decode()
    endif

    call dbg#log#info($"no config file: creating empty config in {a:file}")

    let config = {}

    call mkdir(fnamemodify(a:file, ":p:h"), "p")

    call writefile([json_encode(config)], a:file)

    return config
endf
