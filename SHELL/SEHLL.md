# SEHLL编程

## 1.脚本头固定格式

```bash
#cat .vimrc   #将此文件放置在root目录下自动生效
set ignorecase
set cursorline
set autoindent
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
	if expand("%:e") == 'sh'
	call setline(1,"#!/bin/bash") 
	call setline(2,"#") 
	call setline(3,"#********************************************************************") 
	call setline(4,"#Author:		zhuxiaoxu") 
	call setline(5,"#Email: 		1146992442@qq.com") 
	call setline(6,"#Date: 			".strftime("%Y-%m-%d"))
	call setline(7,"#FileName：		".expand("%"))
	call setline(8,"#Description：		Use your head,and you will have a good idea") 
	call setline(9,"#Copyright (C): 	".strftime("%Y")." All rights reserved")
	call setline(10,"#********************************************************************") 
	call setline(11,"") 
	endif
endfunc
autocmd BufNewFile * normal G
```

## 2.各种判断

### 2.1：判断大小

```bash
-gt  #大于
-ge  #大于等于
-eq  #等于
-le  #小于等于
-lt  #小于

&&  #短路与
||  #短路或
```

### 2.2：文件测试判断

- 存在性测试

```bash
-a FILE   #同-e
-e FILE   #文件存在性测试，存在为真，否则为假
```

- 存在性+类别测试

```bash
-b FILE  #是否存在且为块设备文件
-c FILE  #是否存在且为字符设备文件
-d FILE  #是否存在且为目录文件
-f FILE  #是否存在且为普通文件
-h FILE 或 -L FILE #是否存在且为符号链接文件
-p FILE  #是否存在且为命名管道文件
-S FILE  #是否存在且为套接字文件
```

- 文件权限测试

```bash
-r FILE  #是否存在且可读
-w FILE  #是否存在且可写
-x FILE  #是否存在且可执行
```

