#include <substrate.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

#define kCenterPrefix @"co.cocoanuts.GRDocumentImportProxy:"

extern "C" {
    int SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions(NSString*, 
                                                                 NSURL*, 
                                                                 NSDictionary*,
                                                                 int, 
                                                                 BOOL);
    NSString* SBSCopyFrontmostApplicationDisplayIdentifier();
}

static int (*o_SBSLaunch)(NSString*, NSURL*, NSDictionary*, int, BOOL);

int new_SBSLaunch(NSString* app, 
                  NSURL* url, 
                  NSDictionary* info, 
                  int launchOpts, 
                  BOOL adjust)
{
    NSString* frontmostApp = SBSCopyFrontmostApplicationDisplayIdentifier();

    if ([info objectForKey:@"GRDocumentImport"] &&
        [app isEqualToString:frontmostApp]) 
    {
        // our target app is frontmost, we need
        // to instead communicate with our openURL
        // server within that app
        NSString* centerName;
        centerName = [kCenterPrefix stringByAppendingString:app];

        CPDistributedMessagingCenter* center;
        center = [CPDistributedMessagingCenter centerNamed:centerName];
        
        NSDictionary* userInfo;
        userInfo = [NSDictionary dictionaryWithObject:[url absoluteString]
                                               forKey:@"FileURL"];

        NSError* err = nil;
        NSDictionary* resp;

        resp = [center sendMessageAndReceiveReplyName:@"OpenURL"
                                             userInfo:userInfo
                                                error:&err];
        if (err != nil) {
                NSLog(@"error encountered: %@", err);
        }
        return 2;
    }

    return o_SBSLaunch(app, url, info, launchOpts, adjust);
}

%ctor {
    MSHookFunction(SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions,
                   new_SBSLaunch, &o_SBSLaunch);
}
