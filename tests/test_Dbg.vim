
function TestDbgCatchesNoFiletype()

    let buf_count_before = len(getbufinfo())
    let tmpfile = tempname()
    let filetype = &filetype
    set filetype=

    execute $"redir > {tmpfile}"

    try
        Dbg
    finally
        redir END
        execute $"set filetype={filetype}"
    endtry

    call assert_match('no &filetype set', tmpfile->readfile()->join("\n"))

    let buf_count_after = len(getbufinfo())

    call assert_equal(buf_count_before, buf_count_after)

    call delete(tmpfile)
endf

function BadTestDbgCatchesNoRemote()
    " This test messes up the view so its best not to run it everytime

    let buf_count_before = len(getbufinfo())

    let msgfile = tempname()
    let file_c = tempname()

    execute $"edit {file_c}"
    cd /tmp

    let filetype = &filetype
    set filetype=test

    execute $"redir > {msgfile}"

    try
        Dbg
    finally
        redir END
        execute $"set filetype={filetype}"
        execute $"bwipeout {file_c}"
        cd -

    endtry

    call assert_match('failed to get remote', msgfile->readfile()->join("\n"))

    call assert_equal(buf_count_before, len(getbufinfo()))

    call delete(msgfile)
    call delete(file_c)
endf
