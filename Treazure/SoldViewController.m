//
//  SoldViewController.m
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import "SoldViewController.h"
#import "S3UploaderViewController.h"

@interface SoldViewController ()

@property (nonatomic, retain) IBOutlet UITextField *activeField;

@end

@implementation SoldViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view endEditing:YES];
    [self.submitButtonS setEnabled:NO];
    
    [self.nameField setDelegate:self];
    [self.phoneNumberField setDelegate:self];
    [self.emailField setDelegate:self];
    [self.passwordField setDelegate:self];
    
    self.ref = [[Firebase alloc] initWithUrl:@"https://joda.firebaseio.com/"];
    self.users = [self.ref childByAppendingPath:@"users"];
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
            self.currentUser = [self.users childByAppendingPath:user.userId];
            NSLog(@"User logged in: %@, %d, %@", user.userId, user.provider, user.email);
            self.currentUserId = user.userId;
            
#warning go through accessEverything segue here when testing with signup is done
            [self performSegueWithIdentifier:@"accessEverything" sender:self];

        }
    }];
    
    // Read data and react to changes
//    [self.ref observeEventType:FEventTypeValue
//                     withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"%@ -> %@", snapshot.name, snapshot.value);
//    }];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"accessEverything"]){
        S3UploaderViewController *controller = segue.destinationViewController;
        controller.currentUserId = self.currentUserId;
    }
}

-(IBAction)signUpUser:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    if([self.emailField.text length] > 0 && [self.passwordField.text length] > 0 && [self.phoneNumberField.text length] > 0 )
    {
        [self.authClient createUserWithEmail:self.emailField.text
                                    password:self.passwordField.text
                          andCompletionBlock:^(NSError* error, FAUser* user) {
                              
                              if (error != nil) {
                                  // There was an error creating the account
                                  NSLog(@"%@", error);
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:error.description
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              } else {
                                  // We created a new user account
                                  
                                  // Write data to Firebase
                                  self.currentUser = [self.users childByAppendingPath:user.userId];
                                  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:user.email, @"Email", self.nameField.text, @"Name", self.phoneNumberField.text, @"PhoneNumber", nil];
                                  NSLog(@"%@", dic);
                                  [self.currentUser setValue:dic];
                                  
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucessful!"
                                                                                  message:@"You have created an account sucessfully!"
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
#warning Remove this line below and only move when loggin in
                                  [self performSegueWithIdentifier:@"accessEverything" sender:self];
                                  
                                  [alert show];
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
        [self.authClient loginWithEmail:self.email.text
                            andPassword:self.password.text
                    withCompletionBlock:^(NSError* error, FAUser* user) {
                        NSLog(@"%@", user);
                        
                        if (error != nil) {
                            // There was an error logging in to this account
                            NSLog(@"%@", error);
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                            message:error.localizedDescription
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            // We are now logged in
                            NSLog(@"Now logged in");
                            self.currentUser = [self.users childByAppendingPath:user.userId];
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

#pragma mark - Phone Number Field Formatting
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( [self.emailField.text length] != 0 && [self.passwordField.text length] != 0 && [self.phoneNumberField.text length] != 0 && [self.nameField.text length] != 0 && [self.nameField.text length] != 0)
    {
        [self.submitButtonS setEnabled:YES];
    }
    else {
        [self.submitButtonS setEnabled:NO];
    }

    _activeField = textField;
    if (textField == self.phoneNumberField) {
        NSInteger length = [self getLength:textField.text];
        
        if(length == 10) {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3) {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6) {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSInteger length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}


-(NSInteger)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSInteger length = [mobileNumber length];
    return length;
}

@end
