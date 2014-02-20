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
    [self.view endEditing:YES];
    
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
            NSLog(@"already logged in user");
            NSLog(@"%@, %d", user.userId, user.provider);
        }
    }];
    
    // Write data to Firebase
    [self.ref setValue:@"Setting a value!"];
    
    // Read data and react to changes
    [self.ref observeEventType:FEventTypeValue
                     withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(IBAction)signUpUser:(id)sender
{
    [self.emailS resignFirstResponder];
    [self.passwordS resignFirstResponder];
    
    NSLog(@"%lu", (unsigned long)[self.emailS.text length]);
    NSLog(@"%lu", (unsigned long)[self.passwordS.text length]);

    
    if([self.emailS.text length] > 0 && [self.passwordS.text length] > 0)
    {
        NSLog(@"%@", self.emailS.text);
        NSLog(@"%@", self.passwordS.text);
        
        [self.authClient createUserWithEmail:self.emailS.text
                                    password:self.passwordS.text
                          andCompletionBlock:^(NSError* error, FAUser* user) {
                              
                              if (error != nil) {
                                  // There was an error creating the account
                                  NSLog(@"%@", error);
                              } else {
                                  // We created a new user account
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucessful!"
                                                                                  message:@"You have created an account sucessfully!"
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  [self performSegueWithIdentifier:@"accessEverything" sender:self];
                              }
                          }];
    }
}

-(IBAction)logInUser:(id)sender
{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    // Check if text fields are empty
    if([self.email.text length] > 0 && [self.password.text length] > 0)
    {
        NSLog(@"%@", self.email.text);
        NSLog(@"%@", self.password.text);
        
        [self.authClient loginWithEmail:self.email.text
                            andPassword:self.password.text
                    withCompletionBlock:^(NSError* error, FAUser* user) {
                        
                        if (error != nil) {
                            // There was an error logging in to this account
                            NSLog(@"%@", error);
                        } else {
                            // We are now logged in
                            NSLog(@"Now logged in");
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucessful!"
                                                                            message:@"You have logged in sucessfully!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                            [self performSegueWithIdentifier:@"accessEverything" sender:self];
                        }
                    }];
    }
}

@end
