
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

function! DeinitJob(job_dict)
    if a:job_dict->has_key('win')
        execute $"silent! bwipeout! {nvim_win_get_buf(a:job_dict.win)}"
    endif
    if a:job_dict->has_key('job')
        call jobstop(a:job_dict.job)
    endif
endf

" On success returns a dict with required info
" On failure returns empty dict
function! InitJob(cmd, opts, jobstart = 'jobstart')

    let job_dict = {}

    let initial_win = win_getid()

    if has_key(a:opts, 'term') && a:opts.term
        let win_loc = get(a:opts, 'location', '')
        let win = CreateWindow(win_loc)
        call nvim_set_current_win(win)
        call extend(job_dict, #{win: win})
    endif

    let job = call(a:jobstart, [a:cmd, a:opts])
    if job <= 0
        call LogError('Failed to open the program terminal window')
        if exists('win')
            execute $"silent! bwipeout! {nvim_win_get_buf(job_dict['win'])}"
        endif
        call nvim_set_current_win(initial_win)
        return {}
    endif

    let info = nvim_get_chan_info(job)

    let buf = get(info, 'buffer', -1)
    if buf > 0
        call extend(job_dict, #{buf: buf})
    endif

    call extend(job_dict, #{pty: info['pty'], job: job})

    call nvim_set_current_win(initial_win)
    return job_dict
endf
