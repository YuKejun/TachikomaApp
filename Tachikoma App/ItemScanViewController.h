//
//  ItemScanViewController.h
//  Tachikoma App
//
//  Created by YuKejun on 7/3/15.
//  Copyright (c) 2015 YuKejun. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ScanType {
    IMPORT_SCAN,
    FETCH_SCAN,
    CHECKOUT_SCAN
};

@interface ItemScanViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, assign) enum ScanType scanType;
@property int containerId;

@end
