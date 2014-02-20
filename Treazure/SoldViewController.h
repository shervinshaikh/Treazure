//
//  SoldViewController.h
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface SoldViewController : UIViewController

@property (nonatomic, retain) Firebase *ref;
@property (nonatomic, retain) FirebaseSimpleLogin* authClient;

@end
