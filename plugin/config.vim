function! CleanConfig(config_file)
    try
        call delete(a:config_file)
    endtry
endf

function! GetConfig()
    return "%"->expand()->GetRemote()->GetConfigFile()->readfile()->json_decode()
endf

function! GetConfigFile(remote)
    let sha = sha256(a:remote)
    return $"{stdpath("data")}/dbg.vim/{sha[0:1]}/{sha[2:]}"
endf

function! InsertNewAction(history, action_dict)
    let history = a:history->filter('v:val != a:action_dict')
    return history->insert(a:action_dict)
endf

function! UpdateConfig(config_file, action_dict)

    if filereadable(a:config_file)
        let config = a:config_file->readfile()->json_decode()
    else
        let config = #{hist: []}
    endif

    if a:action_dict.action != 'attach-pid'
        let config.hist = InsertNewAction(config.hist, a:action_dict)
    endif

    call writefile([json_encode(config)], a:config_file)

    echo a:config_file->readfile()->json_decode()
endf
