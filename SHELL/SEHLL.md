# SEHLL编程

1.脚本格式

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

2.