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
 

cd /var/mqm/qmgrs/QM/ssl
runmqakm -keydb -create -db "key.kdb" -pw alice -stash
runmqakm -keydb -create -db "keyclient.kdb" -pw alice -stash
runmqakm -cert -create -db "key.kdb" -pw alice -label ibmwebspheremqqm -dn "CN=svrconn,O=IBM,C=GB"
runmqakm -cert -create -db "keyclient.kdb" -pw alice -label ibmwebspheremqroot -dn "CN=clientconn,O=IBM,C=GB"

runmqakm -cert -extract -db key.kdb -pw alice -label ibmwebspheremqqm -target svrconn.cer
runmqakm -cert -extract -db keyclient.kdb -pw alice -label ibmwebspheremqroot -target clientconn.cer

runmqckm -cert -add -db keyclient.kdb -pw alice -label ibmwebspheremqqm -file svrconn.cer -format ascii
runmqckm -cert -add -db key.kdb -pw alice -label ibmwebspheremqroot -file clientconn.cer -format ascii
runmqakm -cert -list -db key.kdb -stashed
runmqakm -cert -list -db keyclient.kdb -stashed
chmod -R 777 *

# Export the follwoing env's
export MQCHLLIB=/var/mqm/qmgrs/QM/@ipcc
export MQCHLTAB=AMQCLCHL.TAB
export MQSSLKEYR=/var/mqm/qmgrs/QM/ssl/keyclient

/opt/mqm/samp/bin/amqsputc QL QM
/opt/mqm/samp/bin/amqsgetc QL QM
