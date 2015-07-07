//
//  DockSettingViewController.m
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import "DockSettingViewController.h"
#import "ContainerScanViewController.h"

@interface DockSettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *dockIdTextField;
@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;

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
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    int dockId = [self.dockIdTextField.text intValue];
//    NSString* viewControllerIdentifier;
    char message[2];
    message[0] = (int)13;
    message[1] = (char)dockId;
    NSData *data = [NSData dataWithBytes:message length:2];
//    NSInteger returned_len = [self.outputStream write:[data bytes] maxLength:[data length]];
    // TODO: check whether the whole message is sent
//    NSLog(@"%ld", (long)returned_len);
    if (dockId == 1) {
//        viewControllerIdentifier = @"ContainerScanViewController";
        [self performSegueWithIdentifier:@"ToImportSegue" sender:self];
    }
    else if (dockId == 2) {
//        viewControllerIdentifier = @"PackerViewController";
        [self performSegueWithIdentifier:@"ToPackingSegue" sender:self];
    }
//    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
//    [self presentViewController:vc animated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
