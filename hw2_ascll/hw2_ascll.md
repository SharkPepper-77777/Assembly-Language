### 1.LOOP嵌套循环打印

LOOP嵌套循环使用CX寄存器进行打印操作。在使用嵌套循环时，需要确保外循环和内循环的CX值不会互相干扰，因此外循环的CX值在进入内循环时需要保存在另一个寄存器中，内循环完成后再恢复外循环的CX值。

#### 1.1.LOOP循环打印代码以及注释

```assembly
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

```

### 2.条件跳转指令打印

条件跳转指令的运用能更灵活地控制程序的流程。以下代码演示了如何使用条件跳转指令完成类似的ASCII字符输出，并且在每输出13个字符后进行换行操作。

#### 2.1.条件跳转指令打印代码以及注释

```assembly
DATA SEGMENT
    NEWLINE DB 0DH, 0AH                     ; 定义换行符 (回车和换行)
    MSG2    DB 'a'                          ; 定义初始字符 'a'
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
```

### 3.C语言代码

相比于汇编语言，C语言更为高级，处理字符输出和换行相对简单。以下C语言代码实现了同样的ASCII小写字母输出功能，每行输出13个字符。

```c
#include <stdio.h>
int main() {
    char letter = 'a'; // 初始字母为 'a'

    // 使用循环输出26个小写字母
    for (int i = 0; i < 26; i++) {
        printf("%c", letter); // 输出当前字母
        letter++; // 递增字母

        // 每输出13个字母后，换行
        if ((i + 1) % 13 == 0) {
            printf("\n");
        }
    }
    return 0;
}

```

#### 3.1.C语言代码反汇编以及注释

```assembly
0000000000001149 <main>:
    1149:	f3 0f 1e fa          	endbr64                   ; 指令流防护（ENDBR64），用于硬件控制流保护（针对跳转或返回到错误的地方的攻击）
    114d:	55                   	push   %rbp               ; 保存栈帧基址（保存旧的 %rbp）
    114e:	48 89 e5             	mov    %rsp,%rbp          ; 设置新的栈帧基址（%rbp = %rsp）
    1151:	48 83 ec 10          	sub    $0x10,%rsp         ; 为局部变量分配16字节的空间（减小 %rsp）
    
    ; 初始化局部变量 'letter' 和 循环计数器 'i'
    1155:	c6 45 fb 61          	movb   $0x61,-0x5(%rbp)   ; 将ASCII码 'a'（0x61）存入局部变量（%rbp-5），即 letter = 'a'
    1159:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)    ; 初始化循环计数器 'i' 为 0（%rbp-4 = 0）

    ; 跳转到循环开始处
    1160:	eb 56                	jmp    11b8 <main+0x6f>   ; 跳转到循环条件检查的位置

    ; 主循环开始，逐个打印字母
    1162:	0f be 45 fb          	movsbl -0x5(%rbp),%eax   ; 加载 letter 的值到 %eax（sign-extend 1-byte to 32-bit）
    1166:	89 c7                	mov    %eax,%edi          ; 将字母值传递到 %edi（传递给 putchar 的第一个参数）
    1168:	e8 e3 fe ff ff       	call   1050 <putchar@plt> ; 调用 `putchar` 函数，输出一个字符

    ; 更新字母
    116d:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax   ; 从局部变量加载字母的值到 %eax（zero-extend 1-byte to 32-bit）
    1171:	83 c0 01             	add    $0x1,%eax          ; 将字母加1，准备打印下一个字母
    1174:	88 45 fb             	mov    %al,-0x5(%rbp)     ; 将更新后的字母存回局部变量（letter = letter + 1）

    ; 检查是否需要换行（每13个字符换行）
    1177:	8b 45 fc             	mov    -0x4(%rbp),%eax    ; 加载循环计数器 i
    117a:	8d 48 01             	lea    0x1(%rax),%ecx     ; i + 1
    117d:	48 63 c1             	movslq %ecx,%rax          ; 将 %ecx sign-extend 到 %rax
    1180:	48 69 c0 4f ec c4 4e 	imul   $0x4ec4ec4f,%rax,%rax ; 乘法计算（用于处理换行判断）
    1187:	48 c1 e8 20          	shr    $0x20,%rax         ; 将 %rax 右移32位
    118b:	c1 f8 02             	sar    $0x2,%eax          ; 算术右移2位
    118e:	89 ce                	mov    %ecx,%esi          ; 将 %ecx 的值保存到 %esi
    1190:	c1 fe 1f             	sar    $0x1f,%esi         ; 算术右移31位，符号扩展
    1193:	29 f0                	sub    %esi,%eax          ; i = i - (i >> 31)
    1195:	89 c2                	mov    %eax,%edx          ; 保存结果到 %edx
    1197:	89 d0                	mov    %edx,%eax          ; 将 %edx 复制到 %eax
    1199:	01 c0                	add    %eax,%eax          ; %eax = 2 * %eax
    119b:	01 d0                	add    %edx,%eax          ; %eax = %eax + %edx
    119d:	c1 e0 02             	shl    $0x2,%eax          ; 左移2位
    11a0:	01 d0                	add    %edx,%eax          ; %eax = %eax + %edx
    11a2:	29 c1                	sub    %eax,%ecx          ; %ecx = %ecx - %eax
    11a4:	89 ca                	mov    %ecx,%edx          ; 将结果存入 %edx

    ; 检查是否达到换行条件
    11a6:	85 d2                	test   %edx,%edx          ; 检查 %edx 是否为0
    11a8:	75 0a                	jne    11b4 <main+0x6b>   ; 如果不是 0，跳转到 11b4，继续下一个字符

    ; 打印换行符
    11aa:	bf 0a 00 00 00       	mov    $0xa,%edi          ; 将换行符 '\n' 的ASCII码（0x0A）传递给 %edi
    11af:	e8 9c fe ff ff       	call   1050 <putchar@plt> ; 调用 `putchar` 输出换行符

    ; 更新循环计数器 i
    11b4:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)    ; i++

    ; 检查是否已经打印完26个字符
    11b8:	83 7d fc 19          	cmpl   $0x19,-0x4(%rbp)   ; 检查 i 是否小于 26
    11bc:	7e a4                	jle    1162 <main+0x19>   ; 如果 i <= 25，跳转到 1162，继续循环

    ; 返回0，结束程序
    11be:	b8 00 00 00 00       	mov    $0x0,%eax          ; 返回值设为 0
    11c3:	c9                   	leave                     ; 恢复栈帧（%rsp = %rbp，pop %rbp）
    11c4:	c3                   	ret                       ; 返回
```

