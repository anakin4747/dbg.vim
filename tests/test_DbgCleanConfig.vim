
function TestDbgCleanConfigCatchesNoFiletype()

    let buf_count_before = len(getbufinfo())
    let tmpfile = tempname()
    let filetype = &filetype
    set filetype=

    execute $"redir > {tmpfile}"

    try
        DbgCleanConfig
    finally
        redir END
        execute $"set filetype={filetype}"
    endtry

    call assert_match('no &filetype set', tmpfile->readfile()->join("\n"))

    let buf_count_after = len(getbufinfo())

    call assert_equal(buf_count_before, buf_count_after)

    call delete(tmpfile)

endf
