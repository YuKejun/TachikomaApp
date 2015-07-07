//
//  ContainerScanViewController.m
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import "ContainerScanViewController.h"
#import "ItemScanViewController.h"

@interface ContainerScanViewController ()

@end

@implementation ContainerScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanContainer:(UIStoryboardSegue *)segue {
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ItemScanViewController *dest = (ItemScanViewController*)[segue destinationViewController];
    if ([segue.identifier isEqualToString:@"checkInSegue"]) {
        dest.scanType = IMPORT_SCAN;
    }
}


@end
