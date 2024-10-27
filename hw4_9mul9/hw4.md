# 1.打印九九乘法表

### 程序概述

该程序使用嵌套循环打印九九乘法表。`BL` 寄存器控制被乘数，`BH` 寄存器控制乘数。每次循环中计算 `i * j` 并打印结果，内层循环从 `j=i` 递减到 1。外层循环控制每行从 9 递减到 1。

### 代码结构

#### 数据段 (`DATA SEGMENT`)

```assembly
assembly复制代码DATA SEGMENT
    MSG     DB 'The 9*9 table:', 0DH, 0AH, '$'    ; 表头提示
    NEWLINE DB 0DH, 0AH, '$'                      ; 换行符
    SPACE2  DB '  $'                              ; 两空格
    SPACE3  DB '   $'                             ; 三空格
DATA ENDS
```

- `MSG` 用于显示表头信息。
- `NEWLINE` 用于换行。
- `SPACE2` 和 `SPACE3` 控制打印间距。

#### 主程序和循环逻辑

```assembly
assembly复制代码START:              
    MOV AX, DATA        ; 初始化数据段
    MOV DS, AX
    LEA DX, MSG         ; 输出表头信息
    MOV AH, 09H
    INT 21H

    MOV BL, 9           ; 外层循环，BL = i = 9
OUTER_LOOP:         
    CMP BL, 0           
    JE END_PROGRAM      

    MOV BH, BL          ; 内层循环，BH = j = i
INNER_LOOP:         
    CMP BH, 0           
    JE PRINT_NEWLINE    

    MOV AL, BL
    CALL PRINT_DIGIT    ; 打印 i
    MOV DL, 'x'
    MOV AH, 02H
    INT 21H

    MOV AL, BH
    CALL PRINT_DIGIT    ; 打印 j
    MOV DL, '='
    MOV AH, 02H
    INT 21H

    MOV AL, BL
    MUL BH              ; 计算 i * j
    CALL PRINT_NUMBER   ; 打印乘积

    CMP AX, 10          ; 控制间距
    JL SINGLE_DIGIT_RESULT
    LEA DX, SPACE2
    MOV AH, 09H
    INT 21H
    JMP CONTINUE_LOOP

SINGLE_DIGIT_RESULT:
    LEA DX, SPACE3
    MOV AH, 09H
    INT 21H

CONTINUE_LOOP:      
    DEC BH              
    JMP INNER_LOOP

PRINT_NEWLINE:      
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    DEC BL
    JMP OUTER_LOOP
END_PROGRAM:        
    MOV AH, 4CH
    INT 21H
```

### 子程序

- **`PRINT_DIGIT`**：打印一个数字。
- **`PRINT_NUMBER`**：打印 `AX` 中的数值，用于显示乘积。

### 结果

该程序逐行输出九九乘法表，保持对齐格式。如果乘积为个位数，添加三个空格；如果为两位数，添加两个空格。



# 2.九九乘法表纠错

### 程序逻辑

1. **数据段 (DATA SEGMENT)**

   - `TABLE` 定义了一个带有错误的 `9x9` 乘法表数据。
   - `ERROR_LABEL` 用于输出表头 `"x y"`。
   - `ERROR_TEXT` 用于在检测到错误时输出 `"error"` 提示。

2. **代码段 (CODE SEGMENT)**

   - `START`: 初始化数据段，将 `DATA` 段装入 `DS`。
   - 打印表头 `"x y"`，提示将显示错误位置的坐标。

3. **嵌套循环**

   - **外层循环 `i`** (`BL`): 设定外层循环变量 `BL` 为 `1`，即第一个被乘数。循环从 `i=1` 到 `i=9`。
   - **内层循环 `j`** (`BH`): 内层循环变量 `BH` 也从 `1` 到 `9`，即每行的乘数。

4. **计算索引和期望值**

   - 索引计算

     : 

     ```
     index = (i - 1) * 9 + (j - 1)
     ```

     ，用于找到乘法表中对应元素的位置。

     - 将 `i-1` 存入 `DL`，`j-1` 存入 `DH`。
     - 计算 `(i-1) * 9` 并加上 `(j-1)`，得到 `TABLE` 中元素的索引。

   - **存储值和期望值**: 将表中的值加载到 `CL`，计算乘积 `i * j` 存入 `AL`，然后比较二者。

5. **错误处理**

   - 如果 `CL` 和 `AL` 不相等，调用 `DISPLAY_ERROR` 显示错误的位置 `(i, j)` 并输出 `"error"`。
   - 进入 `DISPLAY_ERROR`，依次打印 `i` 和 `j`，以及 `"error"` 提示。

6. **辅助子程序**

   - `PRINT_NUMBER_AL`: 将 AL 中的数字转换为字符并输出。

### 程序代码解读

以下是各部分代码的关键逻辑：

```assembly
assembly复制代码START:              
    ; 初始化数据段
    MOV AX, DATA
    MOV DS, AX

    ; 打印表头
    LEA DX, ERROR_LABEL
    MOV AH, 09H
    INT 21H
```

初始化数据段并打印表头 `"x y"`。

#### 外层和内层循环

```assembly
assembly复制代码    MOV BL, 1               ; i = 1
CHECK_ROW:          
    CMP BL, 10
    JGE END_PROGRAM         ; 如果 i > 9，结束程序

    MOV BH, 1               ; j = 1
CHECK_COLUMN:       
    CMP BH, 10
    JGE NEXT_ROW            ; 如果 j > 9，进入下一行
```

- 外层循环控制 `BL` (`i`)。
- 内层循环控制 `BH` (`j`)，用于遍历每一行的列。

#### 索引和乘积计算

```assembly
assembly复制代码    MOV DL, BL
    DEC DL                  ; DL = i - 1
    MOV DH, BH
    DEC DH                  ; DH = j - 1

    MOV AL, DL
    MOV CL, 9
    MUL CL                  ; AX = (i - 1) * 9

    ; 将 DH 扩展为 16 位
    MOV CX, 0
    MOV CL, DH              ; CX = (j - 1)
    ADD AX, CX              ; AX = (i - 1) * 9 + (j - 1)

    MOV SI, OFFSET TABLE
    ADD SI, AX              ; SI = TABLE + index
    MOV CL, [SI]            ; CL = 存储的值

    ; 计算期望的结果 i * j
    MOV AL, BL
    MUL BH                  ; AX = i * j
```

1. **计算索引**: `AX` 中的值为 `TABLE` 中的索引位置。
2. **读取存储值**: 将 `TABLE` 中的值放入 `CL`。
3. **计算期望结果**: 将乘积 `i * j` 存入 `AL`。

#### 错误检测和调用显示错误过程

```assembly
assembly复制代码    CMP CL, AL
    JE NEXT_ELEMENT         ; 如果相等，检查下一个
    ; 错误处理
    MOV DL, BL              ; DL = i
    MOV DH, BH              ; DH = j

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    CALL DISPLAY_ERROR      ; 显示错误

    ; 恢复寄存器
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX

NEXT_ELEMENT:       
    INC BH                  ; j++
    JMP CHECK_COLUMN
```

- 比较 `CL`（表中值）和 `AL`（期望结果）。如果不相等，调用 `DISPLAY_ERROR`。
- 显示错误后，继续检查下一个元素。

#### DISPLAY_ERROR 子程序

```assembly
assembly复制代码DISPLAY_ERROR PROC NEAR
    ; 显示 i
    MOV AL, DL
    CALL PRINT_NUMBER_AL

    ; 显示空格
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; 显示 j
    MOV AL, DH
    CALL PRINT_NUMBER_AL

    ; 显示 "error"
    LEA DX, ERROR_TEXT
    MOV AH, 09H
    INT 21H
    RET
DISPLAY_ERROR ENDP
```

- 打印错误位置 `(i, j)`。
- 使用 `PRINT_NUMBER_AL` 打印数字 `i` 和 `j`，并显示 `"error"`。

#### PRINT_NUMBER_AL 子程序

```assembly
assembly复制代码PRINT_NUMBER_AL PROC NEAR
    PUSH AX
    PUSH DX

    CMP AL, 10
    JL PRINT_SINGLE_DIGIT

    ; 两位数处理
    MOV AH, 0
    MOV BL, 10
    DIV BL               ; AL = 商（十位），AH = 余数（个位）

    ; 打印十位
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; 打印个位
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    JMP PRINT_NUMBER_AL_END

PRINT_SINGLE_DIGIT: 
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

PRINT_NUMBER_AL_END:
    POP DX
    POP AX
    RET
PRINT_NUMBER_AL ENDP
```

- `PRINT_NUMBER_AL` 将 `AL` 中的值转为字符并输出。
- 若是个位数，直接打印；否则先打印十位，再打印个位。

### 运行结果

该程序会逐行扫描 `9x9` 表，找出数据中的错误，并输出位置 `(i, j)` 和错误提示 `"error"`。