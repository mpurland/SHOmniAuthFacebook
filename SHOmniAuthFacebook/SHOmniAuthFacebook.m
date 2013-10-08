//
//  SHOmniAuthFacebook.m
//  SHOmniAuth
//
//  Created by Seivan Heidari on 5/12/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

//Class dependency
#import "SHOmniAuthFacebook.h"
#import "SHOmniAuth.h"
#import "SHOmniAuthProviderPrivates.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSession+Internal.h>





#define NSNullIfNil(v) (v ? v : [NSNull null])


@interface SHOmniAuthFacebook ()
+(void)updateAccount:(ACAccount *)theAccount withCompleteBlock:(SHOmniAuthAccountResponseHandler)completeBlock;
+(void)performLoginForNewAccount:(SHOmniAuthAccountResponseHandler)completionBlock;
+(NSMutableDictionary *)authHashWithResponse:(NSDictionary *)theResponse;

@end

@implementation SHOmniAuthFacebook


+(void)performLoginWithListOfAccounts:(SHOmniAuthAccountsListHandler)accountPickerBlock
                           onComplete:(SHOmniAuthAccountResponseHandler)completionBlock; {
    
    [self performLoginForNewAccount:completionBlock];
}


+(BOOL)hasLocalAccountOnDevice; {
    ACAccountStore * store = [[ACAccountStore alloc] init];
    ACAccountType  * type  = [store accountTypeWithAccountTypeIdentifier:self.accountTypeIdentifier];
    return [store accountsWithAccountType:type].count > 0;
}

+(BOOL)handlesOpenUrl:(NSURL *)theUrl; {
    return [FBSession.activeSession handleOpenURL:theUrl];
}

+(NSString *)provider; {
    return ACAccountTypeIdentifierFacebook;
}

+(NSString *)accountTypeIdentifier; {
    return ACAccountTypeIdentifierFacebook;
}

+(NSString *)serviceType; {
    return SLServiceTypeFacebook;
}

+(NSString *)description; {
    return NSStringFromClass(self.class);
}

+ (NSArray *)permissionList
{
    NSString * permission = [SHOmniAuth providerValue:SHOmniAuthProviderValueScope forProvider:self.provider];
    NSArray  * permissionList = nil;
    if(permission.length > 0) {
        permissionList = [permission componentsSeparatedByString:@","];
    } else {
        permissionList = @[@"email"];
    }
    return permissionList;
}

+(void)performLoginForNewAccount:(SHOmniAuthAccountResponseHandler)completionBlock;{
    void (^fbCompleteHandler)(FBSession *session, FBSessionState status, NSError *error) = ^(FBSession *session, FBSessionState status, NSError *error) {
        if (status == FBSessionStateClosedLoginFailed || error ) {
            completionBlock(nil, nil, error, NO);
        }
        else if (session != nil && (status == FBSessionStateOpenTokenExtended || status == FBSessionStateOpen)) {
            [self omniAuthMeWithSession:session completion:completionBlock];
        }
    };
    
    NSArray *permissions = [self permissionList];

    if ([FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:fbCompleteHandler]) {
        // Success
    }
}

+ (void)omniAuthMeWithSession: (FBSession *) session completion:(SHOmniAuthAccountResponseHandler)completionBlock {
    FBRequest *requestForMe = [[FBRequest alloc] initWithSession:session graphPath:@"me"];
    [requestForMe startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error) {
            completionBlock(nil, nil, error, NO);
        } else {
            [result setObject: FBSession.activeSession.accessTokenData.accessToken forKey:@"token"];
            completionBlock(nil,[SHOmniAuthFacebook authHashWithResponse:result],error,YES);
        }
    }];
    
}

//Refactor this fucking monster
+(void)updateAccount:(ACAccount *)account withCompleteBlock:(SHOmniAuthAccountResponseHandler)completeBlock; {
    [self performLoginForNewAccount:completeBlock];
}

+(NSMutableDictionary *)authHashWithResponse:(NSDictionary *)theResponse; {
    NSString * name      = theResponse[@"name"];
    NSArray  * names     = [name componentsSeparatedByString:@" "];
    NSString * firstName = theResponse[@"first_name"];
    NSString * lastName  = theResponse[@"last_name"];
    if(names.count > 0 && firstName == nil)
        firstName = names[0];
    if(names.count > 1 && lastName == nil)
        lastName = names[1];
    if(names.count > 2  && lastName == nil)
        lastName = names[names.count-1];
    
    
    
    NSMutableDictionary * omniAuthHash = @{@"auth" :
                                               @{@"credentials" : @{@"secret" : NSNullIfNil(theResponse[@"oauth_token_secret"]),
                                                                    @"token"  : NSNullIfNil(theResponse[@"token"])
                                                                    }.mutableCopy,
                                                 
                                                 @"info" : @{@"description"  : NSNullIfNil(theResponse[@"description"]),
                                                             @"email"        : NSNullIfNil(theResponse[@"email"]),
                                                             @"first_name"   : NSNullIfNil(firstName),
                                                             @"last_name"    : NSNullIfNil(lastName),
                                                             @"headline"     : NSNullIfNil(theResponse[@"headline"]),
                                                             @"industry"     : NSNullIfNil(theResponse[@"industry"]),
                                                             @"image"        : NSNullIfNil(theResponse[@"profile_image_url"]),
                                                             @"name"         : NSNullIfNil(name),
                                                             @"urls"         : @{@"public_profile" : NSNullIfNil(theResponse[@"link"])
                                                                                 }.mutableCopy,
                                                             
                                                             }.mutableCopy,
                                                 @"provider" : @"facebook",
                                                 @"uid"      : NSNullIfNil(theResponse[@"id"]),
                                                 @"raw_info" : NSNullIfNil(theResponse)
                                                 }.mutableCopy,
                                           @"email"    : NSNullIfNil(theResponse[@"email"]),
                                           }.mutableCopy;
    
    
    return omniAuthHash;
    
}


@end