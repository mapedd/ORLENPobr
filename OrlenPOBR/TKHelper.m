//
//  TKHelper.m
//  Retail Incentive
//
//  Created by Nobody on 11-04-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TKHelper.h"


CGPoint CGRectCenter(CGRect rect){
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

NSString * TKNSStringFromBOOL(BOOL yesOrNo){
    if(yesOrNo){
        return [NSString stringWithFormat:@"YES"];
    }
    else{
        return [NSString stringWithFormat:@"NO"];
    }
}

NSString * TKNSStringFromUIViewContentMode(UIViewContentMode mode){
    NSString *string;
    switch (mode) {
        case UIViewContentModeBottom:
            string = [NSString stringWithFormat:@"UIViewContentModeBottom"];
            break;
        case UIViewContentModeBottomLeft:
            string = [NSString stringWithFormat:@"UIViewContentModeBottomLeft"];
            break;
        case UIViewContentModeBottomRight:
            string = [NSString stringWithFormat:@"UIViewContentModeBottomRight"];
            break;
        case UIViewContentModeCenter:
            string = [NSString stringWithFormat:@"UIViewContentModeCenter"];
            break;
        case UIViewContentModeLeft:
            string = [NSString stringWithFormat:@"UIViewContentModeLeft"];
            break;
        case UIViewContentModeRedraw:
            string = [NSString stringWithFormat:@"UIViewContentModeRedraw"];
            break;
        case UIViewContentModeRight:
            string = [NSString stringWithFormat:@"UIViewContentModeRight"];
            break;
        case UIViewContentModeScaleAspectFill:
            string = [NSString stringWithFormat:@"UIViewContentModeScaleAspectFill"];
            break;
        case UIViewContentModeScaleAspectFit:
            string = [NSString stringWithFormat:@"UIViewContentModeScaleAspectFit"];
            break;
        case UIViewContentModeScaleToFill:
            string = [NSString stringWithFormat:@"UIViewContentModeScaleToFill"];
            break;
        case UIViewContentModeTop:
            string = [NSString stringWithFormat:@"UIViewContentModeTop"];
            break;
        case UIViewContentModeTopLeft:
            string = [NSString stringWithFormat:@"UIViewContentModeTopLeft"];
            break;
        case UIViewContentModeTopRight:
            string = [NSString stringWithFormat:@"UIViewContentModeTopRight"];
            break;
            
        default:
            string = nil;
            break;
    }
    
    return string;
}

NSString * TKNSStringFromUIInterfaceOrientation(UIInterfaceOrientation orientation){
    NSString *string;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            string = [NSString stringWithFormat:@"UIInterfaceOrientationLandscapeLeft"];
            break;
        case UIInterfaceOrientationLandscapeRight:
            string = [NSString stringWithFormat:@"UIInterfaceOrientationLandscapeRight"];
            break;
        case UIInterfaceOrientationPortrait:
            string = [NSString stringWithFormat:@"UIInterfaceOrientationPortrait"];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            string = [NSString stringWithFormat:@"UIInterfaceOrientationPortraitUpsideDown"];
            break;
        default:
            string = nil;
            break;
    }
    
    return string;
    
}

NSString * TKNSStringFromUIImageOrientation(UIImageOrientation orientation){
    NSString *string;
    
    switch (orientation) {
        case UIImageOrientationDown:
            string = [NSString stringWithFormat:@"UIInterfaceOrientationLandscapeRight"];
            break;
        case UIImageOrientationDownMirrored:
            string = [NSString stringWithFormat:@"UIImageOrientationDownMirrored"];
            break;
        case UIImageOrientationLeft:
            string = [NSString stringWithFormat:@"UIImageOrientationLeft"];
            break;
        case UIImageOrientationLeftMirrored:
            string = [NSString stringWithFormat:@"UIImageOrientationLeftMirrored"];
            break;
        case UIImageOrientationRight:
            string = [NSString stringWithFormat:@"UIImageOrientationRight"];
            break;
        case UIImageOrientationRightMirrored:
            string = [NSString stringWithFormat:@"UIImageOrientationRightMirrored"];
            break;
        case UIImageOrientationUp:
            string = [NSString stringWithFormat:@"UIImageOrientationUp"];
            break;
        case UIImageOrientationUpMirrored:
            string = [NSString stringWithFormat:@"UIImageOrientationUpMirrored"];
            break;
        default:
            string = nil;
            break;
    }
    
    return string;
}


#define iPadLandscapeWidth 1024.0
#define iPadLandscapeHeight 768.0
#define iPadPortraitWidth 768.0
#define iPadPortraitHeight 1024.0

@implementation TKHelper

+ (CGFloat)systemVersion{
    
    NSLog(@"software version : %@", [[UIDevice currentDevice] systemVersion]);
    
    return [[[UIDevice currentDevice] systemVersion] floatValue];

}

+ (BOOL)isSupportedOrientation:(UIInterfaceOrientation )orientation{
    if (orientation != UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    else
        return NO;
}

+ (CGPoint)centerForView:(UIView *)aView foriPadInOrientation:(UIInterfaceOrientation)interfaceOrientation{
    CGPoint center;
    CGRect frame = aView.frame;
    center.y = frame.origin.y;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        center.x = iPadPortraitWidth/2;
    }
    else{
        center.x = iPadLandscapeWidth/2 ;
    }
    
    return center;
}

+ (void)logImage:(UIImage *)img{

    if (img == nil) {
        NSLog(@"image to log is nil!");
        return;
    }
    
    CGSize sz = img.size;
    LogImageData(@"image", 0, sz.width, sz.height, UIImagePNGRepresentation(img));

}

+ (void)logImageWithDescription:(UIImage *)image{
    NSLog(@"image desc: %@", [image TKdescription]);
    [[self class] logImage:image];
}

+ (void)logImage:(UIImage *)img andComment:(NSString *)comment{
    if (img == nil) {
        NSLog(@"image to log is nil!");
        return;
    }
    
    CGSize sz = img.size;
    NSLog(@"comment:%@", comment);
    LogImageData(@"image", 0, sz.width, sz.height, UIImagePNGRepresentation(img));
}

+ (UIImage *)TKUIImageFromView:(UIView *)view{

    if (view == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

+ (void)logView:(UIView *)view{
    [TKHelper logImage:[TKHelper TKUIImageFromView:view]];
}

+ (void)logViewWithDescription:(UIView *)view{
    NSLog(@"view desc: %@", [view description]);
    [[self class] logView:view];
}

+ (NSString*)generateGUID{
    
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString*)string autorelease];
}

+ (NSString *)cashesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)documentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}


@end


@implementation UIImage (NSBundle)

+ (UIImage *)imageAtPath:(NSString *)path ofType:(NSString *)type{
    NSString *globalPath = [NSString stringWithFormat:@"%@.%@", path, type];
    UIImage *image = [UIImage imageWithContentsOfFile:globalPath];
    
    return image;
    
}

@end

@implementation NSArray (logging)

- (void)logDescription{
    NSLog(@"array:%@", [self description]);
}

- (id)TKfirstObject{
    if ([self count] == 0) {
        return nil;
    }
    return [self objectAtIndex:0];
}

@end


@implementation UIImage (Masking)

- (void)maskWithMask:(UIImage *)aMaskImage {
    
    if (aMaskImage == nil) {
        NSLog(@"mask is nil");
        return;
    }
    
    
    CGImageRef maskRef = aMaskImage.CGImage; 
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    CGImageRelease(mask);
    
    self = [UIImage imageWithCGImage:masked];

}

- (UIImage *)invertColors{
    
    UIGraphicsBeginImageContext(self.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;

}

- (NSString *)TKdescription{
    return [NSString stringWithFormat:@"%@, w: %.2f, h:%.2f, scale: %.2f, orientation: %@"
            ,[self description], self.size.width, self.size.height, self.scale, TKNSStringFromUIImageOrientation(self.imageOrientation)];
    
}

@end


