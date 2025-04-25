
function TestGetCallingFunc()
    let sfile = "<SNR>46_Dbg[2]..GetRemote[1]..LogDebug"
    let expected = "GetRemote[1]"
    call assert_equal(expected, GetCallingFunc(sfile))
endf

function TestGetCallingFuncCorrectsScriptScopedFuncs()
    let sfile = "<SNR>46_Dbg[2]..LogDebug"
    let expected = "s:Dbg[2]"
    call assert_equal(expected, GetCallingFunc(sfile))
endf
