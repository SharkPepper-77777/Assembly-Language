DATA SEGMENT
    MSG     DB 'The 9*9 table:', 0DH, 0AH, '$'
    NEWLINE DB 0DH, 0AH, '$'
    RES     DB 2 DUP(0)                           ; 用于存储乘积的各位数字
    SPACE2  DB '  $'                              ; 两个空格，字符串结束符
    SPACE3  DB '   $'                             ; 三个空格，字符串结束符
DATA ENDS

CODE SEGMENT
                        ASSUME CS:CODE, DS:DATA

    START:              
    ; 初始化数据段
                        MOV    AX, DATA
                        MOV    DS, AX

    ; 打印提示信息
                        LEA    DX, MSG
                        MOV    AH, 09H
                        INT    21H

    ; 初始化外层循环变量 i = 9
                        MOV    BL, 9

    OUTER_LOOP:         
                        CMP    BL, 0                  ; 判断是否 i == 0
                        JE     PROGRAM_END            ; 如果 i == 0，结束程序

    ; 初始化内层循环变量 j = BL（从 i 开始）
                        MOV    BH, BL

    INNER_LOOP:         
                        CMP    BH, 0                  ; 判断是否 j == 0
                        JE     PRINT_NEWLINE          ; 如果 j == 0，打印换行并进行下一次外层循环

    ; 打印 i
                        MOV    AL, BL
                        CALL   PRINT_DIGIT

    ; 打印 'x'
                        MOV    DL, 'x'
                        MOV    AH, 02H
                        INT    21H

    ; 打印 j
                        MOV    AL, BH
                        CALL   PRINT_DIGIT

    ; 打印 '='
                        MOV    DL, '='
                        MOV    AH, 02H
                        INT    21H

    ; 计算乘积 k = i * j
                        MOV    AL, BL
                        MUL    BH                     ; AX = i * j

    ; 打印乘积
                        CALL   PRINT_NUMBER

    ; 检查乘积是否为个位数
                        CMP    AX, 10
                        JL     SINGLE_DIGIT_RESULT

    ; 乘积是两位数，打印两个空格
                        LEA    DX, SPACE2
                        MOV    AH, 09H
                        INT    21H
                        JMP    CONTINUE_LOOP

    SINGLE_DIGIT_RESULT:
    ; 乘积是个位数，打印三个空格
                        LEA    DX, SPACE3
                        MOV    AH, 09H
                        INT    21H

    CONTINUE_LOOP:      
    ; 减少内层循环变量 j
                        DEC    BH
                        JMP    INNER_LOOP

    PRINT_NEWLINE:      
    ; 打印换行符
                        LEA    DX, NEWLINE
                        MOV    AH, 09H
                        INT    21H

    ; 减少外层循环变量 i
                        DEC    BL
                        JMP    OUTER_LOOP

    PROGRAM_END:        
                        MOV    AH, 4CH
                        INT    21H

    ; 子程序：PRINT_DIGIT
    ; 功能：打印 AL 中的数字（可能是两位数）
PRINT_DIGIT PROC NEAR
                        PUSH   AX
                        CMP    AL, 9
                        JG     PRINT_TWO_DIGIT

    ; 一位数处理
                        ADD    AL, '0'
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H
                        POP    AX
                        RET

    PRINT_TWO_DIGIT:    
    ; 处理两位数（10 到 99）
                        PUSH   BX
                        MOV    BX, 10
                        XOR    AH, AH
                        DIV    BL
                        ADD    AL, '0'                ; 十位
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H

                        MOV    AL, AH                 ; 个位
                        ADD    AL, '0'
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H

                        POP    BX
                        POP    AX
                        RET
PRINT_DIGIT ENDP

    ; 子程序：PRINT_NUMBER
    ; 功能：打印 AX 中的数值（0-81）
PRINT_NUMBER PROC NEAR
                        PUSH   AX
                        PUSH   BX
                        PUSH   CX
                        PUSH   DX

                        MOV    CX, 0                  ; 位数计数器
                        MOV    BX, 10                 ; 除数 10
                        MOV    SI, OFFSET RES + 2     ; 指向 RES 数组末尾

    CONVERT_LOOP:       
                        XOR    DX, DX
                        DIV    BX                     ; AX = AX / 10，DX = 余数
                        DEC    SI
                        ADD    DL, '0'                ; 将余数转换为字符
                        MOV    [SI], DL               ; 存储字符
                        INC    CX                     ; 位数加 1
                        CMP    AX, 0
                        JNE    CONVERT_LOOP

    ; 打印结果
    PRINT_DIGITS:       
                        MOV    DL, [SI]
                        MOV    AH, 02H
                        INT    21H
                        INC    SI
                        LOOP   PRINT_DIGITS

                        POP    DX
                        POP    CX
                        POP    BX
                        POP    AX
                        RET
PRINT_NUMBER ENDP

CODE ENDS
END START
