//
//  SHOmniAuthFacebook.h
//  SHOmniAuth
//
//  Created by Seivan Heidari on 5/12/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

extern NSString * const SHOmniAuthFacebookErrorDomain;

#import "SHOmniAuthProvider.h"
@interface SHOmniAuthFacebook : NSObject <SHOmniAuthProvider>
+(BOOL)handlesOpenUrl:(NSURL *)theUrl;
@end
