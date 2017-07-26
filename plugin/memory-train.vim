if exists("g:loaded_memorytrain")
    finish
endif

" 获取num_randoms个[low, high)中的随机数
function s:SFRand(low, high, num_randoms)
let data = []
python << EOF
import numpy as np
import vim
l = vim.eval("a:low")
h = vim.eval("a:high")
n = vim.eval("a:num_randoms")
randoms = np.random.randint(int(l), int(h), int(n))
result = vim.bindeval('data')
result.extend(randoms)
EOF
return data
endfunction

let s:result = []
let s:SFCompute2Numbers = v:false

function s:SFCompute2Numbers()
    if len(s:result) > 0
        let s:result = []
        call execute("2,$normal dd")
    else
        call execute("edit GAME-计算式子的值")
        let line1 = "***** 计算下面式子的值 *****"
        call setline(1, line1)
    endif

    let num_to_method = [" + ", " - "]

    let num_tests = 1
    while num_tests <= 20
        let random_array = s:SFRand(100, 1000, 3)
        let method = random_array[0] % 2
        let rand_num1 = random_array[1]
        let rand_num2 = random_array[2]
        if rand_num1 < rand_num2
            let temp_number = rand_num1
            let rand_num1 = rand_num2
            let rand_num2 = temp_number
        endif

        let current_line = num_tests . ":\t"
        let current_line = current_line . string(rand_num1)
        let current_line = current_line . num_to_method[method]
        let current_line = current_line . string(rand_num2) . " ="
        call append(line('$'), current_line)
        let num_tests += 1

        " 保存计算结果
        if num_to_method[method] == " + "
            call add(s:result, rand_num1 + rand_num2)
        else
            call add(s:result, rand_num1 - rand_num2)
        endif
    endwhile
    let s:SFCompute2Numbers = v:true
endfunction


function s:SFCompute2NumbersCheck()
    if s:SFCompute2Numbers == v:false
        echo "请首先调用SFCompute2Numbers进行出题答题!"
        return
    endif

    let num_rights = 0
    " 对计算结果进行统计
    for i in range(2, 21)
        let current_line = getline(i)
        let begin_idx = stridx(current_line, "=")
        let str_value = strpart(current_line, begin_idx + 1)
        let value = str2nr(str_value)

        if value == get(s:result, i - 2)
            let current_line = current_line . "\tYES!"
            call setline(i, current_line)
            let num_rights += 1
        else
            let current_line = current_line . "\tNO!"
            call setline(i, current_line)
        endif
    endfor

    let output_list = []
    call add(output_list, "============================")
    call add(output_list, "========  统计结果 =========")
    call add(output_list, "============================")
    call add(output_list, "题目总数为\t\t" . string(20))
    call add(output_list, "做对题目数为\t" . string(num_rights))
    call add(output_list, "做对比例为\t\t" . string(num_rights * 1.0 / 20 * 100) . "%.")
    call append(line('$'), output_list)

    " 清理变量和buffer
    let s:result = []
    let s:SFCompute2Numbers = v:false
endfunction

if !hasmapto('<Plug>SFcompute')
map <unique> <leader>s <Plug>SFcompute
endif

" Note that instead of s:Add() we use <SID>Add() here.  That is because the
" mapping is typed by the user, thus outside of the script.  The <SID> is
" translated to the script ID, so that Vim knows in which script to look for
" the Add() function.
 
" This is a bit complicated, but it's required for the plugin to work together
" with other plugins.  The basic rule is that you use <SID>Add() in mappings and
" s:Add() in other places (the script itself, autocommands, user commands).

" Note: ":map <script>" and ":noremap <script>" do the same thing.  The
" "<script>" overrules the command name.  Using ":noremap <script>" is
" preferred, because it's clearer that remapping is (mostly) disabled.
 
noremap <unique> <script> <Plug>SFcompute <SID>SFcompute
noremap <SID>SFcompute :call <SID>SFCompute2Numbers()<CR>

let g:loaded_memorytrain = 1
