0,basic
    a,一种基于dot语言的画图工具，所思即所得.
    b,dot -Tpng xx.gv -o xx.png
    c,withVim
	有个vim 插件可以识别gv文件 可以实现交互绘制.
	交互绘制原理:
	    dot -Txlib xxxxx.gv
	    每次保存 xxx.gv时dot会自动渲染,然后更新视图显示.
	    mapkey
		<LocalLeader>li
		:map	to see
	ref .vim/vimrc
	
1,error
    a,Layout type: "" not recognized. Use one of:
	fix: dot -c	    #config之后在使用.

2,rank dir
    a,指明node的排列方向.
    b,record时
	label="<f0> |<f1>a\ mid |<f2>" 与rankdir垂直构造. 
	    f0 f1:'a mid' f2
	label="{<f0> |<f1>a\ mid |<f2>}" 与rankdir同构造.
	    f0
	    f1:'a mid'
	    f2
