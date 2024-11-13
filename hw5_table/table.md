### hw5_table文档

本汇编程序由两个主要文件`table.asm`和`print.asm`构成，分别负责数据的初始化和显示。`table.asm`文件将所需的年度数据、收入和雇员信息填充至表格段`table`中，而`print.asm`负责将表格数据逐行读取并显示到屏幕上。以下将详细介绍这两个文件的内容和实现过程。

------

### 1. 文件：`table.asm`

#### 功能概述

`table.asm`的主要功能是将年份、总收入、雇员人数和人均收入的数据初始化到一个公共段`table`中，以便`print.asm`文件进行显示处理。

#### 主要代码说明

1. **数据段定义 (`data segment`)**

   - 包含年份、总收入和雇员数的数据，从1975年到1995年共21个数据点。

   - 数据定义如下：

     ```assembly
     assembly复制代码data segment
         years  db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
                db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
                db '1993','1994','1995'
     
         salary dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
                dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
     
         emp    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
                dw 11542,14430,45257,17800
     data ends
     ```

2. **表格段定义 (`table segment`)**

   - 设定一个公共的`table`段，以便`print.asm`文件引用，分配21行，每行16字节的空间，用于存放每年数据。

   - 段定义如下：

     ```assembly
     assembly复制代码table segment PUBLIC
         db 21 dup (0)    ; 每行16字节
     table ends
     ```

3. **代码段 (`codesg segment`)**

   - 将数据按顺序填充到

     ```assembly
     table
     ```

     段的指定位置，按以下步骤进行：

     - **年份填充**：按字节填充4位年份。
     - **收入填充**：将32位的收入数据分为低16位和高16位填充。
     - **雇员数填充**：将雇员人数填入。
     - **人均收入计算和填充**：计算总收入除以雇员人数的人均收入，填入`table`段。

   - 初始化代码如下：

     ```assembly
     assembly复制代码start:
         mov   ax, data
         mov   ds, ax
         mov   ax, table
         mov   es, ax
         mov   cx, 21                 ; 共 21 行数据
     
     init_table:
         ; 填充年份
         mov   ax, ds:[bp]
         mov   es:[si], ax
         add   si, 2
         mov   ax, ds:[bp+2]
         mov   es:[si], ax
         add   si, 3                  ; 空格
     
         ; 填充收入（32 位）
         mov   di, offset salary
         mov   ax, ds:[bp+di]
         mov   es:[si], ax
         add   si, 2
         mov   ax, ds:[bp+di+2]
         mov   es:[si], ax
         add   si, 3
     
         ; 填充雇员数
         mov   di, offset emp
         mov   ax, ds:[bx+di]
         mov   es:[si], ax
         add   si, 3
     
         ; 计算并填充人均收入
         mov   di, offset salary
         mov   ax, ds:[bp+di]
         mov   dx, ds:[bp+di+2]
         mov   di, offset emp
         div   word ptr ds:[bx+di]
         mov   es:[si], ax
         add   si, 3
         add   bp, 4
         add   bx, 2
         loop  init_table
     ```

4. **调用打印过程**

   - 数据填充完成后，调用`print.asm`中的`start_print`过程，启动打印。

------

### 2. 文件：`print.asm`

#### 功能概述

`print.asm`的功能是从`table`段读取数据，并将其格式化显示。每行显示的内容包括年份、收入、雇员数和人均收入。

#### 主要代码说明

1. **初始化段寄存器和显示循环**

   - 将`es`寄存器指向`table`段，`si`指向数据的起始位置。
   - 使用`display_loop`循环逐行读取数据，并调用不同的显示过程进行格式化输出。

   ```assembly
   assembly复制代码show_table proc
       mov    ax, seg TABLE
       mov    es, ax
       mov    si, offset TABLE
       mov    cx, 21
   
   display_loop:
       ; 显示年份
       mov    ax, es:[si]
       call   display_word
       mov    ax, es:[si+2]
       call   display_word
       call   display_space
   
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
       add    si, 10h
       loop   display_loop
   
       ret
   show_table endp
   ```

2. **显示数字的子过程**

   - `display_word`：用于显示16位数据，通过转换为ASCII码并调用BIOS中断显示字符。
   - `display_dword`：用于显示32位数据，先显示低16位，再显示高16位。
   - `display_space`：用于显示空格。
   - `display_newline`：用于换行。

   其中`display_word`代码如下：

   ```assembly
   assembly复制代码display_word proc
       push   ax
       push   bx
       push   cx
       push   dx
       mov    cx, 5
       mov    bx, 10
   
   convert_word_loop:
       xor    dx, dx
       div    bx
       add    dl, '0'
       push   dx
       dec    cx
       test   ax, ax
       jnz    convert_word_loop
   
   show_word_digits:
       pop    dx
       mov    ah, 0Eh
       int    10h
       loop   show_word_digits
   
       pop    dx
       pop    cx
       pop    bx
       pop    ax
       ret
   display_word endp
   ```

------

### 总结

此汇编程序通过`table.asm`和`print.asm`文件的分工合作实现了数据的初始化、计算和逐行显示。`table.asm`负责初始化数据，并将其组织到一个公共段`table`中，而`print.asm`从`table`段中读取并格式化输出内容。