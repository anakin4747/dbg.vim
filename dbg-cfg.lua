
return {
    -- keys are the filetype
    -- To see the current file's filetype `:echo &filetype`
    c = {
        gdb_default = true, -- Whether to use gdb by default instead of cmd
        cmd = "lldb", -- The command for another debugger and its arguments all in one string, no shell support
        gdb = "gdb", -- The command for gdb and its arguments all in one string, no shell support
    },
    python = {
        gdb_default = true,
        gdb = "gdb python",
        cmd = "debugpy",
    },
    rust = {
        gdb_default = true,
        cmd = "rust-lldb",
        gdb = "rust-gdb",
    },
    go = {
        gdb_default = false,
        cmd = "dlv debug",
        gdb = "gdb",
    },
}
