//
//  PackerViewController.m
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import "PackerViewController.h"
#import "ItemScanViewController.h"

@interface PackerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;
@property int containerId;

@end

@implementation PackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.checkOutButton setEnabled:self.isRobotPresent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToPackerMain:(UIStoryboardSegue *)unwindSegue {
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    // retrieve whether there's a robot present before unwinding
    ItemScanViewController *source = [unwindSegue sourceViewController];
    self.isRobotPresent = source.isRobotPresent;
    [self.checkOutButton setEnabled:self.isRobotPresent];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ItemScanViewController *dest = (ItemScanViewController*)[segue destinationViewController];
    dest.inputStream = self.inputStream;
    [dest.inputStream setDelegate:dest];
    dest.outputStream = self.outputStream;
    [dest.outputStream setDelegate:dest];
    dest.isRobotPresent = self.isRobotPresent;
    if ([segue.identifier isEqualToString:@"fetchItemSegue"]) {
        dest.scanType = FETCH_SCAN;
    }
    else if ([segue.identifier isEqualToString:@"checkOutSegue"]) {
        dest.scanType = CHECKOUT_SCAN;
        dest.containerId = self.containerId;
    }
}

# pragma mark - NSStream Delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream == self.inputStream && eventCode == NSStreamEventHasBytesAvailable) {
        unsigned char data[2];
        long received_length = 0;
        while (received_length < 2) {
            long len = [self.inputStream read:data + received_length maxLength:2 - received_length];
            received_length += len;
        }
        // check if the command code is correct
        if (data[0] != 5)
            NSLog(@"Expected robot arrival (5), received %d", data[0]);
        self.containerId = (int)data[1];
        // enable the checkout button
        self.isRobotPresent = YES;
        [self.checkOutButton setEnabled:YES];
    }
}


@end
