//
//  TKHelper.h
//  Retail Incentive
//
//  Created by Nobody on 11-04-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define DEGREES_TO_RADIANS(x) (M_PI*x/180.0f)
#define RADIANS_TO_DEGREES(x) (180.0f*x/M_PI)

#define PNG_TYPE @"png"

/** Returns center CGPoint of a CGRect structure */
CGPoint CGRectCenter(CGRect rect);

@interface TKHelper : NSObject {}

+ (CGFloat)systemVersion;

/** Returns YES if specified orientation is allowed */
+ (BOOL)isSupportedOrientation:(UIInterfaceOrientation )orientation;
/** Returns CGPoint structure with center of view for specified interface orientation */
+ (CGPoint)centerForView:(UIView *)aView foriPadInOrientation:(UIInterfaceOrientation)interfaceOrientation;
/** log UIImage object using NSLogger framework, protected from nil */
+ (void)logImage:(UIImage *)img;
/** log UIImage object using NSLogger framework, protected from nil, with description */
+ (void)logImageWithDescription:(UIImage *)img ;
/** log UIImage object using NSLogger framework, protected from nil , with comment*/
+ (void)logImage:(UIImage *)img andComment:(NSString *)comment;
/** log UIView transformed to UIImage using NSLogger framework, protected from nil */
+ (void)logView:(UIView *)view;
/** log UIView transformed to UIImage using NSLogger framework, protected from nil, with description */
+ (void)logViewWithDescription:(UIView *)view;
/** generates an UIImage from non-nil UIView */
+ (UIImage *)TKUIImageFromView:(UIView *)view;
/** Returns an autoreleased 40 - chars random string */
+ (NSString*)generateGUID;
/** Returns an autoreleased path to current Caches directory */
+ (NSString *)cashesDirectory;
/** Returns an autoreleased path to current Documents directory */
+ (NSString *)documentsDirectory;

@end

@interface UIImage (NSBundle)

+ (UIImage *)imageAtPath:(NSString *)path ofType:(NSString *)type;

@end

@interface NSArray (logging)

/** return first object in an array, of there are any objects inside array */
- (id)TKfirstObject;

@end

NSString * TKNSStringFromBOOL(BOOL yesOrNo);

@interface UIImage (Masking)

- (void)maskWithMask:(UIImage *)aMaskImage; 

- (UIImage *)invertColors;

- (NSString *)TKdescription;

@end



