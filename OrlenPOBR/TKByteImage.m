//
//  TKByteImage.m
//  OrlenPOBR
//
//  Created by Mapedd on 11-06-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TKByteImage.h"
#import "UIImage+Bytes.h"
#import "UIColor-Expanded.h"

// Instead of defining a custom class for line segments that would only be used
//	in this file, just use NSDictionary and some keys.
#define kSegment_Left	@"segmentLeft"
#define kSegment_Right	@"segmentRight"
#define kSegment_Y		@"segmentY"

#define stdev_M1_Coeff 1.5
#define stdev_M7_Coeff 1.5

/* 'hat' */

#define avg_M1_HAT 0.327392
#define stdev_M1_HAT 0.095488

#define avg_M7_HAT 0.011573
#define stdev_M7_HAT 0.0007319

/* 'eye' */

#define avg_M1_EYE 0.201714
#define stdev_M1_EYE 0.048977

#define avg_M7_EYE 0.066836
#define stdev_M7_EYE 0.085184

/* 'beak' */

#define avg_M1_BEAK 0.369283
#define stdev_M1_BEAK 0.04831519

#define avg_M7_BEAK 0.104852
#define stdev_M7_BEAK 0.0133614

/* letter 'O' */

#define avg_M1_O 0.2201827
#define stdev_M1_O 0.011636

#define avg_M7_O 0.013524
#define stdev_M7_O 0.002767

/* letter 'R' */

#define avg_M1_R 0.19903775
#define stdev_M1_R 0.00668

#define avg_M7_R 0.00903
#define stdev_M7_R 0.000208

/* letter 'L' */

#define avg_M1_L 0.252796
#define stdev_M1_L 0.001852

#define avg_M7_L 0.010514
#define stdev_M7_L 0.0003787

/* letter 'E' */

#define avg_M1_E 0.236469
#define stdev_M1_E 0.0018529

#define avg_M7_E 0.0116323
#define stdev_M7_E 0.0003417

/* letter 'N' */

#define avg_M1_N 0.207458
#define stdev_M1_N 0.016895

#define avg_M7_N 0.01039233
#define stdev_M7_N 0.00122807


#define TKCGPointNegative CGPointMake(-1, -1)

// We allocate the memory for the image mask here, but the CGImageRef is used
//	outside of here. So provide a callback to free up the memory after the
//	caller is done with the CGImageRef.
static void MaskDataProviderReleaseDataCallback(void *info, const void *data, size_t size){
	free((void*)data);
}

pixelValue redValueForIndex(int index){
    pixelValue pix;
    
    pix = 232-3*index;
    
    return pix;
}

pixelValue greenValueForIndex(int index){
    pixelValue pix;
    
    pix = 10+2*index;
    
    return pix;
}

pixelValue blueValueForIndex(int index){
    pixelValue pix;
    
    pix = 100-4*index;
    
    return pix;
}

int RandomUnder(int topPlusOne){
    unsigned two31 = 1U << 31;
    unsigned maxUsable = (two31 / topPlusOne) * topPlusOne;
    
    while(1)
    {
        unsigned num = arc4random();
        if(num < maxUsable)
            return num % topPlusOne;
    }
}

@interface TKByteImage (Private)

- (void)searchLineAtPoint:(CGPoint)point;
- (BOOL)markPointIfItMatches:(CGPoint)point;

- (BOOL)pixelMatches:(CGPoint)point;
- (unsigned int)pixelDifference:(CGPoint)point;

- (void)processSegment:(NSDictionary*)segment;
- (CGImageRef)createMask;
- (CGImageRef)mask;

- (BOOL)unfilledAreaLeft;

- (CGPoint)whitePixel;

@end


@implementation TKByteImage

@synthesize width = _width;
@synthesize height = _height;
@synthesize currentArea;

@synthesize delegate = _delegate;

- (id)initWithImage:(UIImage *)image{
    
    self = [super init];
    
    if(!self)
        return nil;
    
    if (image == nil) {
        return nil;
    }
    
    _width = [image width];
    _height = [image height];
    imageBytes = [image bytes];
    
    if (self.width == 0 || self.height == 0 || imageBytes == NULL) {
        return nil;
    }
    
    _width = [image width];
    _height = [image height];
    imageBytes = [image bytes];
    currentArea = 0;
    
    if (self.width == 0 || self.height == 0 || imageBytes == NULL) {
        return nil;
    }
    mMaskRowBytes = (_width + 0x0000000F) & ~0x0000000F;
    mMaskData = calloc(_height, mMaskRowBytes);
    memset(mMaskData, 0xFF, _height * mMaskRowBytes);
    
    mVisited = calloc(_height * _width, sizeof(BOOL));
    mStack = [[NSMutableArray alloc] init];
    
    
    return self;
}

- (id)initWithImage:(UIImage *)image 
          tolerance:(CGFloat)tol 
         startPoint:(CGPoint)point{

    self = [self initWithImage:image];

    
    mPickedPoint.x = floor(point.x);
    mPickedPoint.y = floor(point.y);

    
    mPickedPixel[0] = [self redPixelAtIndexX:(int)mPickedPoint.x andY:(int)mPickedPoint.y];
    mPickedPixel[1] = [self greenPixelAtIndexX:(int)mPickedPoint.x andY:(int)mPickedPoint.y];
    mPickedPixel[2] = [self bluePixelAtIndexX:(int)mPickedPoint.x andY:(int)mPickedPoint.y];
    mPickedPixel[3] = [self alphaPixelAtIndexX:(int)mPickedPoint.x andY:(int)mPickedPoint.y];
    
    int bitsPerSample = 32;
    int maxSampleValue = 0;
    int i = 0;
    for (i = 0; i < bitsPerSample; ++i)
        maxSampleValue = (maxSampleValue << 1) | 1;
    
    mTolerance = tol * maxSampleValue;

    
    return self;
}

- (id)initWithImage:(UIImage *)image
    backgroundColor:(UIColor *)backgroundColor
       andTolerance:(CGFloat)tol{
    
    self = [self initWithImage:image];
    
    if (!self) {
        return nil;
    }
    
    wantedRed = (unsigned char)[backgroundColor red] * 255;
    wantedGreen = (unsigned char)[backgroundColor green] * 255;
    wantedBlue = (unsigned char)[backgroundColor blue] * 255;
    
    NSLog(@"wanted rgb = (%d,%d,%d)", wantedRed, wantedGreen, wantedBlue);
    
    int bitsPerSample = 32;
    int maxSampleValue = 0;
    int i = 0;
    for (i = 0; i < bitsPerSample; ++i)
        maxSampleValue = (maxSampleValue << 1) | 1;
    
    CGPoint point = CGPointMake(-1, -1);
    
    point = [self whitePixel];
    
    if (CGPointEqualToPoint(point, TKCGPointNegative)) {
        NSLog(@"no white points");
        return nil;
    }
    
    mPickedPoint.x = floor(point.x);
    mPickedPoint.y = floor(point.y);
    
    mPickedPixel[0] = [self redPixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
    mPickedPixel[1] = [self greenPixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
    mPickedPixel[2] = [self bluePixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
    
    mTolerance = tol * maxSampleValue;
    
    currentArea = 1;
    
    return self;
    
}

- (void)dealloc{
    NSLog(@"dealloc TKByteImage");
    free(imageBytes);
    free(mVisited);
    free(mMaskData);
    [mStack release];
    [super dealloc];
}

- (UIImage *)currentImage{
    UIImage *image;
    
    image = imageFromBytes(imageBytes, self.width, self.height);
    
    return image;
}

- (UIImage *)indexatedImage{
    UIImage *image = nil;
    
    image = [UIImage imageWithCGImage:[self mask]];
    
    return image;
}

- (BOOL)unfilledAreaLeft{
    BOOL whitePixelsLeft = NO;
    
    for (int i = 0; i<_width; i++) 
    {
        for (int j = 0; j<_height; j++) 
        {
            if (wantedRed == [self redPixelAtIndexX:i andY:j] &&
                wantedGreen == [self greenPixelAtIndexX:i andY:j] &&
                wantedBlue == [self bluePixelAtIndexX:i andY:j]) 
            {
                whitePixelsLeft = YES;
                break;
            }
        }
    }
    
    return whitePixelsLeft;
}

- (CGImageRef) mask{
	// Prime the loop so we have something on the stack. searcLineAtPoint
	//	will look both to the right and left for pixels that match the 
	//	selected color. It will then throw that line segment onto the stack.
	
	
	// While the stack isn't empty, continue to process line segments that
	//	are on the stack.
	while ([self unfilledAreaLeft]) {
        [self searchLineAtPoint:mPickedPoint];
        
        while ( [mStack count] > 0 ) {
            //NSLog(@"mStack count = %d", [mStack count]);
            // Pop the top segment off the stack
            NSDictionary* segment = [[[mStack lastObject] retain] autorelease];
            [mStack removeLastObject];
            
            // Process the segment, by looking both above and below it for pixels
            //	that match the user picked pixel
            [self processSegment:segment];
        }
        
        CGPoint point = [self whitePixel];
        
        if (CGPointEqualToPoint(TKCGPointNegative, point)) {
            break;
        }
        
        mPickedPoint.x = floor(point.x);
        mPickedPoint.y = floor(point.y);
        
        mPickedPixel[0] = [self redPixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
        mPickedPixel[1] = [self greenPixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
        mPickedPixel[2] = [self bluePixelAtIndexX:mPickedPoint.x andY:mPickedPoint.y];
        
        currentArea++;
    }
    
    NSLog(@"%d areas found", currentArea);
	
	// We're done, so convert our mask data into a real mask
	return [self createMask];
}

- (CGPoint)whitePixel{
    CGPoint whitePoint = TKCGPointNegative;
    
    for (int i = 0; i<_width; i++) 
    {
        for (int j = 0; j<_height; j++) 
        {
            if (wantedRed == [self redPixelAtIndexX:i andY:j] &&
                wantedGreen == [self greenPixelAtIndexX:i andY:j] &&
                wantedBlue == [self bluePixelAtIndexX:i andY:j]) 
            {
                whitePoint = CGPointMake(i, j);
                break;
            }
        }
    }
    
    return whitePoint;
}

- (void)searchLineAtPoint:(CGPoint)point{
    
    
	// This function will look at the point passed in to see if it matches
	//	the selected pixel. It will then look to the left and right of the
	//	passed in point for pixels that match. In addition to adding a line
	//	segment to the stack (to be processed later), it will mark the mVisited
	//	and mMaskData bitmaps to reflect if the pixels have been visited or
	//	should be selected.
	
	// First, we want to do some sanity checking. This includes making sure
	//	the point is in bounds, and that the specified point hasn't already
	//	been visited.
    
//   NSLog(@"search line at point = %@", NSStringFromCGPoint(point));
    
	if ( (point.y < 0) || (point.y >= _height) || (point.x < 0) || (point.x >= _width) )
		return;
	BOOL* hasBeenVisited = (mVisited + (long)point.y * _width + (long)point.x);
	if ( *hasBeenVisited )
		return;
    
	// Make sure the point we're starting at at least matches. If it doesn't,
	//	there's not a line segment here, and we can bail now.
	if ( ![self markPointIfItMatches:point] )
		return;
	
	// Search left, marking pixels as visited, and in or out of the selection
	float x = point.x - 1.0;
	float left = point.x;
	while ( x >= 0 ) {
		if ( [self markPointIfItMatches: CGPointMake(x, point.y)] )
			left = x; // Expand our line segment to the left
		else
			break; // If it doesn't match, the we're done looking
		x = x - 1.0;
	}
	
	// Search right, marking pixels as visited, and in or out of the selection
	float right = point.x;
	x = point.x + 1.0;
	while ( x < _width ) {
		if ( [self markPointIfItMatches: CGPointMake(x, point.y)] )
			right = x; // Expand our line segment to the right
		else
			break; // If it doesn't match, the we're done looking
		x = x + 1.0;
	}
	
	// Push the segment we just found onto the stack, so we can look above
	//	and below it later.
	NSDictionary* segment = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:left], kSegment_Left,
                             [NSNumber numberWithFloat:right], kSegment_Right,
                             [NSNumber numberWithFloat:point.y], kSegment_Y,
                             nil];
	[mStack addObject:segment];	
}

- (BOOL) markPointIfItMatches:(CGPoint) point{
	// This method examines a specific pixel to see if it should be in the selection
	//	or not, by determining if it is "close" to the user picked pixel. Regardless
	//	of it is in the selection, we mark the pixel as visited so we don't examine
	//	it again.
	
	// Do some sanity checking. If its already been visited, then it doesn't
	//	match
	BOOL* hasBeenVisited = (mVisited + (long)point.y * _width + (long)point.x);
	if ( *hasBeenVisited )
		return NO;
	
	// Ask a helper function to determine if the pixel passed in matches
	//	the user selected pixel
	BOOL matches = NO;
	if ( [self pixelMatches:point] ) {
        //NSLog(@"point %@ is good", NSStringFromCGPoint(point));
		// The pixels match, so return that answer to the caller
		matches = YES;
		
		// Now actually mark the mask
		unsigned char* maskRow = mMaskData + (mMaskRowBytes * (long)point.y);
		maskRow[(long)point.x] = 0x00; // all on
        
        [self setRedPixel:redValueForIndex(currentArea) 
                 atIndexX:(int)point.x 
                     andY:(int)point.y];
        
        [self setGreenPixel:greenValueForIndex(currentArea)
                   atIndexX:(int)point.x 
                       andY:(int)point.y];
        
        [self setBluePixel:blueValueForIndex(currentArea) 
                  atIndexX:(int)point.x 
                      andY:(int)point.y];
        
        
	}
    else{
        //NSLog(@"point %@ is bad", NSStringFromCGPoint(point));
    }
	
	// We've made a decision about this pixel, so we've visted it. Mark it
	//	as such.
	*hasBeenVisited = YES;
	
	return matches;
}

- (BOOL) pixelMatches:(CGPoint)point{
	// We don't do exact matches (unless the tolerance is 0), so compute
	//	the "difference" between the user selected pixel and the passed in
	//	pixel. If it's less than the specified tolerance, then the pixels
	//	match.
	unsigned int difference = [self pixelDifference:point];	
    
    //NSLog(@"diff = %d,pA=%@, pB = %@",difference, NSStringFromCGPoint(mPickedPoint), NSStringFromCGPoint(point));
	
	return difference <= mTolerance;
}

- (unsigned int) pixelDifference:(CGPoint)point{
	// This method determines the "difference" between the specified pixel
	//	and the user selected pixel in a very simple and cheap way. It takes
	//	the difference of all the components (except alpha) and which ever
	//	has the greatest difference, that's the difference between the pixels.
	
	
	// First get the components for the point passed in
	unsigned int pixel[kMaxSamples];
	//[mImageRep getPixel:pixel atX:(int)point.x y:(int)point.y];
    
    pixel[0] = [self redPixelAtIndexX:(int)point.x andY:(int)point.y];
    pixel[1] = [self greenPixelAtIndexX:(int)point.x andY:(int)point.y];
    pixel[2] = [self bluePixelAtIndexX:(int)point.x andY:(int)point.y];
    pixel[3] = [self alphaPixelAtIndexX:(int)point.x andY:(int)point.y];
    
    
//    NSLog(@"        pixel%@ = (%d,%d,%d)", NSStringFromCGPoint(point), pixel[0],pixel[1],pixel[2]);
//    NSLog(@"picked  pixel%@ = (%d,%d,%d)", NSStringFromCGPoint(mPickedPoint), mPickedPixel[0],mPickedPixel[1],mPickedPixel[2]);
	
	// Determine the largest difference in the pixel components. Note that we
	//	assume the alpha channel is the last component, and we skip it.
	unsigned int maxDifference = 0;
//	int samplesPerPixel = 4;	
//	int i = 0;
//	for (i = 0; i < (samplesPerPixel - 1); ++i) {
//		unsigned int difference = abs((long)mPickedPixel[i] - (long)pixel[i]);
//		if ( difference > maxDifference )
//			maxDifference = difference;
//	}
    
    maxDifference = abs((long)mPickedPixel[0] - (long)pixel[0]);
	
	return maxDifference;
}

- (void) processSegment:(NSDictionary*)segment{
	// Figure out where this segment actually lies, by pulling the line segment
	//	information out of the dictionary
	NSNumber* leftNumber = [segment objectForKey:kSegment_Left];
	NSNumber* rightNumber = [segment objectForKey:kSegment_Right];
	NSNumber* yNumber = [segment objectForKey:kSegment_Y];
	float left = [leftNumber floatValue];
	float right = [rightNumber floatValue];
	float y = [yNumber floatValue];
	
	// We're going to walk this segment, and test each integral point both
	//	above and below it. Note that we're doing a four point connect.
	float x = 0.0;
	for ( x = left; x <= right; x = x + 1.0 ) {
		[self searchLineAtPoint: CGPointMake(x, y + 1.0)]; // check above
		[self searchLineAtPoint: CGPointMake(x, y - 1.0)]; // check below
	}
}

- (CGImageRef)createMask{
    
    NSUInteger bytesPerPixel = 1;
    NSUInteger bytesPerRow = bytesPerPixel * _width+12;
    
    CGContextRef ctx = CGBitmapContextCreate(mMaskData,  
                                             (size_t)_width,  
                                             (size_t)_height,  
                                             8,  
                                             bytesPerRow,  
                                             CGColorSpaceCreateDeviceGray(),  
                                             kCGImageAlphaNone); 
    

    if (ctx == NULL) {
        NSLog(@"context from bytes is NULL");
        return nil;
    }
    
    CGImageRef imageRef = NULL;//CGBitmapContextCreateImage (ctx);  
    return imageRef;
}

- (void)analyze{
    [self performSelectorInBackground:@selector(backgroundAnalyze) withObject:nil];
}

- (void)backgroundAnalyze{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CGFloat m00, m01, m10,m11, m20, m02;
    CGFloat M20,M02, M11;
    CGFloat M1, M7;
    
    NSInteger minX,maxX;
    NSInteger minY,maxY;
    
    minX = _width;
    maxX = 0;
    minY = _height;
    maxY = 0;
    
    pixelValue redIndex;
    pixelValue greenIndex; 
    pixelValue blueIndex;
    
    UIColor *yellowColor = [UIColor yellowColor];
    
    int areaIndex = 1;
    
    for (int i=1; i<currentArea; i++) {
        redIndex = redValueForIndex(i);
        greenIndex = greenValueForIndex(i);
        blueIndex = blueValueForIndex(i);
        
        //NSLog(@"wanted color = (%d,%d,%d) at index %d", redIndex, greenIndex, blueIndex, i);
        
        
        m00=0.0f;
        m01=0.0f;
        m10=0.0f;
        m11=0.0f;
        m20=0.0f;
        m02=0.0f;
        M20=0.0f;
        M02=0.0f;
        M11=0.0f;
        M1 =0.0f;
        M7 =0.0f;
        
        minX = _width;
        maxX = 0;
        minY = _height;
        maxY = 0;
        
        /*
         
         m00 = ΣΣf(x,y)
         m01 = ΣΣ y f(x,y)
         m10 = ΣΣ x f(x,y)
         m11 = ΣΣ x y
         m02 = ΣΣ y^2
         m20 = ΣΣ x^2
         
         M20 = m20-m10^2/m00
         M02 = m02-m01^2/m00
         M11 = m11-m10*m01/m00
         
         
         M1 = {M20+M02}/m00^2
         
         M7 = {M20*M02-M11^2}/m00^4
         
         
         */
        
        for (int x=0; x<_width; x++) {
            for (int y=0; y<_height; y++) {
                if (redIndex == [self redPixelAtIndexX:x andY:y] &&
                    greenIndex == [self greenPixelAtIndexX:x andY:y] &&
                    blueIndex == [self bluePixelAtIndexX:x andY:y] ) 
                {
                    m00++;
                    m01+=y;
                    m10+=x;
                    m11+=x*y;
                    m20+=x*x;
                    m02+=y*y;
                    
                    
                    if (minX>x)
                        minX = x;
                    if (maxX<x)
                        maxX = x;
                    if (minY>y)
                        minY = y;
                    if (maxY<y)
                        maxY = y;
                    
                }
            }
        }
        
       
        if (m00>200.0f && maxX-minX != _width) {
            
            areaIndex+=20;
            
            M20 = m20-(m10*m10)/m00;
            
            M02 = m02-(m01*m01)/m00;
            
            M11 = m11-(m10*m01)/m00;
            
            
            M1 = (M20+M02)/(m00*m00);
            
            M7 = (M20*M02-M11*M11)/(m00*m00*m00*m00);
            
//            NSLog(@"M1 = %f, M7 = %f, area (S=%f) index = %d",M1, M7, m00 ,i);
//            NSLog(@"minX = %d, maxX= = %d, minY = %d, maxY = %d",minX, maxX, minY, maxY);
            
            CGRect boundingRect = CGRectMake(minX, minY, maxX-minX, maxY-minY);
            
            if (ABS(M1-avg_M1_O)<stdev_M1_Coeff*stdev_M1_O && ABS(M7-avg_M7_O)<stdev_M7_Coeff*stdev_M7_O) {
                NSLog(@"letter 'O' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor redColor] andMarkIndex:1];
                oRect = boundingRect;
            }
            else if ((ABS(M1-avg_M1_R)<stdev_M1_Coeff*stdev_M1_R) && (ABS(M7-avg_M7_R)< stdev_M7_Coeff*stdev_M7_R)) {
                NSLog(@"letter 'R' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor blueColor] andMarkIndex:2];
                rRect = boundingRect;
            }
            else if ((ABS(M1-avg_M1_L)<stdev_M1_Coeff*stdev_M1_L) && (ABS(M7-avg_M7_L)< stdev_M7_Coeff*stdev_M7_L)) {
                NSLog(@"letter 'L' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor greenColor] andMarkIndex:3];
                lRect = boundingRect;
            }
            else if ((ABS(M1-avg_M1_E)<stdev_M1_Coeff*stdev_M1_E) && (ABS(M7-avg_M7_E)< stdev_M7_Coeff*stdev_M7_E)) {
                NSLog(@"letter 'E' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor whiteColor] andMarkIndex:4];
                eRect = boundingRect;
            }
            else if ((ABS(M1-avg_M1_N)<stdev_M1_Coeff*stdev_M1_N) && (ABS(M7-avg_M7_N)< stdev_M7_Coeff*stdev_M7_N)) {
                NSLog(@"letter 'N' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor cyanColor] andMarkIndex:5];
                nRect = boundingRect;
            }
//            else if ((ABS(M1-avg_M1_EYE)<stdev_M1_Coeff*stdev_M1_EYE) && (ABS(M7-avg_M7_EYE)< stdev_M7_Coeff*stdev_M7_EYE)) {
//                NSLog(@"letter 'EYE' found");
//                [self drawRectInBytes:boundingRect withColor:[UIColor cyanColor] andMarkIndex:5];
//            }
            else if ((ABS(M1-avg_M1_HAT)<stdev_M1_Coeff*stdev_M1_HAT) && (ABS(M7-avg_M7_HAT)< stdev_M7_Coeff*stdev_M7_HAT)) {
                NSLog(@"letter 'HAT' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor cyanColor] andMarkIndex:5];
                hatRect = boundingRect;
            }
            else if ((ABS(M1-avg_M1_BEAK)<stdev_M1_Coeff*stdev_M1_BEAK) && (ABS(M7-avg_M7_BEAK)< stdev_M7_Coeff*stdev_M7_BEAK)) {
                NSLog(@"letter 'BEAK' found");
                [self drawRectInBytes:boundingRect withColor:[UIColor cyanColor] andMarkIndex:5];
                beakRect = boundingRect;
            }
            else{
                [self drawRectInBytes:boundingRect withColor:yellowColor andMarkIndex:-1];
            }
            
            
            if (!CGRectIsEmpty(oRect) && !CGRectIsEmpty(rRect) && !CGRectIsEmpty(hatRect)) {
                NSLog(@"o r hat found");
                [self drawLineFromPoint:CGRectCenter(oRect) toPoint:CGRectCenter(rRect) withColor:yellowColor];
                [self drawLineFromPoint:CGRectCenter(rRect) toPoint:CGRectCenter(hatRect) withColor:yellowColor];
                [self drawLineFromPoint:CGRectCenter(hatRect) toPoint:CGRectCenter(oRect) withColor:yellowColor];
            }
            else{
                NSLog(@"o r hat not found");
            }
            
            
            //[self drawLineFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(600, 512) withColor:yellowColor];
            //[self drawLineFromPoint:CGPointMake(600, 0) toPoint:CGPointMake(0, 512) withColor:yellowColor];
            
            
            for (int x=0; x<_width; x++) {
                for (int y=0; y<_height; y++) {
                    if (redIndex == [self redPixelAtIndexX:x andY:y] &&
                        greenIndex == [self greenPixelAtIndexX:x andY:y] &&
                        blueIndex == [self bluePixelAtIndexX:x andY:y] ) {
                        
                        [self setRedPixel:areaIndex atIndexX:x andY:y];
                        [self setGreenPixel:areaIndex atIndexX:x andY:y];
                        [self setBluePixel:areaIndex atIndexX:x andY:y];
                    }
                    
                }
            }
            
            [self.delegate performSelectorOnMainThread:@selector(imageAnalyzed:) withObject:self waitUntilDone:NO];
        }
        
        
        
    }
    
    [pool drain];
    
    [self.delegate performSelectorOnMainThread:@selector(imageAnalyzed:) withObject:self waitUntilDone:NO];
}

- (UIImage *)imageWithMarkedCharacters{
    UIImage *image;
    return image;
}

@end

@implementation TKByteImage (AccessPixels)

- (pixelValue)redPixelAtIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0) {
        return 0;
    }
    
    pixelValue red;
    
    
    int row = self.width * y;
    
    int column = x;
    
    red = imageBytes[(row+column)*4];
    
    return red;
}
- (pixelValue)greenPixelAtIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0) {
        return 0;
    }
    
    pixelValue green;
    
    int row = self.width * y;
    
    int column = x;
    
    green = imageBytes[(row+column)*4+1];
    
    return green;
}
- (pixelValue)bluePixelAtIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0) {
        return 0;
    }
    
    pixelValue blue;
    
    int row = self.width * y;
    
    int column = x;
    
    blue = imageBytes[(row+column)*4+2];
    
    return blue;
}
- (pixelValue)alphaPixelAtIndexX:(int)x andY:(int)y{
    if (x>=self.width || y>=self.height || x < 0 || y < 0) {
        return 0;
    }
    
    pixelValue blue;
    
    int row = self.width * y;
    
    int column = x;
    
    blue = imageBytes[row+column*4+3];
    
    return blue;
}

- (void)setRedPixel:(pixelValue)value atIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0) 
        return;
    
    int row = self.width * y;
    
    int column = x;
    
    imageBytes[(row+column)*4] = value;
    
}
- (void)setGreenPixel:(pixelValue)value atIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0) {
        return;
    }
    int row = self.width * y;
    
    int column = x;
    
    imageBytes[(row+column)*4+1] = value;
}
- (void)setBluePixel:(pixelValue)value atIndexX:(int)x andY:(int)y{
    
    if (x>=self.width || y>=self.height || x < 0 || y < 0)
        return;
    
    int row = self.width * y;
    
    int column = x;
    
    imageBytes[(row+column)*4+2] = value;
}
- (void)setAlphaPixel:(pixelValue)value atIndexX:(int)x andY:(int)y{
    if (x>=self.width || y>=self.height || x < 0 || y < 0)
        return;
    int row = self.width * y;
    
    int column = x;
    
    imageBytes[(row+column)*4+3] = value;
}

- (void)drawRectInBytes:(CGRect)rect withColor:(UIColor *)color{
    [self drawRectInBytes:rect withColor:color andMarkIndex:-1];
}

- (void)drawRectInBytes:(CGRect)rect withColor:(UIColor *)color andMarkIndex:(NSInteger)index{
    
    //NSLog(@"drawInRect:%@ index:%d", NSStringFromCGRect(rect), index);
    
    pixelValue redPixel = [color red]*255;
    pixelValue greenPixel = [color green]*255;
    pixelValue bluePixel = [color blue]*255;
    
    int minX = (int)rect.origin.x;
    int maxX = (int)(rect.origin.x + rect.size.width);
    int minY = (int)rect.origin.y;
    int maxY = (int)(rect.origin.y + rect.size.height);
    
    
    
    for (int x=0; x<_width; x++) {
        for (int y=0; y<_height; y++) {
            if ((x>=minX && x<=maxX && y == minY) ||
                (x>=minX && x<=maxX && y == maxY) ||
                (x==minX && y>=minY && y<=maxY) ||
                (x==maxX && y>=minY && y<=maxY)
                ) {
                [self setRedPixel:redPixel atIndexX:x andY:y];
                [self setGreenPixel:greenPixel atIndexX:x andY:y];
                [self setBluePixel:bluePixel atIndexX:x andY:y];
            }
        }
    }
    
    if (index>0) {
        CGPoint point = CGPointMake(minX+2, minY+2);
        
        for (int i=0; i<index; i++) {
            [self drawPointAtPoint:point withColor:color];\
            point.x+=4;
        }
    }
    
}

- (void)drawPointAtPoint:(CGPoint)point withColor:(UIColor *)color{
    
    
    NSInteger x = (NSInteger)point.x;
    NSInteger y = (NSInteger)point.y;
    
    if (x<1 || x>_width-1 || y< 1 || y<_height-1 ) {
        [self setPixelColor:color atIndexX:x-1 andY:y-1];
        [self setPixelColor:color atIndexX:x andY:y-1];
        [self setPixelColor:color atIndexX:x+1 andY:y-1];
        
        [self setPixelColor:color atIndexX:x-1 andY:y];
        [self setPixelColor:color atIndexX:x andY:y];
        [self setPixelColor:color atIndexX:x+1 andY:y];
        
        [self setPixelColor:color atIndexX:x-1 andY:y+1];
        [self setPixelColor:color atIndexX:x andY:y+1];
        [self setPixelColor:color atIndexX:x+1 andY:y+1];
    }
}

- (void)setPixelColor:(UIColor *)color atIndexX:(int)x andY:(int)y{
    pixelValue redPixel = [color red]*255;
    pixelValue greenPixel = [color green]*255;
    pixelValue bluePixel = [color blue]*255;
    
    [self setRedPixel:redPixel atIndexX:x andY:y];
    [self setGreenPixel:greenPixel atIndexX:x andY:y];
    [self setBluePixel:bluePixel atIndexX:x andY:y];
    
    
}

- (void)drawLineFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB withColor:(UIColor *)color{
    //y-y0 = (y1-y0)/(x1-x0)*(x-0)
    //y = (y1-y0)/(x1-x0)*(x-x0)+y0
    //y = a*x - a*x0 + y0
    
    CGFloat a = (pointB.y-pointA.y)/(pointB.x-pointA.x);
    
    
    pixelValue redPixel = [color red]*255;
    pixelValue greenPixel = [color green]*255;
    pixelValue bluePixel = [color blue]*255;
    
    int minX = (int)MIN(pointA.x, pointB.x);
    int maxX = (int)MAX(pointA.x, pointB.x);
    int minY = (int)MIN(pointA.y, pointB.y);
    int maxY = (int)MAX(pointA.y, pointB.y);
    
    
    int leftSide = 0;
    int yInt  = 0;
    
    for (int x=minX; x<=maxX; x++) {
        for (int y=minY; y<=maxY; y++) {
            
            leftSide = a*x-a*pointA.x+pointA.y;
            yInt = (int)y;
            
            if (yInt == leftSide) {
                [self setRedPixel:redPixel atIndexX:x andY:y];
                [self setGreenPixel:greenPixel atIndexX:x andY:y];
                [self setBluePixel:bluePixel atIndexX:x andY:y];
            }
        }
    }
    
}


@end