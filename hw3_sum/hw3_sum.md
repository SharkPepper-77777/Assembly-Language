### 1. 在寄存器、数据段、栈中的汇编实现
#### 1.1 汇编代码概述
该汇编代码演示了如何在寄存器、数据段和堆栈中存储和处理数据。它首先对求和功能进行了三种不同存储方式的实现，分别是：

1. 寄存器存储：在寄存器`AX`中累加1到100的值。

2. 数据段存储：在数据段的变量`sum_in_data`中存储累加结果。
3. 堆栈存储：通过将中间结果压入堆栈并最终弹出，来计算1到100的累加和。

每种存储方式都通过`INT 21H`的系统调用将结果输出到屏幕，并通过`ConvertToStr`子程序将数值转换为字符串形式。

#### 1.2 关键代码与注释
- **寄存器存储：** 在寄存器中求和是通过循环将CX中的值累加到AX，直到CX变为0。

```assembly
MOV    CX, 100                        ; 设置循环计数器为100
XOR    AX, AX                         ; 将AX清零，用于存储求和结果
sum_reg_loop:    
    ADD    AX, CX                     ; 将CX的值加到AX中
    DEC    CX                         ; CX减1
    JNZ    sum_reg_loop               ; 如果CX不为零，继续循环
```
- **数据段存储：** 在数据段的变量sum_in_data中，累加操作与寄存器类似，只是结果存储在数据段中。

```assembly
MOV    WORD PTR [sum_in_data], 0      ; 将sum_in_data初始化为0
MOV    CX, 100                        ; 设置循环计数器为100
sum_data_loop:   
    ADD    WORD PTR [sum_in_data], CX ; 将CX的值加到sum_in_data中
    DEC    CX                         ; CX减1
    JNZ    sum_data_loop              ; 如果CX不为零，继续循环
```
- **堆栈存储：** 通过将每次循环的中间结果压入堆栈，在循环结束后，将结果从堆栈中弹出。
```assembly
MOV    CX, 100                        ; 设置循环计数器为100
XOR    AX, AX                         ; 将AX清零，用于存储求和结果
sum_stack_loop:  
    ADD    AX, CX                     ; 将CX的值加到AX中
    PUSH   CX                         ; 将CX压入堆栈
    DEC    CX                         ; CX减1
    JNZ    sum_stack_loop             ; 如果CX不为零，继续循环
```
### 2. 实现任意输入的汇编代码
#### 2.1 功能描述
该汇编代码扩展了用户输入的功能，允许用户输入一个数字，并计算从1到该数字的累加和。通过使用DOS中断`INT 21H`读取用户输入的字符，将其转换为数字并计算累加和，最后通过`INT 21H`显示结果。

#### 2.2 关键代码与注释
- **用户输入：** 使用DOS中断读取用户输入的字符，并将其从ASCII转换为实际数字。
```assembly
MOV    AH, 01H                        ; DOS 功能号 01H，读取一个字符
INT    21H
CMP    AL, 0DH                        ; 检测是否为回车符
JE     END_INPUT                      ; 如果是回车符，结束输入
```
- **累加和计算：** 使用CX存储用户输入的数字，并计算1到该数字的累加和。

```assembly
MOV    AX, 0                          ; AX用于保存累加和
MOV    CX, BX                         ; CX保存用户输入的数字
SUM_LOOP:     
    ADD    AX, CX                     ; 将 CX（当前数字）加到 AX 中
    LOOP   SUM_LOOP                   ; 循环直到 CX 减为 0
```
### 3.C语言代码

```c
#include<stdio.h>

int main()
{
    // 定义变量 sum 并初始化为 0，sum 用于保存 1 到 100 的累加和
    int sum = 0;

    // for 循环，从 i = 1 开始，一直循环到 i < 101（即 i <= 100）
    // 每次循环结束后，i 的值加 1
    for (int i = 1; i < 101; i++)
    {
        // 将当前的 i 值加到 sum 中，即 sum = sum + i
        sum += i;
    }

    // 打印结果 sum 的值
    // 在这里，%d 是格式化占位符，用来输出整数，sum 是要打印的值
    printf("%d", sum);

    // 返回 0，表示程序成功结束
    return 0;
}

```
#### 3.1.C语言代码反汇编精简后以及注释
```assembly
main:
    pushq   %rbp                    ; 保存旧的基址指针
    movq    %rsp, %rbp               ; 设置新的栈帧
    subq    $16, %rsp                ; 给局部变量分配栈空间

    movl    $0, -8(%rbp)             ; sum = 0
    movl    $1, -4(%rbp)             ; i = 1

.L2:                                 ; 循环开始
    cmpl    $100, -4(%rbp)           ; 比较 i 和 100
    jg      .L3                      ; 如果 i > 100，跳出循环

.L3:                                 ; 循环体
    movl    -4(%rbp), %eax           ; 将 i 加载到 eax 中
    addl    %eax, -8(%rbp)           ; sum += i
    addl    $1, -4(%rbp)             ; i++

    jmp     .L2                      ; 返回到循环判断

.L3:                                 ; 循环结束
    movl    -8(%rbp), %eax           ; 将 sum 加载到 eax
    movl    %eax, %esi               ; sum 是 printf 的第一个参数
    leaq    .LC0(%rip), %rax         ; 加载格式化字符串 "%d"
    movq    %rax, %rdi               ; printf 的第二个参数
    call    printf@PLT               ; 调用 printf 函数

    movl    $0, %eax                 ; 返回值为 0
    leave                            ; 恢复栈帧
    ret                              ; 返回

```