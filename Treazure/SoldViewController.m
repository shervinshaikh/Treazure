//
//  SoldViewController.m
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import "SoldViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface SoldViewController ()

@end

@implementation SoldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Firebase* ref = [[Firebase alloc] initWithUrl:@"https://joda.firebaseio.com/"];
    FirebaseSimpleLogin* authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
    
    // Check the user's current authentication status
    [authClient checkAuthStatusWithBlock:^(NSError* error, FAUser* user) {
        if (error != nil) {
            // Oh no! There was an error performing the check
        } else if (user == nil) {
            // No user is logged in
            NSLog(@"No user logged in");
        } else {
            // There is a logged in user
            NSLog(@"Logged In!");
        }
    }];
    
    // Write data to Firebase
    [ref setValue:@"Do you have data? You'll love Firebase."];
    
    // Read data and react to changes
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
