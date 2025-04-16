
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
