
function TestInitJobTermSucceeds()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = InitJob('gdb', #{term: v:true})

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual), 'InitJob did not return a dict')
    call assert_true(has_key(actual, 'pty'), 'InitJob(term) did not return a pty')
    call assert_true(has_key(actual, 'buf'), 'InitJob(term) did not return a buf')
    call assert_true(has_key(actual, 'win'), 'InitJob(term) did not return a win')
    call assert_true(has_key(actual, 'job'), 'InitJob(term) did not return a job')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " There should be one more buffer and one more window
    call assert_equal(buf_count_before, buf_count_after - 1,
                \ 'InitJob(term) did not create a buffer')
    call assert_equal(win_count_before, win_count_after - 1,
                \ 'InitJob(term) did not create a window')

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.job),
                \ 'InitJob did not create a job')

    " Clean up
    execute $"silent! bwipeout! {actual.buf}"
endf

function TestInitJobPtySucceeds()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = InitJob('tail -f /dev/null', #{pty: v:true})

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    " The dictionary should have all these fields
    call assert_equal(v:t_dict, type(actual), 'InitJob did not return a dict')
    call assert_true(has_key(actual, 'pty'), 'InitJob(pty) did not return a pty')
    call assert_true(has_key(actual, 'job'), 'InitJob(pty) did not return a job')

    call assert_false(has_key(actual, 'buf'), 'InitJob(pty) returned a buffer')
    call assert_false(has_key(actual, 'win'), 'InitJob(pty) returned a window')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " There should not be a new buffer or window
    call assert_equal(buf_count_before, buf_count_after,
                \ 'InitJob(pty) created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'InitJob(pty) created a window')

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.job),
                \ 'InitJob did not create a job')
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

    let actual = InitJob('tail -f /dev/null', #{pty: v:true}, 'ReturnZero')

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal({}, actual, 'Failing InitJob did not return an empty dict')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after InitJob failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing InitJob created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing InitJob created a window')
endf

function TestInitJobFailedJobNotExecutable()

    function! ReturnNegOne(cmd, opts)
        return -1
    endf

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let actual = InitJob('tail -f /dev/null', #{pty: v:true}, 'ReturnNegOne')

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal({}, actual, 'Failing InitJob did not return an empty dict')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after InitJob failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing InitJob created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing InitJob created a window')
endf

function TestDeinitPtyJob()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let job_dict = InitJob('tail -f /dev/null', #{pty: v:true})

    call DeinitJob(job_dict)

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal(0, jobstop(job_dict.job), 'Job was not stopped')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after InitJob failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing InitJob created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing InitJob created a window')
endf

function TestDeinitTermJob()

    let buf_count_before = len(getbufinfo())
    let win_count_before = len(nvim_list_wins())
    let win_before = win_getid()

    let job_dict = InitJob("gdb", #{term: v:true})

    call DeinitJob(job_dict)

    let buf_count_after = len(getbufinfo())
    let win_count_after = len(nvim_list_wins())
    let win_after = win_getid()

    call assert_equal(0, jobstop(job_dict.job), 'Job was not stopped')

    " The window before and after InitJob should be the same
    call assert_equal(win_before, win_after,
                \ 'The currently focused window has changed')
    " The window before and after InitJob failing should be the same
    call assert_equal(buf_count_before, buf_count_after,
                \ 'Failing InitJob created a buffer')
    call assert_equal(win_count_before, win_count_after,
                \ 'Failing InitJob created a window')
endf
