/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#define GRSBSupport_MessagePortName "co.cocoanuts.gremlin.sbsupport"
#define gremlind_MessagePortName "co.cocoanuts.gremlin.center"

typedef enum gr_message {
    /* Legacy API */
	GREMLIN_IMPORT_LEGACY = 0xcefaedfe,
	GREMLIN_SUCC_LEGACY   = 0xefbeadde,
	GREMLIN_FAIL_LEGACY   = 0xbebafeca,

    /* API v2 */
    GREMLIN_IMPORT  = 1,
    GREMLIN_FAILURE = 2,
    GREMLIN_SUCCESS = 6
} gr_message_t;
