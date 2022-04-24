#/bin/bash

db_host=""
db_port="3306"
db_user=""
db_pass=""
db_dbname=""
sysb_mysql_conn="--mysql-host=$db_host --mysql-db=$db_dbname --mysql-user=$db_user --mysql-password=$db_pass"


# without ssl
for sslmode in DISABLED REQUIRED
do
    for conthread in 4 8 16 24 32 64
    do
        echo "start " $conthread "test "
    #    echo $sysb_mysql_conn
    #     mysql -u$db_user -p$db_pass \
    #-h$db_host -e "select sleep(2),now()"
        mysql -u$db_user -p$db_pass -h$db_host -e "drop database if exists $db_dbname"
        mysql -u$db_user -p$db_pass -h$db_host -e "create database $db_dbname"

    # prepare
    # --table_size=1000000 --tables=5 so, set --threads=5
    # for alibaba cloud 4c,16g rds, it takes
        sysbench oltp_read_write --threads=5 --time=600 --warmup-time=60 \
    --report-interval=3 --percentile=95 --histogram=on --db-driver=mysql \
    $sysb_mysql_conn \
    --table_size=1000000 --tables=5 prepare >> p.log.$sslmode.$conthread 2>>2.log

    # run
        sysbench oltp_read_write --mysql-ssl=$sslmode --threads=$conthread --time=600 --warmup-time=60 \
    --report-interval=3 --percentile=95 --histogram=on --db-driver=mysql \
    $sysb_mysql_conn \
    --table_size=1000000 --tables=5 run >> r.log.$sslmode.$conthread 2>>2.log


    # cleanup
        sysbench oltp_read_write --threads=$conthread --time=600 --warmup-time=60 \
    --report-interval=3 --percentile=95 --histogram=on --db-driver=mysql \
    $sysb_mysql_conn \
    --table_size=1000000 --tables=5 cleanup >> c.log.$sslmode.$conthread 2>>2.log
    done
done
