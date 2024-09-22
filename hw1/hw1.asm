STKSGE SEGMENT PARA 'STACK'            ;定义堆栈段，段名为STACK
             DB 100 DUP('?')      ;分配堆栈的大小，设置为100字节
STKSGE ENDS
DATA SEGMENT                               ;定义数据段，段名为DATA
           STRING DB'Hello World','$'      ;定义字符串数据
DATA ENDS
CODE SEGMENT                                        ;定义代码段，改名为CODE
            ASSUME CS:CODE, DS:DATA, SS:STKSGE
      START:MOV    AX, DATA                         ;程序执行起始点
            MOV    DS, AX                           ;将数据段地址寄存器指向用户数据段
            MOV    AX, STKSGE
            MOV    SS, AX                           ;将堆栈段地址寄存器指向用户堆栈段
            LEA    DX, STRING
            MOV    AH, 09H
            INT    21H                              ;系统调试功能，在显示器上显示字符串
            MOV    AH, 4CH
            INT    21H                              ;系统调试功能，程序结束返回操作系统
CODE ENDS
        END  START               ;汇编结束，段内程序起点为START