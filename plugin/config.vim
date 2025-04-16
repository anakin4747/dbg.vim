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

function! GetConfig(current_file)

    let config_file = a:current_file->GetRemote()->GetConfigFile()

    if !filereadable(config_file)
        return {}
    endif

    return json_decode(readfile(config_file))
endf

function! UpdateConfig(action_dict)

endf
