//
//  FlipsideViewController.m
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "TKConstants.h"
#import "UIImage+Bytes.h"

@implementation FlipsideViewController

@synthesize delegate=_delegate;

@synthesize imageView = _imageView;
@synthesize workingImage = _workingImage;
@synthesize activity = _activity;



- (void)dealloc
{
    self.workingImage = nil;
    self.imageView = nil;
    self.activity = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self setImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


- (void)substract{
    //NSLog(@"startSegmentation, (r, g, b, o) = (%d,%d,%d,%d)", redDifference, greenDifference, blueDifference, overallDifference);
    
	CGContextRef ctx; 
    CGImageRef imageRef1 = [self.workingImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef1);
    NSUInteger height = CGImageGetHeight(imageRef1);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData1 = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context1 = CGBitmapContextCreate(rawData1, width, height,
                                                  bitsPerComponent, bytesPerRow, colorSpace,
                                                  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context1, CGRectMake(0, 0, width, height), imageRef1);
    CGContextRelease(context1);

    int byteIndex = (bytesPerRow * 0) + 0 * bytesPerPixel;
    
    
    for (int ii = 0 ; ii < width * height ; ++ii)
    {    

            rawData1[byteIndex]   = 0;
//			rawData1[byteIndex+1] = 0;
			rawData1[byteIndex+2] = 0;
//			rawData1[byteIndex+3] = 0x00;
		
    }
    
	
	ctx = CGBitmapContextCreate(rawData1,  
								CGImageGetWidth( imageRef1 ),  
								CGImageGetHeight( imageRef1 ),  
								8,  
								CGImageGetBytesPerRow( imageRef1 ),  
								CGImageGetColorSpace( imageRef1 ),  
								kCGImageAlphaPremultipliedLast ); 
	
	imageRef1 = CGBitmapContextCreateImage (ctx);  
	UIImage* rawImage = [[UIImage alloc] initWithCGImage:imageRef1];
//    [[UIImage alloc] initWithCGImage:imageRef1 scale:1.0 orientation:UIImageOrientationRight];
	CGImageRelease(imageRef1);
	CGContextRelease(ctx);  
    
    self.workingImage = rawImage;
    [rawImage release];
	free(rawData1);
    
    [self setImage];
    [self.activity stopAnimating];
}

- (void)setImage{
    
    self.imageView.image = self.workingImage;

}


- (IBAction)doSegmentation:(id) sender {
   
    [self.activity startAnimating]; 
    
    [self findOrlenLogo];

}

- (void)findOrlenLogo{
    
    NSUInteger width = [self.workingImage width];
    NSUInteger height = [self.workingImage height];
    
    unsigned char *rawData = [self.workingImage bytes];
    
    int byteIndex = 0;
    
    for (int ii = 0 ; ii < width * height ; ++ii)
    {    
        
        int gray = rawData[byteIndex]+rawData[byteIndex+1]+rawData[byteIndex+2];
        gray/=3;
    
        rawData[byteIndex]   = gray;
        rawData[byteIndex+1] = gray;
        rawData[byteIndex+2] = gray;
//        rawData[byteIndex+3] = 0x00; // it's Alpha value, useless in this case
            
		
		byteIndex += 4;
		
    }
    
    self.imageView.image = imageFromBytes(rawData, width, height);
    
    free(rawData);
    
    [self.activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
}


@end
