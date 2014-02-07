//
//  S3UploaderViewController.h
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>

typedef enum {
    GrandCentralDispatch,
    Delegate,
    BackgroundThread
} UploadType;

@interface S3UploaderViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, AmazonServiceRequestDelegate> {
    UploadType _uploadType;
}

@property (nonatomic, retain) AmazonS3Client *s3;

-(IBAction)uploadPhotoWithGrandCentralDispatch:(id)sender;
-(IBAction)uploadPhotoWithDelegate:(id)sender;
-(IBAction)uploadPhotoWithBackgroundThread:(id)sender;

-(IBAction)showInBrowser:(id)sender;

@end
