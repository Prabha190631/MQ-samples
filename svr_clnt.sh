# SVRCONN-CLNTCONN set-up

#!/bin/bash
endmqm -i QM; dltmqm QM
crtmqm QM; strmqm QM

echo "alter qmgr chlauth(disabled) connauth('')" | runmqsc QM
echo "refresh security(*)" | runmqsc QM
echo "define chl(CHL) chltype(SVRCONN) trptype(TCP)" | runmqsc QM
echo "define ql(QL)" | runmqsc QM
echo "define listener(LIST) trptype(TCP) port(1920) control(qmgr)" | runmqsc QM
echo "start listener(LIST)" | runmqsc QM
echo "dis lsstatus(LIST)" | runmqsc QM
echo "define chl(CHL) chltype(CLNTCONN) trptype(TCP) conname('127.0.0.1(1920)') qmname(QM)" | runmqsc QM
echo "quit"  | runmqsc QM
 
export MQCHLLIB=/var/mqm/qmgrs/QM/@ipcc
export MQCHLTAB=AMQCLCHL.TAB

/opt/mqm/samp/bin/amqsputc QL QM
/opt/mqm/samp/bin/amqsgetc QL QM
