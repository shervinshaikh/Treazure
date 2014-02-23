//
//  DescriptionViewController.h
//  Treazure
//
//  Created by Shervin Shaikh on 2/22/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *iPhoneModelPicker;
@property (strong, nonatomic) IBOutlet NSArray *iPhoneModels;

@end
