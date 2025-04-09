
function TestGetRemote()
    let expected = "https://github.com/anakin4747/dbg.vim"
    let actual = GetRemote(expand('test_GetRemote.vim:p'))
    call assert_equal(expected, actual)
endf
