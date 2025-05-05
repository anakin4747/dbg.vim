
function! dbg#cmd#build(action_dict, command, args)
    if empty(a:action_dict)
        return ""
    endif

    let action = get(a:action_dict, "action", "")
    if empty(action)
        return ""
    endif

    if action == "launch"
        let program_path = get(a:action_dict, "program_path", "")
        if empty(program_path)
            return ""
        endif

        let program_args = join(get(a:action_dict, "program_args", []))
        let coredump_path = get(a:action_dict, "coredump_path", "")

        " program_args and coredump_path are mutually exclusive this is an error
        if !empty(program_args) && !empty(coredump_path)
            return ""
        endif

        if !empty(program_args)
            return $"{a:command} {a:args} --args {program_path} {program_args}"
        endif

        if !empty(coredump_path)
            return $"{a:command} {a:args} {program_path} {coredump_path}"
        endif

        return $"{a:command} {a:args} {program_path}"

    " TODO
    "if other actions
    endif
endf
