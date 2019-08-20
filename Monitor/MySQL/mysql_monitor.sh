#!/bin/bash
Seconds_Behind_Master(){
	NUM=`mysql -uroot -hlocalhost   -e "show slave status\G;"  | grep "Seconds_Behind_Master:" | awk -F: '{print $2}'`
	echo $NUM
}

master_slave_check(){
NUM1=`mysql -uroot -hlocalhost   -e "show slave status\G;"  | grep "Slave_IO_Running" | awk -F:  '{print $2}' | sed 's/^[ \t]*//g'`
#echo $NUM1
NUM2=`mysql -uroot -hlocalhost   -e "show slave status\G;"  | grep "Slave_SQL_Running:" | awk -F:  '{print $2}' | sed 's/^[ \t]*//g'`
#echo $NUM2
if test $NUM1 == "Yes" &&  test $NUM2 == "Yes";then
    echo 50
else
    echo 100
fi
}

main(){
    case $1 in
        Seconds_Behind_Master)
           Seconds_Behind_Master;
           ;;
	master_slave_check)
	   master_slave_check
	   ;;
    esac
}
main $1
