//
//  TKByteImage.m
//  OrlenPOBR
//
//  Created by Mapedd on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TKByteImage.h"
#import "UIImage+Bytes.h"
#import "UIImage+Bytes.h"

@implementation TKByteImage

@synthesize width = _width;
@synthesize height = _height;


- (id)initWithImage:(UIImage *)image{
    
    if (image == nil) {
        return nil;
    }
    
    self = [super init];
    
    if(!self)
        return nil;
    
    _width = [image width];
    _height = [image height];
    imageBytes = [image bytes];
    
    if (self.width == 0 || self.height == 0 || imageBytes == NULL) {
        return nil;
    }
    
    return self;
}

- (void)dealloc{
    free(imageBytes);
    [super dealloc];
}

- (pixelValue)redPixelAtIndexX:(int)x andY:(int)y{
    
    if (x>self.width || y>self.height) {
        return 0;
    }
    
    pixelValue red;
    
    
    int row = self.width * y;
    
    int column = x;
    
    red = imageBytes[row+column*4];
    
    return red;
}
- (pixelValue)greenPixelAtIndexX:(int)x andY:(int)y{
    
    if (x>self.width || y>self.height) {
        return 0;
    }
    
    pixelValue green;
    
    int row = self.width * y;
    
    int column = x;
    
    green = imageBytes[row+column*4+1];
    
    return green;
}
- (pixelValue)bluePixelAtIndexX:(int)x andY:(int)y{
    
    if (x>self.width || y>self.height) {
        return 0;
    }
    
    pixelValue blue;
    
    int row = self.width * y;
    
    int column = x;
    
    blue = imageBytes[row+column*4+2];
    
    return blue;
}

- (UIImage *)currentImage{
    UIImage *image;
    
    image = imageFromBytes(imageBytes, self.width, self.height);
    
    return image;
}

@end
