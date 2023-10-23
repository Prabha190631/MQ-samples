/* Sample script for setting up Distributed Queue Manager with SSL enabled */

#!/bin/bash
endmqm -i SEN; endmqm -i REC
dltmqm SEN; dltmqm REC
crtmqm SEN; crtmqm REC
strmqm SEN; strmqm REC

# set-up for receiver side: create ql, listener, channel
echo "define ql(RECEIVERQ)" | runmqsc REC
echo "define chl(SEN.TO.REC) chltype(RCVR) trptype(TCP) SSLCIPH(TLS_RSA_WITH_AES_256_GCM_SHA384)" | runmqsc REC
echo "define listener(REC.TO.LISTENER) trptype(TCP) port(2319)" | runmqsc REC
echo "start listener(REC.TO.LISTENER)" | runmqsc REC
echo "dis lsstatus(REC.TO.LISTENER)" | runmqsc REC
echo "refresh security type(ssl)" | runmqsc REC
echo "quit" | runmqsc REC

# set-up of sender side: create ql for tx q, create remote queue, channel
echo "define ql(REC) usage(XMITQ)" | runmqsc SEN
echo "define qr(SENDERQ) RNAME(RECEIVERQ) RQMNAME(REC) XMITQ(REC)" | runmqsc SEN
echo "define chl(SEN.TO.REC) chltype(SDR) trptype(TCP)  XMITQ(REC)  CONNAME('localhost(2319)') SSLCIPH(TLS_RSA_WITH_AES_256_GCM_SHA384)" | runmqsc SEN
echo "refresh security type(ssl)" | runmqsc SEN
echo "start chl(SEN.TO.REC)" | runmqsc SEN
echo "dis chs(SEN.TO.REC)" | runmqsc SEN
echo "quit" | runmqsc SEN

# create keydatabase, personal certificates and extract/add public part of certificate for sender-receiver QM's
cd /var/mqm/qmgrs/SEN/ssl
runmqakm -keydb -create -db "key.kdb" -pw alice -stash 
runmqckm -cert -create -db "key.kdb" -label ibmwebspheremqsen -dn "CN=SDR_RSA_CERT" -stashed
runmqakm -cert -extract -db key.kdb -pw alice -label ibmwebspheremqsen -target sen.cer
chmod -R 777 *
scp sen.cer /var/mqm/qmgrs/REC/ssl

cd /var/mqm/qmgrs/REC/ssl
runmqakm -keydb -create -db "key.kdb" -pw alice -stash 
runmqckm -cert -create -db "key.kdb" -label ibmwebspheremqrec -dn "CN=RCVR_RSA_CERT" -stashed
runmqakm -cert -extract -db key.kdb -pw alice -label ibmwebspheremqrec -target rec.cer
chmod -R 777 *
scp rec.cer /var/mqm/qmgrs/SEN/ssl
runmqckm -cert -add -db key.kdb -pw alice -label ibmwebspheremqsen -file sen.cer -format ascii

cd /var/mqm/qmgrs/SEN/ssl
runmqckm -cert -add -db key.kdb -pw alice -label ibmwebspheremqrec -file rec.cer -format ascii

runmqakm -cert -list -db key.kdb -stashed
cd -
runmqakm -cert -list -db key.kdb -stashed


#/opt/mqm/samp/bin/amqsput SENDERQ SEN
#/opt/mqm/samp/bin/amqsget RECEIVERQ REC
