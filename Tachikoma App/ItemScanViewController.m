//
//  ItemScanViewController.m
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import "ItemScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ItemScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UILabel *_label;
}
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property int itemId;

@end

@implementation ItemScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    if (self.scanType == IMPORT_SCAN) {
        [self.view bringSubviewToFront:self.dismissButton];
        [self.dismissButton setEnabled:NO];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            [_session stopRunning];
            
            _label.text = detectionString;
            self.itemId = [detectionString intValue];
            NSString *alertViewTitle;
            NSString *alertViewMessage;
            if (self.scanType == IMPORT_SCAN) {
                alertViewMessage = [NSString stringWithFormat:@"Checkin item %d to container %d", self.itemId, self.containerId];
                char message[3];
                message[0] = (char)9;
                message[1] = (char)self.itemId;
                message[2] = (char)self.containerId;
                NSData *data = [NSData dataWithBytes:message length:3];
                [self.outputStream write:[data bytes] maxLength:[data length]];
                // TODO: check return value
            }
            else if (self.scanType == FETCH_SCAN) {
                alertViewMessage = [NSString stringWithFormat:@"Fetch item %d", self.itemId];
                char message[2];
                message[0] = (char)1;
                message[1] = (char)self.itemId;
                NSData *data = [NSData dataWithBytes:message length:2];
                [self.outputStream write:[data bytes] maxLength:[data length]];
                // TODO: check return value
                NSLog(@"Fetch item %d", self.itemId);
            }
            else {  // CHECKOUT_SCAN
                alertViewMessage = [NSString stringWithFormat:@"Chekout item %d from container %d", self.itemId, self.containerId];
                char message[4];
                message[0] = (char)10;
                message[1] = (char)self.itemId;
                // dismiss the robot after checkout
                message[2] = (char)12;
                message[3] = (char)self.containerId;
                self.isRobotPresent = NO;
                NSData *data = [NSData dataWithBytes:message length:4];
                [self.outputStream write:[data bytes] maxLength:[data length]];
                // TODO: check return value
                NSLog(@"Chekout item %d", self.itemId);
            }
            
            if (self.scanType != FETCH_SCAN) {
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                                   message:alertViewMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [theAlert show];
            }
            break;
        }
        else
            _label.text = @"(none)";
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"UnwindToContainerScan"]) {
        [_session stopRunning];
        char message[2];
        message[0] = (char)12;
        message[1] = (char)self.containerId;
        NSData *data = [NSData dataWithBytes:message length:2];
        // TODO: check return value
        [self.outputStream write:[data bytes] maxLength:[data length]];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (self.scanType == IMPORT_SCAN) {
            [_session startRunning];
            _highlightView.frame = CGRectMake(0, 0, 0, 0);
        }
        else {
            [self performSegueWithIdentifier:@"UnwindToPackerMain" sender:self];
        }
    }
}



# pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream == self.inputStream && eventCode == NSStreamEventHasBytesAvailable) {
        if (self.scanType == IMPORT_SCAN) {
            // if being notified that a robot has arrived, enable the DISMISS button
            unsigned char reply;
            long len = [self.inputStream read:&reply maxLength:1];
            if (len != 1)
                NSLog(@"IMPORT_SCAN error: receive byte %ld, expected 1", len);
            if (reply != 0)
                NSLog(@"IMPORT SCAN error: receive reply %d, expected 0", reply);
            [self.dismissButton setEnabled:YES];
        }
        else if (self.scanType == FETCH_SCAN) {
            // if being notified that a robot has arrived, log it and notify the packer page at return
            unsigned char reply;
            long len = [self.inputStream read:&reply maxLength:1];
            if (len != 1)
                NSLog(@"FETCH_SCAN error: receive byte %ld, expected 1", len);
            // a robot has arrived
            if (reply == 5) {
                self.isRobotPresent = YES;
            }
            // reqeust item reply: success
            else if (reply == 4) {
                unsigned char containerId;
                long len = [self.inputStream read:&containerId maxLength:1];
                if (len != 1)
                    NSLog(@"FETCH_SCAN reply error: receive byte %ld, expected 1", len);
                self.containerId = (int)containerId;
                NSString* alertViewMessage = [NSString stringWithFormat:@"Item %d is found in container %d", self.itemId, containerId];
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                                   message:alertViewMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [theAlert show];
            }
            // request item reply: item does not exist
            else if (reply == 6) {
                NSString* alertViewMessage = [NSString stringWithFormat:@"Item %d doe not exist", self.itemId];
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                                   message:alertViewMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [theAlert show];
            }
        }
        else {  // CHECKOUT_SCAN
            // shouldn't receive anything
            NSLog(@"CHECKOUT_SCAN error: Shouldn't receive anything");
        }
    }
}

@end
