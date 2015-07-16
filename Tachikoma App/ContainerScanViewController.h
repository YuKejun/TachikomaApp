//
//  ContainerScanViewController.h
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerScanViewController : UIViewController <NSStreamDelegate>

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;

- (IBAction)unwindToContainerScan:(UIStoryboardSegue *)segue;

@end
