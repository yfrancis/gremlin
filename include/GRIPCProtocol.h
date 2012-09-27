/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#define GRSBSupport_MessagePortName "co.cocoanuts.gremlin.sbsupport"

#define gremlind_MessagePortName "co.cocoanuts.gremlin.center"

typedef enum gr_message {
	GREMLIN_IMPORT = 0xcefaedfe,
	GREMLIN_SUCC   = 0xefbeadde,
	GREMLIN_FAIL   = 0xbebafeca
} gr_message_t;
