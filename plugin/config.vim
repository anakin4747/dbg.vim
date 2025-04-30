function! CleanConfig()

    let config_file = GetConfigFile()

    if !filereadable(config_file)
        call LogInfo("No config file")
        return
    endif

    try
        call delete(config_file)
    catch
        call LogWarning("Failed to delete config")
    endtry
endf

function! GetOrInitConfig(file = GetConfigFile()) abort

    if filereadable(a:file)
        return a:file->readfile()->json_decode()
    endif

    call LogInfo($"No config file: creating empty config in {a:file}")

    let config = #{hist: [{}]}

    call mkdir(fnamemodify(a:file, ":p:h"), "p")

    call writefile([json_encode(config)], a:file)

    return config
endf

function! GetConfigFile(remote = GetRemote())
    let sha = sha256(a:remote)
    return $"{stdpath("data")}/dbg.vim/{sha[0:1]}/{sha[2:]}"
endf

function! InsertNewAction(history, action_dict)
    let history = a:history->filter('v:val != a:action_dict')
    return history->insert(a:action_dict)
endf

function! UpdateConfig(action_dict, config_file = GetConfigFile())

    let config = GetOrInitConfig(a:config_file)

    if a:action_dict.action != 'attach-pid'
        let config.hist = InsertNewAction(config.hist, a:action_dict)
    endif

    call writefile([json_encode(config)], a:config_file)
endf
