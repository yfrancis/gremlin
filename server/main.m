/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import <Foundation/Foundation.h>
#import "GRController.h"

int main(int argc, char *argv[]) 
{
    GRController* controller = [GRController sharedController];
    NSLog(@"created gremlin controller! %@", controller);

    CFRunLoopRun();

	return 0;
}
