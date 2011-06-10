//
//  UIImage+Bytes.m
//  OrlenPOBR
//
//  Created by Mapedd on 11-05-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Bytes.h"
#import <QuartzCore/QuartzCore.h>

UIImage* imageFromBytes(unsigned char * bytes, NSUInteger width, NSUInteger height){
    
    UIImage *image;
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    CGContextRef ctx = CGBitmapContextCreate(bytes,  
								width,  
								height,  
								8,  
								bytesPerRow,  
								CGColorSpaceCreateDeviceRGB(),  
								kCGImageAlphaPremultipliedLast ); 
	
	CGImageRef imageRef = CGBitmapContextCreateImage (ctx);  
	image = [[[UIImage alloc] initWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp] autorelease];
//    [UIImage imageWithCGImage:imageRef];
//    [[UIImage alloc] initWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
	CGImageRelease(imageRef);
	CGContextRelease(ctx);  
    
	//free(bytes);

    
    return image;
}


@implementation UIImage (UIImage_Bytes)


- (unsigned char*)bytes{
    CGImageRef imageRef1 = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef1);
    NSUInteger height = CGImageGetHeight(imageRef1);
    NSLog(@"bytes_width: %d, byte_height: %d", width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                  bitsPerComponent, bytesPerRow, colorSpace,
                                                  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef1);
    CGContextRelease(context);
    return rawData;
	
}

- (NSUInteger)width{
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    return width;
}

- (NSUInteger)height{
    CGImageRef imageRef = [self CGImage];
    NSUInteger height = CGImageGetHeight(imageRef);
    return height;
}

- (UIImage*) maskImageWithMask:(UIImage *)aMaskImage{
        
    CGImageRef maskRef = aMaskImage.CGImage; 
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    CGImageRelease(mask);
    return [UIImage imageWithCGImage:masked];
    
    
}

- (UIImage*)imageScaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext( newSize );
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
