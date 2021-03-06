//
//  S3UploaderViewController.m
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import "S3UploaderViewController.h"
#import "Constants.h"

#import <AWSRuntime/AWSRuntime.h>

@interface S3UploaderViewController ()

@end

@implementation S3UploaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Uploader";
    
    // Initial the S3 Client.
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    if(![ACCESS_KEY_ID isEqualToString:@"AKIAIM7BLTO7XEILT4NA"]
       && self.s3 == nil)
    {
        
        // Create the picture bucket.
        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Constants pictureBucket] andRegion:[S3Region USWest2]];
        S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
    }
    self.currentUser = [[Firebase alloc] initWithUrl: [@"https://joda.firebaseio.com/users/" stringByAppendingString:self.currentUserId]];
    NSLog(@"%@", self.currentUser);
    NSLog(@"%@", self.currentUserId);
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"This device doesn't have a camera."
                                                  delegate:self cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
			break;
		}
		case 1:
		{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"This device doesn't support photo libraries."
                                                  delegate:self cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
                [alert show];
            }
			break;
		}
	}
}

#pragma mark - Grand Central Dispatch

-(IBAction)uploadPhotoWithGrandCentralDispatch:(id)sender
{
    [self showImagePicker:GrandCentralDispatch];
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                                  inBucket:[Constants pictureBucket]];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

#pragma mark - AmazonServiceRequestDelegate

-(IBAction)uploadPhotoWithDelegate:(id)sender
{
    [self showImagePicker:Delegate];
}

- (void)processDelegateUpload:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                              inBucket:[Constants pictureBucket]];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    por.delegate = self;
    
    // Put the image data into the specified s3 bucket and object.
    [self.s3 putObject:por];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlertMessage:error.description withTitle:@"Upload Error"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Background Thread

-(IBAction)uploadPhotoWithBackgroundThread:(id)sender
{
    [self showImagePicker:BackgroundThread];
}

- (void)processBackgroundThreadUpload:(NSData *)imageData
{
    [self performSelectorInBackground:@selector(processBackgroundThreadUploadInBackground:)
                           withObject:imageData];
}

- (void)processBackgroundThreadUploadInBackground:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                              inBucket:[Constants pictureBucket]];
    por.contentType = @"image/jpeg";
    por.data        = imageData;
    
    // Put the image data into the specified s3 bucket and object.
    S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
    [self performSelectorOnMainThread:@selector(showCheckErrorMessage:)
                           withObject:putObjectResponse.error
                        waitUntilDone:NO];
}

- (void)showCheckErrorMessage:(NSError *)error
{
    if(error != nil)
    {
        NSLog(@"Error: %@", error);
        [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
    }
    else
    {
        [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Show the image in the browser

-(IBAction)showInBrowser:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"image/jpeg";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = PICTURE_NAME;
        gpsur.bucket                  = [Constants pictureBucket];
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 172800]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error = nil;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
        
        if(url == nil)
        {
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Error: %@", error);
                    [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display the URL in Safari
                [[UIApplication sharedApplication] openURL:url];
            });
        }
        
    });
}

#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"in the controller");
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    // Convert the image to JPEG data.
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
//    if(_uploadType == GrandCentralDispatch)
//    {
//        [self processGrandCentralDispatchUpload:imageData];
//    }
//    else if(_uploadType == Delegate)
//    {
//        [self processDelegateUpload:imageData];
//    }
//    else if(_uploadType == BackgroundThread)
//    {
//        [self processBackgroundThreadUpload:imageData];
//    }
    
    // Display the image in a view & hold its value in a global property for future reference
    // Then when you click background upload, it runs a background upload on all three images
    // -- Or it uploads in the background for each image as it is selected
    //  Show in browser instead sends 3 links somewhere: email to someone? add to firebase? display in alert?
    
    // FUTURE:
    // Enter in description on same page as image upload, have submit to upload images & sync firebase
    
    // Login and bucket creation?
    // Information we need: First/Last Name, Phone Number, Email
    if(_imageNumber == first)
    {
        NSLog(@"first photo set imageview");
        self.firstPhoto.image = image;
    }
    else if(_imageNumber == second)
    {
        NSLog(@"second photo set imageview");
        self.secondPhoto.image = image;
    }
    else if(_imageNumber == third)
    {
        NSLog(@"third photo set imageview");
        self.thirdPhoto.image = image;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

- (IBAction)selectFirstPhoto:(id)sender
{
    [self showImagePicker:first];
}

- (IBAction)selectSecondPhoto:(id)sender
{
    [self showImagePicker:second];
}

- (IBAction)selectThirdPhoto:(id)sender
{
    [self showImagePicker:third];
}

- (void)showImagePicker:(ImageNumber)imageNumber
{
    _imageNumber = imageNumber;
    UIActionSheet *photoSourcePicker = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Take Photo",
                                        @"Choose from Library",
                                        nil,
                                        nil];
    
    [photoSourcePicker showInView:self.view];
}


- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -

@end
