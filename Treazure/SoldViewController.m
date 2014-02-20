//
//  SoldViewController.m
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import "SoldViewController.h"

@interface SoldViewController ()

@end

@implementation SoldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.ref = [[Firebase alloc] initWithUrl:@"https://joda.firebaseio.com/"];
    self.authClient = [[FirebaseSimpleLogin alloc] initWithRef:self.ref];
    
    // Check the user's current authentication status
    [self.authClient checkAuthStatusWithBlock:^(NSError* error, FAUser* user) {
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
    [self.ref setValue:@"Do you have data? You'll love Firebase."];
    
    // Read data and react to changes
    [self.ref observeEventType:FEventTypeValue
                     withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
    }];
    
    [self createAuthAccount];
    [self logUserIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAuthAccount
{
    [self.authClient createUserWithEmail:@"email@domain.com"
                                password:@"very secret"
                      andCompletionBlock:^(NSError* error, FAUser* user) {
                     
                     if (error != nil) {
                         // There was an error creating the account
                         NSLog(@"%@", error);
                     } else {
                         // We created a new user account
                         NSLog(@"created account");
                     }
                 }];
}

- (void)logUserIn
{
    [self.authClient loginWithEmail:@"email@domain.com"
                        andPassword:@"very secret"
                withCompletionBlock:^(NSError* error, FAUser* user) {
               
               if (error != nil) {
                   // There was an error logging in to this account
                   NSLog(@"%@", error);
               } else {
                   // We are now logged in
                   NSLog(@"Now logged in");
               }
           }];
}

@end
