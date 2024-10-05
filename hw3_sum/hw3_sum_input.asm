STKSGE SEGMENT PARA 'STACK'        ; 定义堆栈段，段名为STACK
           DB 100 DUP('?')    ; 分配堆栈的大小，设置为100字节
STKSGE ENDS

DATA SEGMENT                                                           ; 定义数据段，段名为DATA
    buffer    DB 10 DUP(0)                                             ; 存储用户输入的缓冲区，最多10个字符
    message   DB 'Please input a number (press Enter to finish): $'
    newline   DB 13, 10, '$'
    resultMsg DB 13, 10, 'You entered: $'
    sumMsg    DB 13, 10, 'The sum from 1 to your number is: $'         ; 显示求和结果的消息
DATA ENDS

CODE SEGMENT                                            ; 定义代码段，段名为CODE
                  ASSUME CS:CODE, DS:DATA, SS:STKSGE
    START:        MOV    AX, DATA                       ; 初始化数据段
                  MOV    DS, AX                         ; 设置DS寄存器指向数据段

    ; 显示提示消息
                  LEA    DX, message
                  MOV    AH, 09H
                  INT    21H

    ; 初始化用于保存结果的寄存器
                  MOV    SI, 0                          ; SI 用于指向缓冲区
                  MOV    BX, 0                          ; BX 用于保存最终的数字

    INPUT_LOOP:   
    ; 获取单个字符输入
                  MOV    AH, 01H                        ; DOS 功能号 01H，读取一个字符
                  INT    21H
                  CMP    AL, 0DH                        ; 检测是否为回车符
                  JE     END_INPUT                      ; 如果是回车符，结束输入

                  SUB    AL, 30H                        ; 将 ASCII 字符转换为数值 ('0' -> 0, '1' -> 1, ...)
                  MOV    [SI + buffer], AL              ; 将转换后的数值存入缓冲区

    ; 将数字累加到寄存器BX中
                  MOV    AX, BX                         ; 将当前结果移动到AX
                  MOV    BX, 10                         ; 准备乘以10
                  MUL    BX                             ; AX = AX * 10
                  MOV    BX, AX                         ; 将乘积结果存入BX
                  MOV    AL, [SI + buffer]
                  MOV    AH, 0
                  ADD    BX, AX

                  INC    SI                             ; 缓冲区索引增加
                  JMP    INPUT_LOOP                     ; 循环输入

    END_INPUT:    
    ; 显示"你输入的是"的消息
                  LEA    DX, resultMsg
                  MOV    AH, 09H
                  INT    21H

    ; 输出用户输入的数字字符
                  MOV    CX, SI                         ; CX 保存输入的字符数
                  MOV    SI, 0                          ; 从缓冲区的开头开始输出

    PRINT_LOOP:   
                  CMP    CX, 0                          ; 检查是否输出完所有字符
                  JE     CALCULATE_SUM                  ; 如果没有字符要输出，跳转到求和

                  MOV    DL, [SI + buffer]              ; 获取缓冲区中的字符
                  ADD    DL, 30H                        ; 将数字转换回 ASCII 以便输出
                  MOV    AH, 02H                        ; DOS 功能号 02H，显示字符
                  INT    21H

                  INC    SI                             ; 指向下一个字符
                  DEC    CX                             ; 减少字符计数
                  JMP    PRINT_LOOP                     ; 返回循环继续输出

    CALCULATE_SUM:
    ; 计算从1到输入数字的和
                  LEA    DX, sumMsg
                  MOV    AH, 09H
                  INT    21H

                  MOV    AX, 0                          ; AX用于保存累加和
                  MOV    CX, BX                         ; CX保存用户输入的数字

    SUM_LOOP:     
                  ADD    AX, CX                         ; 将 CX（当前数字）加到 AX 中
                  LOOP   SUM_LOOP                       ; 循环直到 CX 减为 0

    ; 输出求和结果
                  CALL   PRINT_AX                       ; 输出累加和

    ; 结束程序
                  MOV    AH, 4CH
                  INT    21H

    ; 改进的数值转换和输出部分
    PRINT_AX:     
                  PUSH   AX                             ; 保存AX
                  PUSH   CX                             ; 保存CX
                  PUSH   DX                             ; 保存DX

                  MOV    CX, 0                          ; 用于计算字符数
                  LEA    DI, buffer                     ; 将DI指向缓冲区，用于存储字符串

    PRINT_LOOP_AX:
                  MOV    DX, AX                         ; 将AX中的值拷贝到DX
                  MOV    BX, 10                         ; 除以10
                  XOR    DX, DX                         ; 清除DX用于除法
                  DIV    BX                             ; AX / 10，商存入AX，余数存入DX
                  ADD    DL, '0'                        ; 将余数转换为ASCII字符
                  DEC    DI                             ; 移动到前一个缓冲区位置
                  MOV    [DI], DL                       ; 存储字符
                  INC    CX                             ; 计数增加
                  CMP    AX, 0                          ; 检查AX是否为0
                  JNZ    PRINT_LOOP_AX                  ; 如果AX不为0，继续

    ; 输出缓冲区中的数字字符
    OUTPUT_BUFFER:
                  MOV    AH, 02H                        ; DOS功能号 02H，显示字符
                  MOV    DL, [DI]                       ; 获取字符
                  INT    21H                            ; 显示字符
                  INC    DI                             ; 移动到下一个字符
                  DEC    CX                             ; 减少字符计数
                  JNZ    OUTPUT_BUFFER                  ; 如果还有字符，继续输出

                  POP    DX                             ; 恢复DX
                  POP    CX                             ; 恢复CX
                  POP    AX                             ; 恢复AX
                  RET

CODE ENDS

END START                          ; 汇编结束，段内程序起点为START
