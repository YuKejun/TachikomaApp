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

@end

@implementation DockSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinNetwork:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    int dockId = [self.dockIdTextField.text intValue];
    NSString* viewControllerIdentifier;
    if (dockId == 1) {
        viewControllerIdentifier = @"ContainerScanViewController";
    }
    else if (dockId == 2) {
        viewControllerIdentifier = @"PackerViewController";
    }
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    [self presentViewController:vc animated:YES completion:nil];
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
