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

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UITextField *emailS;
@property (weak, nonatomic) IBOutlet UITextField *passwordS;
@property (weak, nonatomic) IBOutlet UIButton *submitButtonS;


@property (nonatomic, retain) Firebase *ref;
@property (nonatomic, retain) FirebaseSimpleLogin* authClient;

-(IBAction)signUpUser:(id)sender;
-(IBAction)logInUser:(id)sender;



@end
