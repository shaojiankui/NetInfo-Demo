//
//  RootViewController.h
//  NetInfo-Demo
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *logTextArea;
@property (weak, nonatomic) IBOutlet UITextField *address;
- (IBAction)pingTouched:(id)sender;
- (IBAction)fetchTouched:(id)sender;
- (IBAction)wifiTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *result;

@end
