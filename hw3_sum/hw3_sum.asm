STKSGE SEGMENT PARA 'STACK'        ; 定义堆栈段，段名为STKSGE
           DB 256 DUP(0)    ; 分配256字节的堆栈空间
STKSGE ENDS

DATA SEGMENT                                                     ; 定义数据段，段名为DATA
    sum_in_data DW 0                                             ; 存储在数据段中的求和结果
    resultStr   DB 6 DUP(0)                                      ; 存储结果字符串的缓冲区
    msg1        DB 'Result stored in register: $'
    msg2        DB 0DH,0AH,'Result stored in data segment: $'
    msg3        DB 0DH,0AH,'Result stored in stack: $'
DATA ENDS

CODE SEGMENT                                               ; 定义代码段，段名为CODE
                     ASSUME CS:CODE, DS:DATA, SS:STKSGE

    START:           
    ; 初始化段寄存器
                     MOV    AX, DATA
                     MOV    DS, AX
                     MOV    AX, STKSGE
                     MOV    SS, AX
                     MOV    SP, 256                        ; 初始化堆栈指针SP到堆栈顶端

    ;-------------------------------
    ; 1. 结果存储在寄存器中
    ;-------------------------------
                     MOV    CX, 100                        ; 设置循环计数器为100
                     XOR    AX, AX                         ; 将AX清零，用于存储求和结果

    sum_reg_loop:    
                     ADD    AX, CX                         ; 将CX的值加到AX中
                     DEC    CX                             ; CX减1
                     JNZ    sum_reg_loop                   ; 如果CX不为零，继续循环

    ; 将AX中的sum转换为ASCII字符串
                     CALL   ConvertToStr                   ; 转换AX中的值为字符串，结果在resultStr中

    ; 显示消息和结果
                     LEA    DX, msg1
                     MOV    AH, 09H
                     INT    21H

                     LEA    DX, resultStr
                     MOV    AH, 09H
                     INT    21H

    ;-------------------------------
    ; 2. 结果存储在数据段中
    ;-------------------------------
                     MOV    WORD PTR [sum_in_data], 0      ; 将sum_in_data初始化为0
                     MOV    CX, 100                        ; 设置循环计数器为100

    sum_data_loop:   
                     ADD    WORD PTR [sum_in_data], CX     ; 将CX的值加到sum_in_data中
                     DEC    CX                             ; CX减1
                     JNZ    sum_data_loop                  ; 如果CX不为零，继续循环

                     MOV    AX, WORD PTR [sum_in_data]     ; 将sum_in_data的值加载到AX中
                     CALL   ConvertToStr                   ; 转换AX中的值为字符串，结果在resultStr中

    ; 显示消息和结果
                     LEA    DX, msg2
                     MOV    AH, 09H
                     INT    21H

                     LEA    DX, resultStr
                     MOV    AH, 09H
                     INT    21H

    ;-------------------------------
    ; 3. 结果存储在堆栈中
    ;-------------------------------
                     MOV    CX, 100                        ; 设置循环计数器为100
                     XOR    AX, AX                         ; 将AX清零，用于存储求和结果

    sum_stack_loop:  
                     ADD    AX, CX                         ; 将CX的值加到AX中
                     PUSH   CX                             ; 将CX压入堆栈（演示存储在堆栈中）
                     DEC    CX                             ; CX减1
                     JNZ    sum_stack_loop                 ; 如果CX不为零，继续循环

                     PUSH   AX                             ; 将求和结果AX压入堆栈

    ; 从堆栈中弹出求和结果到AX
                     POP    AX

    ; 清理堆栈（弹出之前压入的CX值）
                     MOV    CX, 100
    clean_stack_loop:
                     POP    DX                             ; 弹出堆栈中的值（此处不使用，弹出即可）
                     LOOP   clean_stack_loop               ; 循环直到堆栈清空

                     CALL   ConvertToStr                   ; 转换AX中的值为字符串，结果在resultStr中

    ; 显示消息和结果
                     LEA    DX, msg3
                     MOV    AH, 09H
                     INT    21H

                     LEA    DX, resultStr
                     MOV    AH, 09H
                     INT    21H

    ;-------------------------------
    ; 程序结束
    ;-------------------------------
                     MOV    AH, 4CH                        ; 正常结束程序
                     INT    21H

    ;-------------------------------------
    ; 子程序：ConvertToStr
    ; 将AX中的数值转换为ASCII字符串，存储在resultStr中
    ;-------------------------------------
ConvertToStr PROC
                     PUSH   AX
                     PUSH   BX
                     PUSH   CX
                     PUSH   DX
                     PUSH   SI
                     PUSH   DI                             ; 保存DI寄存器

                     LEA    SI, resultStr + 5              ; 指向resultStr的末尾
                     MOV    BYTE PTR [SI], '$'             ; 添加字符串结束符
                     DEC    SI                             ; 指向最后一个字符位置

                     MOV    BX, 10                         ; 设置除数为10

    ConvertLoop:     
                     XOR    DX, DX                         ; 清除DX
                     DIV    BX                             ; AX除以10
                     ADD    DL, '0'                        ; 将余数转换为ASCII字符
                     MOV    [SI], DL                       ; 存储字符
                     DEC    SI                             ; 前移一位
                     CMP    AX, 0
                     JNE    ConvertLoop

                     INC    SI                             ; SI指向字符串起始位置

    ; 计算字符串长度并复制到resultStr起始位置
                     LEA    DI, resultStr                  ; DI指向resultStr的起始位置
                     MOV    BX, OFFSET resultStr + 6       ; BX = resultStr的结束地址（包含终止符）
                     SUB    BX, SI                         ; BX = 字符串长度（包含终止符）
                     MOV    CX, BX                         ; CX = 字符串长度
                     REP    MOVSB                          ; 复制字符串

                     POP    DI                             ; 恢复DI寄存器
                     POP    SI
                     POP    DX
                     POP    CX
                     POP    BX
                     POP    AX
                     RET
ConvertToStr ENDP

CODE ENDS
    END START                        ; 程序结束，入口点为START
