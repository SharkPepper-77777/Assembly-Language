STKSGE SEGMENT PARA 'STACK'        ; 定义堆栈段，段名为STACK
           DB 100 DUP('?')    ; 分配堆栈的大小，设置为100字节
STKSGE ENDS

DATA SEGMENT                    ; 定义数据段，段名为DATA
    MSG2    DB 'a', '$'         ; 初始化字符为 'a'
    NEWLINE DB 0DH, 0AH, '$'    ; 定义换行符
DATA ENDS

ASSUME CS:CODE,DS:DATA

CODE SEGMENT                  ; 定义代码段，段名为CODE
    START:
          MOV  AX, DATA       ; 加载数据段地址
          MOV  DS, AX         ; 设置数据段寄存器
            
          MOV  CX, 2          ; 外层循环计数（外层循环2次）
     
    L:                        ; 外层循环起始
          MOV  BX,CX          ; 保存外层循环的CX值
            
          MOV  CX, 13         ; 设置内层循环计数（每行打印13个字母）
            
    L1:                       ; 内层循环起始
          MOV  AH, 2          ; 设置打印字符功能
          MOV  AL, [MSG2]     ; 加载当前字符
          MOV  DL, AL         ; 将字符放入 DL 寄存器
          INT  21H            ; 调用 DOS 中断打印字符
          INC  AL             ; 增加 AL 中的字符（下一个字母）
          MOV  [MSG2], AL     ; 更新 MSG2 中的字符
        
          LOOP L1             ; 内层循环结束
            
    ; 打印换行符
          LEA  DX, NEWLINE    ; 加载换行符地址
          MOV  AH, 09H        ; 功能号：显示字符串
          INT  21H            ; DOS中断，显示字符串

          MOV  CX,BX          ; 恢复外层循环的CX值
          LOOP L              ; 外层循环结束

          MOV  AX, 4C00h      ; 终止程序
          INT  21H
CODE ENDS
END START
