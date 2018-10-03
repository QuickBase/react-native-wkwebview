//
//  RCTWKCookieManager.m
//  RCTWKWebView
//
//  Created by Kyle Shank on 9/8/18.
//

#import "RCTWKCookieManager.h"

@import WebKit;

@implementation RCTWKCookieManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setCookie:(NSString * _Nonnull)name value:(NSString* _Nonnull)value maximumAge:(NSNumber* _Nonnull)maximumAge secure:(BOOL)secure sessionOnly:(BOOL)sessionOnly httpOnly:(BOOL)httpOnly url:(NSString* _Nonnull)urlString resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                           url.host, NSHTTPCookieDomain,
                           url.path, NSHTTPCookiePath,
                           name, NSHTTPCookieName,
                           value,NSHTTPCookieValue,
                           [maximumAge stringValue], NSHTTPCookieMaximumAge,
                           (secure ? @"TRUE" : @"FALSE"), NSHTTPCookieSecure,
                           (sessionOnly ? @"TRUE" : @"FALSE"), NSHTTPCookieDiscard,
                           (httpOnly ? @"TRUE" : @"FALSE"), @"HttpOnly",
                           @"1", NSHTTPCookieVersion,
                           nil];
    
    NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:props];
    
    if (@available(iOS 11, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WKHTTPCookieStore* wkCookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
            [wkCookieStore setCookie:newCookie completionHandler:^{
                resolve(props);
            }];
        });
    }else {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
        [[NSUserDefaults standardUserDefaults] synchronize];
        resolve(props);
    }
}

RCT_EXPORT_METHOD(clearCookies:(NSString *)urlString resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (@available(iOS 11, *)) {
        NSURL* url = [NSURL URLWithString:urlString];
        dispatch_async(dispatch_get_main_queue(), ^{
            WKHTTPCookieStore* wkCookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
            [wkCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
                NSMutableArray<NSHTTPCookie*>* cookiesToRemove = [NSMutableArray array];
                for( NSHTTPCookie* cookie in cookies ){
                    if([cookie.domain isEqualToString:url.host]){
                        [cookiesToRemove addObject:cookie];
                    }
                }
                for( NSHTTPCookie* cookie in cookiesToRemove ){
                    [wkCookieStore deleteCookie:cookie completionHandler:nil];
                }
                resolve(nil);
            }];
        });
    }else {
        NSURL* url = [NSURL URLWithString:urlString];
        NSArray<NSHTTPCookie*>* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for( NSHTTPCookie* cookie in cookies ){
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(clearAllCookies:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (@available(iOS 11, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeCookies]];
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                       modifiedSince:dateFrom
                                                   completionHandler: ^ {
                                                       resolve(nil);
                                                   }];
        });
    }else {
        NSArray<NSHTTPCookie*>* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];;
        for( NSHTTPCookie* cookie in cookies ){
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        resolve(nil);
    }
}

RCT_EXPORT_METHOD(getCookie:(NSString*)name url:(NSString *)urlString resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    NSURL* url = [NSURL URLWithString:urlString];
    if (@available(iOS 11, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WKHTTPCookieStore* wkCookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
            [wkCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
                NSString* value = nil;
                for( NSHTTPCookie* cookie in cookies ){
                    if ([cookie.name isEqualToString:name] && [cookie.domain isEqualToString:url.host]){
                        value = cookie.value;
                        break;
                    }
                }
                resolve(value);
            }];
        });
    } else {
        NSArray<NSHTTPCookie*>* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        NSString* value = nil;
        for( NSHTTPCookie* cookie in cookies ){
            if ([cookie.name isEqualToString:name]){
                value = cookie.value;
                break;
            }
        }
        resolve(value);
    }
}

@end
