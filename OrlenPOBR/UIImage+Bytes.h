//
//  UIImage+Bytes.h
//  OrlenPOBR
//
//  Created by Mapedd on 11-05-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


UIImage* imageFromBytes(unsigned char * bytes, NSUInteger width, NSUInteger height);

@interface UIImage (UIImage_Bytes)

- (unsigned char*)bytes;
- (NSUInteger)width;
- (NSUInteger)height;
- (UIImage*) maskImageWithMask:(UIImage *)aMaskImage;
- (UIImage*)imageScaledToSize:(CGSize)newSize;

@end


