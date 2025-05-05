
function TestGetConfigFile()
    let expected =
        \ $"{stdpath("data")}/dbg.vim/15/5080cad0a4d0966202d095e2e2962a32355a42318f347df3f8500678e94165"
    let actual = dbg#config#file("https://github.com/anakin4747/dbg.vim")
    call assert_equal(expected, actual)
endf
