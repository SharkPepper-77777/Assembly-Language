assume cs:codesg, ds:data, es:table

data segment
    years  db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
           db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
           db '1993','1994','1995'

    salary dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
           dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    emp    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
           dw 11542,14430,45257,17800
data ends

table segment PUBLIC        ; 确保 table 段是公共的，以便其他文件可以访问
          db 21 dup (0)    ; 预留 21 行空间，每行 16 字节
table ends

codesg segment
               extrn start_print:proc       ; 声明 start_print 为外部过程

    start:     
               mov   ax, data
               mov   ds, ax
               mov   ax, table
               mov   es, ax

               mov   cx, 21                 ; 共 21 行数据
               mov   bx, 0                  ; 雇员数索引
               mov   bp, 0                  ; 年份和总收入索引
               mov   si, 0                  ; table 偏移

    init_table:
    ; 填充年份
               mov   ax, ds:[bp]            ; 前 2 字节
               mov   es:[si], ax
               add   si, 2
               mov   ax, ds:[bp+2]          ; 后 2 字节
               mov   es:[si], ax
               add   si, 3                  ; 空格，移动到收入

    ; 填充收入（32 位）
               mov   di, offset salary
               mov   ax, ds:[bp+di]
               mov   es:[si], ax
               add   si, 2
               mov   ax, ds:[bp+di+2]
               mov   es:[si], ax
               add   si, 3                  ; 空格，移动到雇员数

    ; 填充雇员数
               mov   di, offset emp
               mov   ax, ds:[bx+di]
               mov   es:[si], ax
               add   si, 3                  ; 空格，移动到人均收入

    ; 计算并填充人均收入
               mov   di, offset salary
               mov   ax, ds:[bp+di]
               mov   dx, ds:[bp+di+2]
               mov   di, offset emp
               div   word ptr ds:[bx+di]
               mov   es:[si], ax

    ; 前进到下一行
               add   si, 3
               add   bp, 4
               add   bx, 2
               loop  init_table

    ; 调用打印过程
               call  start_print

    ; 程序结束
               mov   ax, 4c00h
               int   21h
codesg ends
end start
