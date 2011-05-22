//
//  FlipsideViewController.m
//  FaceDemo
//
//  Created by Tomek Kuźma  on 11-03-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate=_delegate;
@synthesize workingImage1, workingImage2, workingImage3;
@synthesize imageView;

- (void)dealloc
{
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
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
    
    NSBundle *bundle = [NSBundle mainBundle];
    maskImage = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"mask5" ofType:@"png"]];
    
   // workingImage3 = [[UIImage alloc] init];
    
    redDifference = 50;
    greenDifference = 50;
    blueDifference = 50;
    overallDifference = 50;
    [self doSegmentation:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    CGImageRef imageRef1 = [self.workingImage1 CGImage];
    CGImageRef imageRef2 = [self.workingImage2 CGImage];
    NSUInteger width = CGImageGetWidth(imageRef1);
    NSUInteger height = CGImageGetHeight(imageRef1);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData1 = malloc(height * width * 4);
	unsigned char *rawData2 = malloc(height * width * 4);
	unsigned char *rawData3 = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context1 = CGBitmapContextCreate(rawData1, width, height,
                                                  bitsPerComponent, bytesPerRow, colorSpace,
                                                  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextRef context2 = CGBitmapContextCreate(rawData2, width, height,
												  bitsPerComponent, bytesPerRow, colorSpace,
												  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context1, CGRectMake(0, 0, width, height), imageRef1);
    CGContextRelease(context1);
	
	CGContextDrawImage(context2, CGRectMake(0, 0, width, height), imageRef2);
    CGContextRelease(context2);
    
    int diff, redDiff, greenDiff, blueDiff;
	
    
    int byteIndex = (bytesPerRow * 0) + 0 * bytesPerPixel;
    
    
    for (int ii = 0 ; ii < width * height ; ++ii)
    {    
        
        
        diff = abs((rawData1[byteIndex]+rawData1[byteIndex+1]+rawData1[byteIndex+2])-(rawData2[byteIndex]+rawData2[byteIndex+1]+rawData2[byteIndex+2]));
        redDiff = abs(rawData1[byteIndex]-rawData2[byteIndex]);
        greenDiff = abs(rawData1[byteIndex+1]-rawData2[byteIndex+1]);
        blueDiff = abs(rawData1[byteIndex+2]-rawData2[byteIndex+2]);
        
        if (greenDiff <= greenDifference && redDiff <= redDifference && blueDiff <= blueDifference && diff <= overallDifference){
            
            
            rawData3[byteIndex]   = 0;
			rawData3[byteIndex+1] = 0;
			rawData3[byteIndex+2] = 0;
			rawData3[byteIndex+3] = 0x00;
            
        }
        else if(greenDiff <=2*greenDifference && redDiff <=2*redDifference && blueDiff <= 2*blueDifference && diff <= 2*overallDifference){
            rawData3[byteIndex]   = rawData2[byteIndex];
			rawData3[byteIndex+1] = rawData2[byteIndex+1];
			rawData3[byteIndex+2] = rawData2[byteIndex+2];
			rawData3[byteIndex+3] = 0x80;
        }
        else{
            rawData3[byteIndex]   = rawData2[byteIndex];
			rawData3[byteIndex+1] = rawData2[byteIndex+1];
			rawData3[byteIndex+2] = rawData2[byteIndex+2];
			rawData3[byteIndex+3] = rawData2    [byteIndex+3];
        }
		
		byteIndex += 4;
		
    }
    
	
	ctx = CGBitmapContextCreate(rawData3,  
								CGImageGetWidth( imageRef1 ),  
								CGImageGetHeight( imageRef1 ),  
								8,  
								CGImageGetBytesPerRow( imageRef1 ),  
								CGImageGetColorSpace( imageRef1 ),  
								kCGImageAlphaPremultipliedLast ); 
	
	imageRef1 = CGBitmapContextCreateImage (ctx);  
	UIImage* rawImage = [[UIImage alloc] initWithCGImage:imageRef1 scale:1.0 orientation:UIImageOrientationRight];
	CGImageRelease(imageRef1);
	CGContextRelease(ctx);  
    
    
	
    self.workingImage3 = rawImage;
    //[imageView performSelectorOnMainThread:@selector(setImage:) withObject: self.workingImage3 waitUntilDone:NO];
    [rawImage release];
    
    [self performSelectorOnMainThread:@selector(setImage) withObject:nil waitUntilDone:NO];
	free(rawData1);
	free(rawData2);
	free(rawData3);
    
    //NSLog(@"finishedSegmentation");
    [activ stopAnimating];
}

- (void)setImage{
    
    NSLog(@"size3 : %f, %f \n size mask ; %f, %f", self.workingImage3.size.width,self.workingImage3.size.height
          ,maskImage.size.width,maskImage.size.height);
    
//    UIImage *imageToSet = [self imageWithImage:workingImage3 scaledToSize:maskImage.size];
//    imageToSet = [self maskImage:imageToSet withMask:maskImage];
    
    self.imageView.image = [self maskImage:workingImage3 withMask:maskImage];
    //[self maskImage:self.workingImage3 withMask:maskImage];

}


- (IBAction)doSegmentation:(id) sender {
   
    [activ startAnimating]; 
    
    [self performSelectorInBackground:@selector(substract) withObject:nil];

}

- (IBAction)adjustTreshold:(id) sender{
    UIButton *myButton = (UIButton *)sender;
    int tag = myButton.tag;
    switch (tag) {
        case 0:
            if (redDifference<245) {
                redDifference+=10;
            }
            break;
        case 1:
            if (redDifference>10) {
                redDifference-=10;
            }
            break;
        case 2:
            if (greenDifference<245) {
                greenDifference+=10;
            }
            break;
        case 3:
            if (greenDifference>10) {
                greenDifference-=10;
            }
            break;
        case 4:
            if (blueDifference<245) {
                blueDifference+=10;
            }
            break;
        case 5:
            if (blueDifference>10) {
                blueDifference-=10;
            }
            break;
        case 6:
            if (overallDifference<3*255-10) {
                overallDifference+=10;
            }
            break;
        case 7:
            if (overallDifference>10) {
                overallDifference-=10;
            }
            break;
            
            
        default:
            break;
    }
    
    [redLabel setText:[NSString stringWithFormat:@"%d", redDifference]];
    [greenLabel setText:[NSString stringWithFormat:@"%d", greenDifference]];
    [blueLabel setText:[NSString stringWithFormat:@"%d", blueDifference]];
    [overallLabel setText:[NSString stringWithFormat:@"%d", overallDifference]];
    
    [self doSegmentation:nil];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)aMaskImage {
    

        CGImageRef maskRef = aMaskImage.CGImage; 
        
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), NULL, false);
        
        CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
        CGImageRelease(mask);
        return [UIImage imageWithCGImage:masked];
  
    
}

- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
