#/bin/bash

#SQL statistics:
#    queries performed:
#        read:                            4564805
#        write:                           1304232
#        other:                           652114
#        total:                           6521151
#    transactions:                        326058 (543.42 per sec.)
#    queries:                             6521151 (10868.41 per sec.)
#    ignored errors:                      0      (0.00 per sec.)
#    reconnects:                          0      (0.00 per sec.)
#
#Throughput:
#    events/s (eps):                      543.4213
#    time elapsed:                        600.0097s
#    total number of events:              326058
#
#Latency (ms):
#         min:                                    6.14
#         avg:                                    7.36
#         max:                                   92.74
#         95th percentile:                        8.28
#         sum:                              2399637.20
#
#Threads fairness:
#    events (avg/stddev):           81514.5000/184.11
#    execution time (avg/stddev):   599.9093/0.00

for sslmode in DISABLED REQUIRED
do
    for conthread in 4 8 16 24 32 64 96
    do
        echo "sslmod:" $sslmode ";   Concurrent thread" $conthread " "
        awk '{  \
           if($1 ~ /transactions:/){printf $0;print ""} \
           else if ( $1 ~ /queries:/ ){printf $0;print ""} \
           else if ( $1 ~ /95th/ ){printf $0;print ""} \
        }' r.log.$sslmode.$conthread
        echo ""
    done
done
