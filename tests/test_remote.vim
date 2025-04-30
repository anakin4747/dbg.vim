
function TestGetRemote()
    let expected = "https://github.com/anakin4747/dbg.vim"
    let actual = GetRemote(expand('test_remote.vim:p'))
    call assert_equal(expected, actual,
                \ "Fails when not in dbg.vim root dir")
endf

function TestGetRemoteTerm()
    let expected = "https://github.com/anakin4747/dbg.vim"

    new | terminal

    let actual = GetRemote(expand("%"))
    call assert_equal(expected, actual,
                \ "Fails when not in dbg.vim root dir")
    bwipeout!
endf

function TestGetRemoteHandlesBadArgs()
    let expected = ""
    let actual = GetRemote({})
    call assert_equal(expected, actual)

    let actual = GetRemote(0)
    call assert_equal(expected, actual)

    let actual = GetRemote([])
    call assert_equal(expected, actual)
endf

function TestGetRemoteTmpInput()
    let expected = "https://github.com/anakin4747/dbg.vim"
    let actual = GetRemote('/tmp/file')
    call assert_equal(expected, actual,
                \ "Fails when not in dbg.vim root dir")
endf

function TestGetRemoteOutsideGitRepoFails()
    cd
    let actual = GetRemote('/tmp/file')
    cd -

    call assert_equal("", actual)
endf
