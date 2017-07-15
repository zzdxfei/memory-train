function Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

let s:result = []
let s:SFCompute2Numbers = v:false

function SFCompute2Numbers()
    if len(s:result) > 0
        let s:result = []
    endif

    let num_to_method = [" + ", " - "]
    call execute("edit GAME-计算式子的值")
    let line1 = "***** 计算下面式子的值 *****"
    call setline(1, line1)

    let num_tests = 1
    while num_tests <= 20
        let method = Rand() % 2
        let rand_num1 = Rand() % 900 + 100
        let rand_num2 = Rand() % 900 + 100
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


function SFCompute2NumbersCheck()
    " 对计算结果进行统计
    for i in range(2, 21)
        let current_line = getline(i)
        let begin_idx = stridx(current_line, "=")
        let str_value = strpart(current_line, begin_idx + 1)
        let value = str2nr(str_value)

        echo value
        if value == get(s:result, i - 2)
            let current_line = current_line . "\tYES!"
            call setline(i, current_line)
        else
            let current_line = current_line . "\tNO!"
            call setline(i, current_line)
        endif
    endfor

    
    " 清理变量和buffer
    let s:result = []
    let s:SFCompute2Numbers = v:false
    "call execute("1,$normal dd")
endfunction
