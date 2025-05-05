
function TestGetCallingFunc()
    let sfile = "<SNR>46_Dbg[2]..dbg#remote#get[1]..dbg#log#debug"
    let expected = "dbg#remote#get[1]"
    call assert_equal(expected, dbg#log#callingFunc(sfile))
endf

function TestGetCallingFuncCorrectsScriptScopedFuncs()
    let sfile = "<SNR>46_Dbg[2]..dbg#log#debug"
    let expected = "s:Dbg[2]"
    call assert_equal(expected, dbg#log#callingFunc(sfile))
endf
