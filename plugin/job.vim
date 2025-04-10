
function! CreateWindow(location = '')
    let initial = win_getid()

    if a:location == 'tab'
        tabnew
        let new = win_getid()
        call nvim_set_current_win(initial)
        return new
    endif

    if a:location == 'vertical'
        vertical new
        let new = win_getid()
        call nvim_set_current_win(initial)
        return new
    endif

    new
    let new = win_getid()
    call nvim_set_current_win(initial)
    return new
endf

" On success returns a dict with required info
" On failure returns empty dict or job id
function! InitJob(cmd, opts, win,
            \ f_jobstart = 'jobstart', f_chan_info = 'nvim_get_chan_info')


    let initial_win = win_getid()

    try
        call nvim_set_current_win(a:win)
    catch
        return {}
    endtry

    let job = call(a:f_jobstart, [a:cmd, a:opts])
    if job <= 0
        echohl WarningMsg
        echo 'Failed to open the program terminal window'
        echohl None
        execute $"bwipeout {nvim_win_get_buf(a:win)}"
        call nvim_set_current_win(initial_win)
        return {}
    endif

    let info = call(a:f_chan_info, [job])

    let pty = get(info, 'pty', '')
    if empty(pty)
        execute $"bwipeout {nvim_win_get_buf(a:win)}"
        call jobstop(job)
        call nvim_set_current_win(initial_win)
        " Return job id on failure to be able to test that the job does not
        " exist
        return job
    endif

    let buf = get(info, 'buffer', -1)
    if buf < 0
        call nvim_set_current_win(initial_win)
        return #{pty: pty, win: a:win, job: job}
    endif

    call nvim_set_current_win(initial_win)
    return #{pty: pty, buf: buf, win: a:win, job: job}
endf
