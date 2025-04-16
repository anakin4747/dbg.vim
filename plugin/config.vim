" Have the repo configs just be a list of all the previous settings
"
" They do not grow upon each other, they are independent
"
" Anytime it is started with new different args to the current repo config
" then a new one is added to the beginning of the config

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

    let config.hist = InsertNewAction(config.hist, a:action_dict)

    call writefile([json_encode(config)], a:config_file)

    echo a:config_file->readfile()->json_decode()
endf
