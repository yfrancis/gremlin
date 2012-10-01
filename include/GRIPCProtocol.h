/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#define GRSBSupport_MessagePortName "co.cocoanuts.gremlin.sbsupport"

#define gremlind_MessagePortName "co.cocoanuts.gremlin.center"

typedef enum gr_message {
	GREMLIN_IMPORT        = 0xcefaedfe,

    /* Legacy API */
	GREMLIN_SUCC_LEGACY   = 0xefbeadde,
	GREMLIN_FAIL_LEGACY   = 0xbebafeca,

    GREMLIN_SUCCESS       = 1,
    GREMLIN_FAILURE       = 2
} gr_message_t;
