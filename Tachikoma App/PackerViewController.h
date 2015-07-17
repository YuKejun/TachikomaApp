//
//  PackerViewController.h
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackerViewController : UIViewController <NSStreamDelegate>

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property BOOL isRobotPresent;

- (IBAction)unwindToPackerMain:(UIStoryboardSegue *)unwindSegue;

@end
