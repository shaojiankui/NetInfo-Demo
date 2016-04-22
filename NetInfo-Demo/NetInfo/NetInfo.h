//
//  NetInfo.h
//  NetInfo-Demo
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface NetInfo : NSObject
//获取网卡信息列表
+ (NSMutableDictionary *)getInterfaceList;
//获取某网卡地址
+ (NSString *) localAddressForInterface:(NSString *)interface;
//获取IP地址
+ (NSString *)getIPAddress;
//网关地址
+ (NSString *)getGatewayIPAddress;
//是否越狱
+ (BOOL)isJailbroken;
//网卡mac地址获取
+ (NSString *)MacAddressOfInterface:(NSString *)interface;
//ping
+ (NSMutableDictionary *)ping:(NSString *)host;
//fetch
+ (NSMutableDictionary *)fetch:(NSString *)file;

+ (id)fetchSSIDInfo;

+ (NSString *)currentWifiSSID;
//根据域名获取ip
+(NSString*)getIPAddressByDomain:(NSString*)domain;
@end
