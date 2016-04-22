//
//  RootViewController.m
//  NetInfo-Demo
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "RootViewController.h"
#import "NetInfo.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self printInterfaceList];
    
    NSLog(@"getIPAddressByDomain:%@", [NetInfo getIPAddressByDomain:@"www.github.com"]);
    NSLog(@"getGatewayIPAddress:%@", [NetInfo getGatewayIPAddress]);

    
}


- (void)printInterfaceList{
    NSMutableDictionary* allInterfaceList = [NetInfo getInterfaceList];
    for (NSString *name in allInterfaceList)
    {
        [self appendLog:[NSString stringWithFormat:@"Interface %@ : %@#%@", name, [allInterfaceList objectForKey:name], [NetInfo MacAddressOfInterface:name]] to:self.logTextArea];
    }
}
- (void)appendLog:(NSString *)logmessage to:(UITextView *)area {
    NSString *logcache = area.text;
    
    area.text = [NSString stringWithFormat:@"%@ %@\n", logcache, logmessage];
    [area scrollRangeToVisible:NSMakeRange(logcache.length + logmessage.length, 0)];
}

- (IBAction)pingTouched:(id)sender {
    self.result.text = [[NetInfo ping:self.address.text] description];
}

- (IBAction)fetchTouched:(id)sender {
    self.result.text = [[NetInfo fetch:self.address.text] description];

}

- (IBAction)wifiTouched:(id)sender {
    self.result.text = [[NetInfo fetchSSIDInfo] description];

}
@end
