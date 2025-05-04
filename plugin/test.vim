
function! s:GetTestFuncs()
    return execute('function /^Test')
            \ ->substitute('function \(\S*\)()[^\n]*\n\?', '\1\n', 'g')
            \ ->split("\n")
endfunction

function! s:DeleteOldTests()
    for test in s:GetTestFuncs()
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

    let test_errors = {}

    let passcount = 0
    let failcount = 0

    for test in test_funcs
        execute $"silent call {test}()"

        if !empty(v:errors)

            let test_errors[test] = v:errors
            let failcount += 1
        elseif !empty(v:errmsg)
            " For if an error is thrown
            let test_errors[test] = v:errmsg
            let failcount += 1
        else
            let passcount += 1
        endif

        let v:errors = []
        let v:errmsg = ""
    endfor


    if failcount
        echohl WarningMsg
        for [test, errs] in items(test_errors)
            echom $"FAIL: {test}:"
            for err in errs
                let match = matchlist(err, '\(line \d\+\): \(.*\)')
                echom $"  {match[1]}"
                echom $"    {match[2]}"
            endfor
            echom ""
        endfor

        echom $"{failcount} TESTS FAILED"
        echohl None
    endif

    if passcount
        echohl Title
        echom $"{passcount} TESTS PASSED"
        echohl None
    endif

endfunction
