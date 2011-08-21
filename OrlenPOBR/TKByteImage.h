//
//  TKByteImage.h
//  OrlenPOBR
//
//  Created by Mapedd on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKConstants.h"

// Max would be CYMKA
#define kMaxSamples	5


@interface TKByteImage : NSObject {
    pixelValue *imageBytes;
    int _width;
    int _height;
    
    // The raw data for the resulting image mask
	unsigned char	*mMaskData;
	size_t			mMaskRowBytes;
	
	// An intermediate table we use when examining the source image to determine
	//	if we have visited a specific pixel location. It is mWidth by mHeight
	//	in size.
	BOOL			*mVisited;
    
	// Information about the pixel the user clicked on, including its coordinates
	//	and its pixel components.
	CGPoint			mPickedPoint;
	unsigned int	mPickedPixel[kMaxSamples];
	
	// The tolerance scaled to the range used by the pixel components in the
	//	source image.
	unsigned int	mTolerance;
    
    // The current solid area found
    unsigned int currentArea;
    
	// The stack of line segments we still need to process. When it goes empty
	//	we're done.
	NSMutableArray*	mStack;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image 
          tolerance:(CGFloat)tol 
         startPoint:(CGPoint)point;

- (pixelValue)redPixelAtIndexX:(int)x andY:(int)y;
- (pixelValue)greenPixelAtIndexX:(int)x andY:(int)y;
- (pixelValue)bluePixelAtIndexX:(int)x andY:(int)y;
- (pixelValue)alphaPixelAtIndexX:(int)x andY:(int)y;
- (UIImage *)currentImage;
- (UIImage *)indexatedImage;

@end
