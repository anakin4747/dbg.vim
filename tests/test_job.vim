
function TestInitJobTermSucceeds()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = dbg#job#init('gdb', #{term: v:true})

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual), 'dbg#job#init did not return a dict')
    call assert_true(has_key(actual, 'pty'), 'dbg#job#init(term) did not return a pty')
    call assert_true(has_key(actual, 'buf'), 'dbg#job#init(term) did not return a buf')
    call assert_true(has_key(actual, 'win'), 'dbg#job#init(term) did not return a win')
    call assert_true(has_key(actual, 'job'), 'dbg#job#init(term) did not return a job')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " There should be one more buffer and one more window
    call assert_equal(buf_count_before, buf_count_after - 1,
                \ 'dbg#job#init(term) did not create a buffer')
    call assert_equal(win_count_before, win_count_after - 1,
                \ 'dbg#job#init(term) did not create a window')

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.job),
                \ 'dbg#job#init did not create a job')

    " Clean up
    execute $"silent! bwipeout! {actual.buf}"
endf

function TestInitJobPtySucceeds()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = dbg#job#init('tail -f /dev/null', #{pty: v:true})

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual), 'dbg#job#init did not return a dict')
    call assert_true(has_key(actual, 'pty'), 'dbg#job#init(pty) did not return a pty')
    call assert_true(has_key(actual, 'job'), 'dbg#job#init(pty) did not return a job')

    call assert_false(has_key(actual, 'buf'), 'dbg#job#init(pty) returned a buffer')
    call assert_false(has_key(actual, 'win'), 'dbg#job#init(pty) returned a window')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " There should not be a new buffer or window
    call assert_equal(buf_count_before, buf_count_after,
                \ 'dbg#job#init(pty) created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'dbg#job#init(pty) created a window')

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.job),
                \ 'dbg#job#init did not create a job')
endf

function TestInitJobFailedToGetJob()
    " Test that when JobCmd fails buffer state and window state is properly
    " restored

    function ReturnZero(cmd, opts)
        return 0
    endf

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = dbg#job#init('tail -f /dev/null', #{pty: v:true}, 'ReturnZero')

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal({}, actual, 'Failing dbg#job#init did not return an empty dict')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after dbg#job#init failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing dbg#job#init created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing dbg#job#init created a window')
endf

function TestInitJobFailedJobNotExecutable()

    function! ReturnNegOne(cmd, opts)
        return -1
    endf

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = dbg#job#init('tail -f /dev/null', #{pty: v:true}, 'ReturnNegOne')

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal({}, actual, 'Failing dbg#job#init did not return an empty dict')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after dbg#job#init failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing dbg#job#init created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing dbg#job#init created a window')
endf

function TestDeinitPtyJob()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let job_dict = dbg#job#init('tail -f /dev/null', #{pty: v:true})

    call DeinitJob(job_dict)

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal(0, jobstop(job_dict.job), 'Job was not stopped')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after dbg#job#init failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing dbg#job#init created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing dbg#job#init created a window')
endf

function TestDeinitTermJob()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let job_dict = dbg#job#init("gdb", #{term: v:true})

    call DeinitJob(job_dict)

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal(0, jobstop(job_dict.job), 'Job was not stopped')

    " The window before and after dbg#job#init should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after dbg#job#init failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing dbg#job#init created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing dbg#job#init created a window')
endf
