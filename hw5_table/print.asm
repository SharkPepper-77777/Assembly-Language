assume cs:codesg, es:table

codesg segment
                      public show_table           ; 导出 show_table 使其可以在其他文件中引用
                      extrn  TABLE:byte           ; 使用 extrn 引入 TABLE 符号

show_table proc
    ; 初始化 ES 段寄存器指向 TABLE 段
                      mov    ax, seg TABLE
                      mov    es, ax
                      mov    si, offset TABLE     ; 将 TABLE 的偏移地址赋值给 SI

                      mov    cx, 21               ; 每行显示数据的行数
                      mov    di, 0B800h           ; 显存段地址（文本模式）

    display_loop:     
    ; 显示年份
                      mov    ax, es:[si]          ; 取出年份的前两个字节
                      call   display_word
                      mov    ax, es:[si+2]        ; 取出年份的后两个字节
                      call   display_word
                      call   display_space        ; 增加间隔

    ; 显示收入（32位）
                      mov    ax, es:[si+5]
                      mov    dx, es:[si+7]
                      call   display_dword
                      call   display_space

    ; 显示雇员数（16位）
                      mov    ax, es:[si+0Ah]
                      call   display_word
                      call   display_space

    ; 显示人均收入（16位）
                      mov    ax, es:[si+0Dh]
                      call   display_word

    ; 换行
                      call   display_newline
                      add    si, 10h              ; 每行数据占用16字节的table空间
                      loop   display_loop

                      ret
show_table endp

    ; 显示16位数字
display_word proc
                      push   ax
                      push   bx
                      push   cx
                      push   dx
                      push   di                   ; 保存显存指针

                      mov    cx, 5                ; 预留5位
                      mov    bx, 10

    convert_word_loop:
                      xor    dx, dx
                      div    bx                   ; 取余数（个位数）
                      add    dl, '0'              ; 转换为ASCII
                      push   dx                   ; 将ASCII字符入栈
                      dec    cx
                      test   ax, ax
                      jnz    convert_word_loop    ; 如果商不为0，继续分解

    show_word_digits: 
                      pop    dx                   ; 从栈中取出每一位字符
                      mov    ah, 0Eh              ; BIOS写字符函数
                      mov    bh, 0                ; 显存页号
                      mov    bl, 07h              ; 设置字符属性（白色）
                      int    10h                  ; 调用BIOS中断显示字符
                      add    di, 2                ; 移动显存指针
                      loop   show_word_digits

                      pop    di
                      pop    dx
                      pop    cx
                      pop    bx
                      pop    ax
                      ret
display_word endp

    ; 显示32位数字
display_dword proc
                      push   ax
                      push   dx
                      call   display_word         ; 调用 display_word 显示低16位
                      pop    ax
                      call   display_word         ; 显示高16位
                      ret
display_dword endp

    ; 显示间隔
display_space proc
                      mov    ah, 0Eh
                      mov    al, ' '
                      mov    bh, 0
                      mov    bl, 07h              ; 间隔颜色为白色
                      int    10h
                      ret
display_space endp

    ; 显示换行
display_newline proc
                      mov    ah, 0Eh
                      mov    al, 0Dh              ; 回车
                      int    10h
                      mov    al, 0Ah              ; 换行
                      int    10h
                      ret
display_newline endp

codesg ends
end show_table
