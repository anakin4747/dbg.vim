
function TestGetConfigFile()
    let expected =
        \ $"{stdpath("data")}/dbg.vim/15/5080cad0a4d0966202d095e2e2962a32355a42318f347df3f8500678e94165"
    let actual = GetConfigFile("https://github.com/anakin4747/dbg.vim")
    call assert_equal(expected, actual)
endf

" You could mock the functions in GetConfig to be able to insert mock json and
" file permissions. mock json to handle bad json gracefully

" TODO: write update config logic
"
" This will be easy to write tests for
" hopefully

" Given a specific config file we will need to read and write to this file the
" config
" We will also need to add the list to the running config

"function TestUpdateConfig()
"
"    call UpdateConfig(config_file, action_dict)
"endf

function TestInsertNewAction()
    let expected = [#{action: "launch", program_path: "/bin/bash"}]
    let actual = InsertNewAction([], #{action: "launch", program_path: "/bin/bash"})
    call assert_equal(expected, actual)
endf

function TestMoveDuplicateActionToFront()
    let action_hist = [
        \ #{action: "launch", program_path: "/bin/bash"},
        \ #{action: "launch", program_path: "/bin/bash", program_args: ["-c", "ls"]},
        \ #{action: "attach-pid", pid: 31892},
        \]
    let new_action = #{action: "attach-pid", pid: 31892}
    let expected = [
        \ #{action: "attach-pid", pid: 31892},
        \ #{action: "launch", program_path: "/bin/bash"},
        \ #{action: "launch", program_path: "/bin/bash", program_args: ["-c", "ls"]},
        \]

    let actual = InsertNewAction(action_hist, new_action)
    call assert_equal(expected, actual)
endf

