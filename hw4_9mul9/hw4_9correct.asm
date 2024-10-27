DATA SEGMENT
    ; 定义带有错误的 9x9 乘法表数据
    TABLE       DB 7,2,3,4,5,6,7,8,9            ;9*9表数据
                DB 2,4,7,8,10,12,14,16,18
                DB 3,6,9,12,15,18,21,24,27
                DB 4,8,12,16,7,24,28,32,36
                DB 5,10,15,20,25,30,35,40,45
                DB 6,12,18,24,30,7,42,48,54
                DB 7,14,21,28,35,42,49,56,63
                DB 8,16,24,32,40,48,56,7,72
                DB 9,18,27,36,45,54,63,72,81

    ERROR_LABEL DB 'x  y', 0DH, 0AH, '$'        ; 表头 "x  y"
    ERROR_TEXT  DB 'error', 0DH, 0AH, '$'       ; 错误提示 "error"
DATA ENDS

CODE SEGMENT
                        ASSUME CS:CODE, DS:DATA

    START:              
    ; 初始化数据段
                        MOV    AX, DATA
                        MOV    DS, AX

    ; 打印表头
                        LEA    DX, ERROR_LABEL
                        MOV    AH, 09H
                        INT    21H

    ; 外层循环变量 i，从 1 到 9
                        MOV    BL, 1                  ; BL = i

    CHECK_ROW:          
                        CMP    BL, 10
                        JGE    END_PROGRAM            ; 如果 i > 9，结束程序

    ; 内层循环变量 j，从 1 到 9
                        MOV    BH, 1                  ; BH = j

    CHECK_COLUMN:       
                        CMP    BH, 10
                        JGE    NEXT_ROW               ; 如果 j > 9，进入下一行

    ; 计算在 TABLE 中的索引
    ; index = (i - 1) * 9 + (j - 1)
                        MOV    DL, BL
                        DEC    DL                     ; DL = i - 1
                        MOV    DH, BH
                        DEC    DH                     ; DH = j - 1

                        MOV    AL, DL                 ; AL = i - 1
                        MOV    CL, 9
                        MUL    CL                     ; AX = (i - 1) * 9

    ; 将 DH 扩展为 16 位，再相加
                        MOV    CX, 0                  ; 清零 CX
                        MOV    CL, DH                 ; CX = (j - 1)
                        ADD    AX, CX                 ; AX = (i - 1) * 9 + (j - 1)

    ; 获取存储的值
                        MOV    SI, OFFSET TABLE
                        ADD    SI, AX                 ; SI = TABLE + index
                        MOV    CL, [SI]               ; CL = 存储的值

    ; 现在，计算期望的结果：AL = i * j
                        MOV    AL, BL                 ; AL = i
                        MUL    BH                     ; AX = i * j

    ; 比较存储的值和期望的结果
                        CMP    CL, AL
                        JE     NEXT_ELEMENT           ; 如果相等，检查下一个

    ; 发现错误，准备调用 DISPLAY_ERROR
                        MOV    DL, BL                 ; DL = i
                        MOV    DH, BH                 ; DH = j

    ; 保存寄存器并调用过程
                        PUSH   AX
                        PUSH   BX
                        PUSH   CX
                        PUSH   DX
                        PUSH   SI

                        CALL   DISPLAY_ERROR

    ; 恢复寄存器
                        POP    SI
                        POP    DX
                        POP    CX
                        POP    BX
                        POP    AX

    NEXT_ELEMENT:       
                        INC    BH                     ; j = j + 1
                        JMP    CHECK_COLUMN

    NEXT_ROW:           
                        INC    BL                     ; i = i + 1
                        JMP    CHECK_ROW

    END_PROGRAM:        
                        MOV    AH, 4CH
                        INT    21H

    ; 过程：DISPLAY_ERROR
    ; 功能：显示错误的位置和 "error" 提示
DISPLAY_ERROR PROC NEAR
    ; 输入：
    ; DL = i
    ; DH = j

    ; 显示 x 坐标
                        MOV    AL, DL
                        CALL   PRINT_NUMBER_AL

    ; 显示空格
                        MOV    DL, ' '
                        MOV    AH, 02H
                        INT    21H

    ; 显示 y 坐标
                        MOV    AL, DH
                        CALL   PRINT_NUMBER_AL

    ; 显示 "error"
                        LEA    DX, ERROR_TEXT
                        MOV    AH, 09H
                        INT    21H

                        RET
DISPLAY_ERROR ENDP

    ; 过程：PRINT_NUMBER_AL
    ; 功能：将 AL 中的数字转换为字符串并显示
PRINT_NUMBER_AL PROC NEAR
                        PUSH   AX
                        PUSH   DX

                        CMP    AL, 10
                        JL     PRINT_SINGLE_DIGIT

    ; 两位数处理
                        MOV    AH, 0
                        MOV    BL, 10
                        DIV    BL                     ; AL = 商（十位），AH = 余数（个位）

    ; 显示十位
                        ADD    AL, '0'
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H

    ; 显示个位
                        MOV    AL, AH
                        ADD    AL, '0'
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H

                        JMP    PRINT_NUMBER_AL_END

    PRINT_SINGLE_DIGIT: 
    ; 一位数处理
                        ADD    AL, '0'
                        MOV    DL, AL
                        MOV    AH, 02H
                        INT    21H

    PRINT_NUMBER_AL_END:
                        POP    DX
                        POP    AX
                        RET
PRINT_NUMBER_AL ENDP

CODE ENDS
END START
