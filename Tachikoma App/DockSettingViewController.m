//
//  DockSettingViewController.m
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import "DockSettingViewController.h"
#import "ContainerScanViewController.h"
#import "PackerViewController.h"

@interface DockSettingViewController () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *dockIdTextField;
@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property int dockId;

- (void)initNetworkCommunication;

@end

@implementation DockSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNetworkCommunication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinNetwork:(UIButton *)sender {
    self.dockId = [self.dockIdTextField.text intValue];
    char message[2];
    message[0] = (int)13;
    message[1] = (char)self.dockId;
    NSData *data = [NSData dataWithBytes:message length:2];
    NSInteger returned_len = [self.outputStream write:[data bytes] maxLength:[data length]];
    // TODO: check whether the whole message is sent
//    NSLog(@"%ld", (long)returned_len);
}

#pragma mark - Communication
- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.8.83", 29876, &readStream, &writeStream);
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream == self.inputStream && eventCode == NSStreamEventHasBytesAvailable) {
        unsigned char reply;
        long len = [self.inputStream read:&reply maxLength:1];
        if (len != 1) {
            NSLog(@"Join request error: receive byte %ld, expected 1", len);
        }
        // do appropriate action according to the reply
        if (reply == (char)2) {
            if (self.dockId == 1) {
                [self performSegueWithIdentifier:@"ToImportSegue" sender:self];
            }
            else if (self.dockId == 2) {
                [self performSegueWithIdentifier:@"ToPackingSegue" sender:self];
            }
        }
        else if (reply == (char)3) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                               message:@"Join request is rejected"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
        else {
            NSLog(@"Join Request error: receive reply %d, expected 2 or 3", reply);
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToImportSegue"]) {
        ContainerScanViewController *dest = (ContainerScanViewController*)[segue destinationViewController];
        dest.inputStream = self.inputStream;
        [dest.inputStream setDelegate:dest];
        dest.outputStream = self.outputStream;
        [dest.outputStream setDelegate:dest];
    }
    else if ([segue.identifier isEqualToString:@"ToPackingSegue"]) {
        PackerViewController *dest = (PackerViewController*)[segue destinationViewController];
        dest.inputStream = self.inputStream;
        [dest.inputStream setDelegate:dest];
        dest.outputStream = self.outputStream;
        [dest.outputStream setDelegate:dest];
        dest.isRobotPresent = NO;
    }
}


@end
