#!/bin/bash 

nginx_status_fun(){ #函数内容
	NGINX_PORT=$1 #端口，函数的第一个参数是脚本的第二个参数，即脚本的第二个参数是段端口号
	NGINX_COMMAND=$2 #命令，函数的第二个参数是脚本的第三个参数，即脚本的第三个参数是命令
	nginx_active(){ #获取nginx_active数量，以下相同，这是开启了nginx状态但是只能从本机看到
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| grep 'Active' | awk '{print $NF}'
        }
	nginx_reading(){ #获取nginx_reading状态的数量
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| grep 'Reading' | awk '{print $2}'
       }
	nginx_writing(){
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| grep 'Writing' | awk '{print $4}'
       }
	nginx_waiting(){
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
       }
	nginx_accepts(){
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $1}'
       }
	nginx_handled(){
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $2}'
       }
	nginx_requests(){
        /usr/bin/curl "http://127.0.0.1:"$NGINX_PORT"/nginx_status/" 2>/dev/null| awk NR==3 | awk '{print $3}'
       }
  	case $NGINX_COMMAND in
		active)
			nginx_active;
			;;
		reading)
			nginx_reading;
			;;
		writing)
			nginx_writing;
			;;
		waiting)
			nginx_waiting;
			;;
		accepts)
			nginx_accepts;
			;;
		handled)
			nginx_handled;
			;;
		requests)
			nginx_requests;
		esac 
}

main(){ #主函数内容
	case $1 in #分支结构，用于判断用户的输入而进行响应的操作
		nginx_status) #当输入nginx_status就调用nginx_status_fun，并传递第二和第三个参数
			nginx_status_fun $2 $3;
			;;
		*) #其他的输入打印帮助信息
			echo $"Usage: $0 {nginx_status key}"
	esac #分支结束符
}

main $1 $2 $3
