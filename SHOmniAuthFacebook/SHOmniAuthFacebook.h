//
//  SHOmniAuthFacebook.h
//  SHOmniAuth
//
//  Created by Seivan Heidari on 5/12/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "SHOmniAuthProvider.h"
@class FBSession;

@interface SHOmniAuthFacebook : NSObject <SHOmniAuthProvider>

+ (BOOL)handlesOpenUrl:(NSURL *)theUrl;
+ (void)omniAuthMeWithSession: (FBSession *) session completion:(SHOmniAuthAccountResponseHandler)completionBlock;

@end
