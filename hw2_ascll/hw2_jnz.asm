DATA SEGMENT
    NEWLINE DB 0DH, 0AH    ; 定义换行符 (回车和换行)
    MSG2    DB 'a'         ; 定义初始字符 'a'
DATA ENDS

ASSUME CS:CODE, DS:DATA

CODE SEGMENT
    START:       
                 MOV AX, DATA        ; 将数据段地址加载到 AX
                 MOV DS, AX          ; 设置数据段寄存器

                 MOV CX, 26          ; 设置总循环次数为26 (打印26个字母)
                 MOV AH, 2           ; 设置功能号，显示字符
                 MOV BX, 13          ; 设置每行输出13个字符的计数器

    L1:          
                 MOV AL, [MSG2]      ; 加载 MSG2 中的字符 ('a')
                 MOV DL, AL          ; 将字符存储到 DL (用于显示)
                 INT 21H             ; 调用 DOS 中断，显示 DL 中的字符

                 INC AL              ; 将 AL 中的字符加1 ('a' -> 'b')
                 MOV [MSG2], AL      ; 将加1后的字符存回 MSG2

                 DEC BX              ; 每行计数器递减
                 JNZ SKIP_NEWLINE    ; 如果还未到13个字符，跳过换行

    ; 输出换行符
                 MOV DL, 0DH         ; 输出回车 (CR)
                 INT 21H             ; 调用 DOS 中断

                 MOV DL, 0AH         ; 输出换行 (LF)
                 INT 21H             ; 调用 DOS 中断

                 MOV BX, 13          ; 重置每行计数器

    SKIP_NEWLINE:
                 DEC CX              ; 总计数器递减
                 JNZ L1              ; 如果总计数器不为0，继续循环

                 MOV AX, 4C00H       ; 结束程序
                 INT 21H             ; 调用 DOS 中断，返回操作系统

CODE ENDS
    END START
