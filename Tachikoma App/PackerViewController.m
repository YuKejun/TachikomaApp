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

@end

@implementation PackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToPackerMain:(UIStoryboardSegue *)unwindSegue {
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ItemScanViewController *dest = (ItemScanViewController*)[segue destinationViewController];
    if ([segue.identifier isEqualToString:@"fetchItemSegue"]) {
        dest.scanType = FETCH_SCAN;
    }
    else if ([segue.identifier isEqualToString:@"checkOutSegue"]) {
        dest.scanType = CHECKOUT_SCAN;
    }
}


@end
