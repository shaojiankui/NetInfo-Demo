//
//  NetInfo.m
//  NetInfo-Demo
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "NetInfo.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <mach/mach.h>
@implementation NetInfo
+ (NSString *)getIPAddress {
    return [self localAddressForInterface:@"en0"];
}

+ (NSMutableDictionary *) getInterfaceList
{
    NSMutableArray *arrayOfAllInterfaces = [NSMutableArray array];
    NSMutableDictionary *dictOfAllInterfaces = [NSMutableDictionary dictionary];
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString* name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                
                // NSLog(@"if: %@ %@", name, address);
                
                [arrayOfAllInterfaces addObject:name];
                [dictOfAllInterfaces setObject:address forKey:name];
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    // return arrayOfAllInterfaces;
    return dictOfAllInterfaces;
}

+ (NSString *) localAddressForInterface:(NSString *)interface
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                NSLog(@"if; %@ %@", [NSString stringWithUTF8String:temp_addr->ifa_name],
                      [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:interface]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


+ (BOOL)isJailbroken
{
    if (!([UIDevice.currentDevice.model isEqualToString:@"iPhone Simulator"] || [UIDevice.currentDevice.model isEqualToString:@"iPad Simulator"]))
    {
        if ([NSFileManager.defaultManager fileExistsAtPath:@"/private/var/lib/apt/"])
            return YES;
        
        if (!NSBundle.mainBundle.infoDictionary[@"SignerIdentity"])
            return YES;
    }
    
    return NO;
}

+ (NSString *)MacAddressOfInterface:(NSString *)interface
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *mac;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if (!(mib[5] = if_nametoindex(interface.UTF8String)))
        return nil;
    
    if (0 > sysctl(mib, 6, NULL, &len, NULL, 0))
        return nil;
    
    buf = malloc(len);
    
    if (0 > sysctl(mib, 6, buf, &len, NULL, 0))
    {
        free(buf);
        
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    mac = (unsigned char *)LLADDR(sdl);
    
    NSString *ret = [NSString.alloc initWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]];
    
    free(buf);
    
    return ret;
}


+ (id)fetchSSIDInfo {
    
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        NSLog(@"%@ -> %@", ifnam, info);
        
        if (info && [info count]) { break; }
    }
    return info;
}

+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@",[info  allKeys]);
        if (info[@"SSIDD"]) {
            ssid = info[@"SSID"];
            
        }
    }
    return ssid;
}

+ (NSMutableDictionary *)ping:(NSString *)host {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    SCNetworkConnectionFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(SCNetworkReachabilityCreateWithName(NULL, [host cStringUsingEncoding:NSUTF8StringEncoding]), &flags) && flags > 0) {
        // NSLog(@"Host %@ is reachable: %d", host, flags);
        [result setObject:@"yes" forKey:@"reachable"];
    }
    else {
        [result setObject:@"no" forKey:@"reachable"];
    }
    [result setObject:[NSString stringWithFormat:@"ping %@", host] forKey:@"description"];
    
    return result;
}

+ (NSMutableDictionary *)fetch:(NSString *)file {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:file] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    NSURLResponse *testResponse;
    NSError *testError;
    
    
    NSDate *date = [NSDate date];
    NSData *testData = [NSURLConnection sendSynchronousRequest:testRequest returningResponse:&testResponse error:&testError];
    double timePassed_seconds = [date timeIntervalSinceNow] * -1.0;
    [result setValue:[NSString stringWithFormat:@"%.3fs", timePassed_seconds] forKey:@"time"];
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)testResponse;
    NSInteger statusCode = [response statusCode];
    [result setValue:[NSString stringWithFormat:@"%zd", statusCode] forKey:@"status"];
    
    NSInteger errorCode = testError.code;
    [result setValue:[NSString stringWithFormat:@"%zd", errorCode] forKey:@"code"];
    
    NSString *responseStr = [[NSString alloc] initWithData:testData encoding:NSASCIIStringEncoding];
    NSInteger length = [responseStr length];
    [result setValue:[NSString stringWithFormat:@"%zd", length] forKey:@"body_length"];
    
    [result setObject:[NSString stringWithFormat:@"fetch %@", file] forKey:@"description"];
    
    return result;
}

@end
