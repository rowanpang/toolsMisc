1,log:
    a,*-176.log 是 tsock.conf 配置为176时的log,(另外一台机,lvzl)
    b,*-100.........................100....(loalhost)

2,tsocks 原理:
    a,normal socket,block socket
	1),直接hook app 中的connect(skfd,xx),在这个阶段
	2),连接proxy server并实施sock 协议.然后
	3),返回,free 掉相关内存(skfd 已经是connect的proxy server不再需要关系这个连接)
    b,non-block socket
	1),tsocks 的处理完全符合标准api调用,如果是non-block 则直接返回
	2),connect阶段skfd 可能不会连接到proxy server.
	3),tsocks 会hook app 中 call poll(xxx,POLLOUT,xx),并尝试连接proxy server,实施sock 协议.

3,with curl
    a,问题现象:
	curl ip.cn 不返回 无法获得当前的外网ip

    b,root case:
	1),curl 建立的是non-block socket  根据上面tosks原理可知，tsocks需要hook curl 对poll(xxx,POLLOUT,xx)
	2),但是curl 编译启用了fortify sourc,在一定的上下文中调用的不是poll 而是 __poll_chk
	3),而tsocks没有export __poll_chk,从而无法hook它
	4),恰好这个主要的'poll'(send http 请求之前的),就变成了__poll_chk.
	5),对于192.168.1.100, 
	    a),localhost 连接,connect 瞬间就完成了,所以__poll_chk直接返回1(即连接成功,连接可以使用)
	    b),curl 直接发送了 http 请求,但真实情况时 tsocks还没有建立起socks协议,proxy server不会响应这个请求.
	
	6),对于192.168.1.176，
	    a),remote host, connect并没有瞬间完成,虽然时call的 __poll_chk 但是返回0(含义为当前连接还不可用)
	    b),返回0,curl就会进行延时 后面会调用 Curl_poll() 而这个调用的就是'poll'非__poll_chk, 
	    c),tsocks hook poll,进行sock 协议.
	    d),连接成功,返回,
	    e),curl 发送http请求,proxy 代理, 返回.
	
    c,fix:
	ref xxx.rowan.xxx.src.rpm
