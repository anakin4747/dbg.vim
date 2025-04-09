


" repo local configs need to be stored in a file somewhere
"
" like have one file that stores the repos root dir in the first column and the
" second column is just the config vimscript dict

" TODO
" Given the current file, I want to be able to get the configuration stored in
" the internal storage for
function! GetConfig(cfg_dir, file)
    " Have the repo configs just be a list of all the previous settings
    "
    " They do not grow upon each other, they are independent
    "
    " Anytime it is started with new different args to the current repo config
    " then a new one is added to the beginning of the config
endf
