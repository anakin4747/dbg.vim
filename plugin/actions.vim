
function! s:GetMaxPid()
    " This will break for non linux but idc
    return '/proc/sys/kernel/pid_max'->readfile()[0]->str2nr()
endf

function! s:TryLaunch(args, cfg)
    let prog = get(a:args, 0, get(a:cfg, "program_path", ""))

    " Cannot use executable() since it searches $PATH
    if getfperm(prog) !~ '..x......'
        return
    endif

    let core = get(a:args, 1, get(a:cfg, "coredump_path", ""))
    if filereadable(core)
        return #{action: "launch", program_path: prog, coredump_path: core}
    endif

    if !empty(get(a:args, 1, ""))
        return #{action: "launch", program_path: prog, program_args: a:args[1:]}
    endif

    let cfg_args = get(a:cfg, "program_args", [])

    if !empty(cfg_args)
        return #{action: "launch", program_path: prog, program_args: cfg_args}
    endif

    return #{action: "launch", program_path: prog}
endf

function! s:TryAttachIP(args, cfg)
    let ip = get(a:args, 0, get(a:cfg, "ip", ""))

    if ip !~ '\v^(\d{1,3}\.){3}\d{1,3}$'
        return
    endif

    let port = str2nr(get(a:args, 1, get(a:cfg, "port", -1)))
    if port < 65535 && port > 0
        return #{action: "attach-ip", ip: ip, port: port}
    endif
    return #{action: "attach-ip", ip: ip}
endf

function! s:TryAttachPid(args, cfg)
    let pid = str2nr(get(a:args, 0, get(a:cfg, "pid", "-1")))

    if pid < s:GetMaxPid() && pid > 0
        return #{action: "attach-pid", pid: pid}
    endif
endf

function! s:TryAttachProc(args, cfg)
    let proc = get(a:args, 0, get(a:cfg, "proc", ""))

    try " Maybe we won't just want the first one in the future
        let pid = $"pgrep {proc}"->system()->split()[0]->str2nr()
    catch
        return
    endtry

    if pid < s:GetMaxPid() && pid > 0
        return #{action: "attach-pid", pid: pid, proc: proc}
    endif
endf

function! GetNextAction(cfg, args = "")
    if empty(a:cfg) && empty(a:args)
        return ""
    endif

    let args = split(a:args)

    for action_to_try in ['s:TryLaunch', 's:TryAttachIP', 's:TryAttachPid', 's:TryAttachProc']
        let action = call(action_to_try, [args, a:cfg])
        if !empty(action)
            return action
        endif
    endfor
endf

function! GetLastAction(config, filetype = &filetype) abort
    try
        let last_action = a:config[a:filetype].action_history[0]
    catch
        return {}
    endtry

    return last_action
endf

function! InsertNewAction(history, action_dict)
    let history = a:history->filter('v:val != a:action_dict')
    return history->insert(a:action_dict)
endf

function! SaveNewAction(action_dict, config_file = GetConfigFile(), filetype = &filetype)

    let config = GetOrInitConfig(a:config_file)

    if !has_key(config, a:filetype)
        let config[a:filetype] = {}
    endif

    if !has_key(config[a:filetype], 'action_history')
        let config[a:filetype].action_history = []
    endif

    let history = config[a:filetype].action_history

    if a:action_dict.action != 'attach-pid'
        let config[a:filetype].action_history = InsertNewAction(history, a:action_dict)
    endif

    try
        call writefile([json_encode(config)], a:config_file)
    catch
        call LogError($"Failed to write config: {config} to file: {a:config_file}")
        return
    endtry

    call LogDebug($"Successfully saved config: {config}")
endf
