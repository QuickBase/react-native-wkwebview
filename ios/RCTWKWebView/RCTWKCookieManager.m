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

RCT_EXPORT_METHOD(setCookie:(NSString *)name value:(NSString*)value url:(NSString*)urlString resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSDictionary* props = [NSDictionary dictionaryWithObjectsAndKeys:
                           url.host, NSHTTPCookieDomain,
                           url.path, NSHTTPCookiePath,
                           name, NSHTTPCookieName,
                           value,NSHTTPCookieValue,nil];
    
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
                __block NSUInteger cookiesCleared = 0;
                __block NSUInteger cookiesLength = [cookiesToRemove count];
                for( NSHTTPCookie* cookie in cookiesToRemove ){
                    [wkCookieStore deleteCookie:cookie completionHandler:^{
                        cookiesCleared++;
                        if (cookiesCleared == cookiesLength){
                            resolve(nil);
                        }
                    }];
                }
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
