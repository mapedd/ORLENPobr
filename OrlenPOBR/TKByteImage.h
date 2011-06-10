//
//  TKByteImage.h
//  OrlenPOBR
//
//  Created by Mapedd on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKConstants.h"


@interface TKByteImage : NSObject {
    pixelValue *imageBytes;
    int _width;
    int _height;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithImage:(UIImage *)image;
- (pixelValue)redPixelAtIndexX:(int)x andY:(int)y;
- (pixelValue)greenPixelAtIndexX:(int)x andY:(int)y;
- (pixelValue)bluePixelAtIndexX:(int)x andY:(int)y;
- (UIImage *)currentImage;

@end
