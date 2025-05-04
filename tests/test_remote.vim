
function TestGetRemote()
    let expected = "https://github.com/anakin4747/dbg.vim"
    let actual = GetRemote(expand('test_remote.vim:p'))
    call assert_equal(expected, actual,
                \ "Fails when not in dbg.vim root dir")
endf

function TestGetRemoteTerm()
    let expected = "https://github.com/anakin4747/dbg.vim"

    new | terminal

    try
        let actual = GetRemote(expand("%"))
        call assert_equal(expected, actual,
                    \ "Fails when not in dbg.vim root dir")
    catch
    finally
        bwipeout!
    endtry
endf

function TestGetRemoteHandlesDict()
    call assert_equal("", GetRemote({}))
endf

function TestGetRemoteHandlesNumber()
    call assert_equal("", GetRemote(0))
endf

function TestGetRemoteHandlesList()
    call assert_equal("", GetRemote([]))
endf

function TestGetRemoteTmpInput()
    let expected = "https://github.com/anakin4747/dbg.vim"
    let actual = GetRemote('/tmp/file')
    call assert_equal(expected, actual,
                \ "Fails when not in dbg.vim root dir")
endf

function TestGetRemoteOutsideGitRepoFails()
    cd
    call assert_equal("", GetRemote('/tmp/file'))
    cd -

endf
