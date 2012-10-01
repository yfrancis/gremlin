/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import <Foundation/Foundation.h>
#import "GRController.h"
#import "GRDisplayManager.h"

#ifdef HAVE_BUGSENSE
#include "GRBugSenseAPI.h"
#import <BugSense/BugSenseCrashController.h>
#endif

int main(int argc, char *argv[]) 
{

#ifdef HAVE_BUGSENSE
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:kBSAPIKey
                                               userDictionary:nil
                                              sendImmediately:YES];
#endif

    GRController* controller = [GRController sharedController];
    GRDisplayManager* display = [GRDisplayManager sharedManager];

    [controller addObserver:display
                 forKeyPath:@"hasActiveTasks"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];

    [controller processImportRequests];

	return 0;
}
