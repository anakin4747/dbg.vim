
function TestInitJobInvalidWinId()
    let win_before = win_getid()
    let buf_count_before = len(getbufinfo())

    let actual = InitJob("gdb", #{pty: v:true}, -1)

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    call assert_equal({}, actual)
    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    " There should not be any buffers added as a side effect
    call assert_equal(buf_count_before, buf_count_after)
endf

function TestInitJobTermSucceeds()

    let win_before = win_getid()
    let buf_count_before = len(getbufinfo())

    let win = CreateWindow('tab')

    let actual = InitJob("gdb", #{term: v:true}, win)

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual))
    call assert_true(has_key(actual, 'pty'))
    call assert_true(has_key(actual, 'buf'))
    call assert_true(has_key(actual, 'win'))
    call assert_true(has_key(actual, 'job'))

    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    " There should be one more buffer
    call assert_equal(buf_count_before, buf_count_after - 1)

    call assert_equal(1, jobstop(actual.job))
    execute $"silent! bwipeout! {actual.buf}"
endf

function TestInitJobPtySucceeds()

    let win_before = win_getid()
    let buf_count_before = len(getbufinfo())

    let win = CreateWindow('tab')

    let actual = InitJob("gdb", #{pty: v:true}, win)

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual))
    call assert_true(has_key(actual, 'pty'))
    call assert_true(has_key(actual, 'win'))
    call assert_true(has_key(actual, 'job'))

    call assert_false(has_key(actual, 'buf'))

    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    " There should be one more buffer
    call assert_equal(buf_count_before, buf_count_after - 1)

    call assert_equal(1, jobstop(actual.job))
    execute $"silent! bwipeout! {nvim_win_get_buf(win)}"
endf

function TestInitJobFailedToGetJob()
    " Test that when JobCmd fails buffer state and window state is properly
    " restored

    function ReturnZero(cmd, opts)
        return 0
    endf

    let buf_count_before = len(getbufinfo())
    let win_before = win_getid()
    let win = CreateWindow('tab')

    let actual = InitJob("gdb", #{pty: v:true}, win, 'ReturnZero')

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    call assert_equal({}, actual)
    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    call assert_equal(buf_count_before, buf_count_after)
    " The window should be closed and no longer valid
    call assert_false(nvim_win_is_valid(win))
endf

function TestInitJobFailedJobNotExecutable()
    " Test that when JobCmd fails buffer state and window state is properly
    " restored
    function! ReturnNegOne(cmd, opts)
        return -1
    endf

    let win_before = win_getid()
    let buf_count_before = len(getbufinfo())
    let win = CreateWindow('tab')

    let actual = InitJob("gdb", #{pty: v:true}, win, 'ReturnNegOne')

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    call assert_equal({}, actual)
    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    " There should not be any buffers added as a side effect
    call assert_equal(buf_count_before, buf_count_after)
    " The window should be closed and no longer valid
    call assert_false(nvim_win_is_valid(win))
endf

function TestInitJobChanNoPty()

    function! ReturnNoPty(job)
        return #{buffer: 200}
    endf

    let win_before = win_getid()
    let buf_count_before = len(getbufinfo())
    let win = CreateWindow('tab')

    let actual = InitJob("gdb", #{pty: v:true}, win, 'jobstart', 'ReturnNoPty')

    let win_after = win_getid()
    let buf_count_after = len(getbufinfo())

    " Make sure InitJob returns the number of the failed job
    call assert_equal(v:t_number, type(actual), 'Job is not a number')
    call assert_equal(0, jobstop(actual), 'Job was not stopped')

    " The window before and after InitJob failing should be the same
    call assert_equal(win_before, win_after)
    " There should not be any buffers added as a side effect
    call assert_equal(buf_count_before, buf_count_after)
    " The window should be closed and no longer valid
    call assert_false(nvim_win_is_valid(win))
endf
