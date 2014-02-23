//
//  Constants.h
//  Treazure
//
//  Created by Shervin Shaikh on 2/7/14.
//  Copyright (c) 2014 Treazure. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants used to represent your AWS Credentials.
#define ACCESS_KEY_ID          @""
#define SECRET_KEY             @""


// Constants for the Bucket and Object name.
#define PICTURE_BUCKET         @"bucketz"
#define PICTURE_NAME           @"iOS"


#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."

@interface Constants : NSObject

/**
 * Utility method to create a bucket name using the Access Key Id.  This will help ensure uniqueness.
 */
+(NSString *)pictureBucket;

@end
