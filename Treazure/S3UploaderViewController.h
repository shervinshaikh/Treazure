//
//  S3UploaderViewController.h
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <Firebase/Firebase.h>

typedef enum {
    GrandCentralDispatch,
    Delegate,
    BackgroundThread
} UploadType;

typedef enum {
    first,
    second,
    third
} ImageNumber;

@interface S3UploaderViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, AmazonServiceRequestDelegate> {
    UploadType _uploadType;
    ImageNumber _imageNumber;
}

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, weak) IBOutlet UIImageView *firstPhoto;
@property (nonatomic, weak) IBOutlet UIImageView *secondPhoto;
@property (nonatomic, weak) IBOutlet UIImageView *thirdPhoto;

@property (nonatomic, weak) NSString *currentUserId;
@property (nonatomic, retain) Firebase *currentUser;

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

-(IBAction)uploadPhoto:(id)sender;

-(IBAction)uploadPhotoWithGrandCentralDispatch:(id)sender;
-(IBAction)uploadPhotoWithDelegate:(id)sender;
-(IBAction)uploadPhotoWithBackgroundThread:(id)sender;

-(IBAction)showInBrowser:(id)sender;

-(IBAction)selectFirstPhoto:(id)sender;
-(IBAction)selectSecondPhoto:(id)sender;
-(IBAction)selectThirdPhoto:(id)sender;

@end
