
function! s:GetTestFuncs()
    return substitute(execute('function /^Test'), 'function \(\S*\)()[^\n]*\n\?', '\1\n', 'g')
endfunction

function! s:DeleteOldTests()
    for test in split(s:GetTestFuncs(), "\n")
        execute "delfunction ".test
    endfor
endfunction

command! DbgRunTests call DbgRunTests()

function! DbgRunTests()

    call s:DeleteOldTests()

    runtime! tests/test_*.vim

    let test_funcs = s:GetTestFuncs()

    let v:errors = []
    let v:errmsg = ""

    let passcount = 0
    let failcount = 0

    for test in split(test_funcs, "\n")
        execute $"silent call {test}()"

        if !empty(v:errors)
            echohl WarningMsg
            echomsg $"FAIL: {test}: {v:errors}"
            echohl None
            let v:errors = []
            let failcount += 1
        elseif !empty(v:errmsg)
            " For if an error is thrown
            echohl WarningMsg
            echomsg $"FAIL: {test}: {v:errmsg}"
            echohl None
            let v:errmsg = ""
            let failcount += 1
        else
            "echohl Title
            "echomsg $"PASS: {test}"
            "echohl None
            let passcount += 1
        endif
    endfor

    if failcount != 0
        echohl WarningMsg
        echomsg $"{failcount} TESTS FAILED"
        echohl None
    endif

    if passcount != 0
        echohl Title
        echomsg $"{passcount} TESTS PASSED"
        echohl None
    endif

endfunction
