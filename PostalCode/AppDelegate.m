//
//  AppDelegate.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 10/22/13.
//  Copyright (c) 2013 OCHIISHI Koichiro. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    // postalcode://search?query=
    NSString *host = [url host];
    NSDictionary *dict = [self parseQueryString:[url query]];
    if ([host isEqualToString:@"search"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchQuery" object:dict];
    }
    return YES;
}

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
        [dict setObject:val forKey:key];
        // DLog(@"key: %@, val: %@", key, val);
    }
    return dict;
}

@end
