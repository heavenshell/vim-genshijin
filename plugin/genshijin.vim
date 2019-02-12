let s:save_cpo = &cpo
set cpo&vim

command! -buffer -nargs=* -range=0 Genshijin call genshijin#run(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
