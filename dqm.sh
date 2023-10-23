/* Sample script for setting up Distributed Queue Manager */

#!/bin/bash
endmqm -i SDR; endmqm -i RCVR
dltmqm SDR; dltmqm RCVR
crtmqm SDR; crtmqm RCVR
strmqm SDR; strmqm RCVR

# set-up of receiver side, create ql, listener, channel 
echo "define ql(RCVR.Q)" | runmqsc RCVR
echo "define chl(SDR.RCVR) chltype(RCVR) TRPTYPE(TCP)" | runmqsc RCVR
echo "define listener(RCVR.L) trptype(TCP) port(1906) control(qmgr)" | runmqsc RCVR
echo "start listener(RCVR.L)" | runmqsc RCVR
echo "dis lsstatus(RCVR.L)" | runmqsc RCVR
echo "quit" | runmqsc RCVR

# set-=up of sender side, create ql for tx q, create remote queue, channel 
echo "define ql(TX.Q) USAGE(XMITQ)" | runmqsc SDR
echo "define qr(SDR.Q) rname(RCVR.Q) rqmname(RCVR) XMITQ(TX.Q)" | runmqsc SDR
echo "define chl(SDR.RCVR) chltype(SDR) TRPTYPE(TCP) XMITQ(TX.Q) CONNAME('localhost(1906)')" | runmqsc SDR
echo "start chl(SDR.RCVR)" | runmqsc SDR
echo "dis chs(SDR.RCVR)" | runmqsc SDR
echo "quit" | runmqsc SDR

# put and get messages from the queue
/opt/mqm/samp/bin/amqsput SDR.Q SDR
/opt/mqm/samp/bin/amqsget RCVR.Q RCVR
